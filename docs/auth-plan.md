# Mettle — Authentication & Data Plan (M2)

Google and email sign-in via Supabase, Supabase Postgres as the database. Companion to
[`product-plan.md`](./product-plan.md) and [`backend-plan.md`](./backend-plan.md).

**Scope:** this is the M2 identity milestone. M1 ships with no auth and device-local storage; this
document is how that becomes an account without throwing the local path away.

---

## 1. Decisions

| Decision | Choice | Why |
|---|---|---|
| Google OAuth | **Shipped** | Free, no per-message cost, and most target users already have an account. The path we expect most users to take |
| Email + password | **Shipped** | Supabase owns the hashing, reset tokens and rate limiting, so the cost is a reset screen and an email template — not a security system we write |
| Phone OTP | **Not shipped** | Needs a paid SMS provider and per-country config. Not a trust decision — a phone JWT is exactly as valid as a Google one |
| Auth service | **Supabase Auth** | Issues the JWT, rotates refresh tokens, owns the OAuth dance |
| Database | **Supabase Postgres** | One managed Postgres serving app data *and* the LangGraph checkpointer |
| Token verification | **Local, via JWKS** | No network hop per request once keys are cached |
| Anonymous start | **Yes — anonymous sign-in, later linked to a real identity** | Preserves M1's "zero friction to try it" (see §7) |

> **Correction to a common framing:** there is no "demo" versus "authentic" auth method. Every
> Supabase method — Google, email, phone — issues the same signed JWT with the same claims and the
> same `sub`. The backend cannot tell them apart and should not try. Pick methods on cost and
> friction, never on perceived legitimacy.

**What email + password adds that Google-only did not have:** a password-reset flow (screen, email
template, deep link back into the app), a sign-up path distinct from sign-in, and a verification
step before a new account is trusted. Supabase provides the mechanics; the app provides the screens.
It also means the reset deep link joins the OAuth callback as a second link the Android manifest
must handle.

---

## 2. Who owns what

```
┌──────────────┐   Google OAuth (PKCE)    ┌─────────────────┐
│  Flutter app │ ───────────────────────▶ │  Supabase Auth  │
│              │ ◀─── JWT + refresh ───── │                 │
└──────┬───────┘                          └────────┬────────┘
       │                                           │ signs tokens
       │ Bearer JWT                                │ publishes JWKS
       ▼                                           ▼
┌──────────────┐   verify JWT locally     ┌─────────────────┐
│   FastAPI    │ ───── (cached JWKS) ────▶ │   JWKS endpoint │
│              │                          └─────────────────┘
│  owns the    │
│  interview   │  service_role key
└──────┬───────┘ ─────────────────┐
       │                          ▼
       │                 ┌──────────────────┐
       │  reads own rows │ Supabase Postgres│
       └── via RLS ─────▶│  app tables      │
         (app, direct)   │  + checkpoints   │
                         └──────────────────┘
```

**Supabase owns:** the OAuth flow, token signing, refresh rotation, the user table, and the database.

**FastAPI owns:** the interview. It verifies tokens, runs the graph, calls Claude, and writes
sessions and scores. It never issues or refreshes tokens.

**Two paths to the database, deliberately:**

| Path | Used for | Auth |
|---|---|---|
| App → Supabase directly | Reading *your own* history, trend, topic mastery | Anon key + **RLS** |
| FastAPI → Supabase | Writing sessions and scores; LangGraph checkpoints | **service_role** key, bypasses RLS |

This split is the standard Supabase pattern and it is not laziness. Reads of your own rows need no
business logic, so routing them through FastAPI adds a hop and a second thing to keep up. Writes
*do* need logic — the scores are produced by the graph — so the backend owns them. The rule that
keeps it honest: **the backend is the only writer of interview data; the app only ever reads it.**

---

## 3. The wiring, step by step

Your sequence was right. Spelled out:

1. **App** calls native Google Sign-In, receives a Google `idToken`.
2. **App** passes it to `supabase.auth.signInWithIdToken(provider: google, idToken: …)`.
3. **Supabase** creates-or-finds the user and returns a session: a short-lived **access token (JWT)**
   plus a **refresh token**. `supabase_flutter` persists both and refreshes in the background.
4. **App** attaches `Authorization: Bearer <access_token>` to every FastAPI request.
5. **FastAPI** verifies the signature against Supabase's cached **JWKS**, checks `exp`, `iss` and
   `aud`, and reads `sub` — the user's UUID. No call to Supabase per request.
6. **FastAPI** scopes everything to that `sub`: the LangGraph `thread_id`, session ownership, and the
   `user_id` it writes on every row.
7. **App** reads Home and Progress **directly from Supabase**, where RLS restricts rows to
   `auth.uid() = user_id`.

**Email + password:** steps 1–2 are replaced by `signInWithPassword` or `signUp`; everything from
step 3 is identical. `signUp` may return a session with an unconfirmed email depending on project
settings — decide explicitly whether an unverified account can start an interview, because the
default is permissive.

Why verify locally rather than calling `GET /auth/v1/user`: that endpoint is a network round-trip on
every single request, and it would put Supabase's uptime in the path of every interview turn. JWKS
keys are fetched once and cached; rotation is handled by refetching on an unknown `kid`.

---

## 4. Schema and RLS

Two tables. Scores stay denormalised onto the session row because every read wants them together.

```sql
create table public.sessions (
  id            text primary key,              -- sesn_… from the backend
  user_id       uuid not null references auth.users on delete cascade,
  topic         text not null,
  difficulty    text not null,
  model         text not null,                 -- which model graded it
  overall       int  not null,
  correctness   int  not null,
  depth         int  not null,
  clarity       int  not null,
  structure     int  not null,
  missing       jsonb not null default '[]',
  completed_at  timestamptz not null default now()
);

create table public.turns (
  id            bigint generated always as identity primary key,
  session_id    text not null references public.sessions on delete cascade,
  position      int  not null,
  kind          text not null,                 -- initial | follow_up
  reason        text,                          -- weakest dimension, when follow_up
  question      text not null,
  answer        text not null,
  score         jsonb not null,
  unique (session_id, position)
);

create index sessions_user_completed_idx
  on public.sessions (user_id, completed_at desc);

alter table public.sessions enable row level security;
alter table public.turns    enable row level security;

create policy "own sessions" on public.sessions
  for select using (auth.uid() = user_id);

create policy "own turns" on public.turns
  for select using (
    exists (
      select 1 from public.sessions s
      where s.id = turns.session_id and s.user_id = auth.uid()
    )
  );
```

**Select-only policies, on purpose.** There is no insert or update policy for the app, so the app
*cannot* write a score even if someone tampers with the client. The backend writes with the
service_role key, which bypasses RLS entirely. A self-reported score would make the whole product
meaningless, so the database is where that gets prevented.

**LangGraph's checkpoint tables live in the same database** and are created by
`AsyncPostgresSaver.setup()`. The backend reaches them over a direct connection; the app must never
see them. Keep them out of the `public` schema exposed to the anon key, or leave RLS on with no
policy so the anon key cannot read them.

---

## 5. Backend changes

### Token verification

A FastAPI dependency, roughly:

```python
CurrentUser = Annotated[str, Depends(require_user)]   # returns the user's uuid

async def require_user(authorization: Annotated[str | None, Header()] = None) -> str:
    token = _bearer(authorization)                    # 401 if absent / malformed
    claims = await verify_supabase_jwt(token)         # JWKS-cached; 401 on bad sig / exp
    return claims["sub"]
```

Verification checks signature, `exp`, `iss` (your project's auth URL) and `aud` (`authenticated`).
Keys come from the project's JWKS endpoint, cached in memory, refetched when a token presents an
unseen `kid`.

> Supabase has moved from a single shared HS256 secret to asymmetric signing keys with a JWKS
> endpoint. Prefer the asymmetric path. The legacy shared-secret route still works but means
> distributing a symmetric secret that can also *mint* tokens, not just verify them. **Confirm the
> current endpoint path and key format against Supabase's docs when implementing** — this area has
> changed more than once.

### Ownership — a hole to close

Today `device_id` is stored on the session handle and **never checked**. Anyone who knows a
`session_id` can stream it, answer it, read its scorecard, or delete it. Auth must close this, and
not just on new endpoints:

- `registry.get()` grows an owner check; a mismatch is **404**, not 403 — a 403 confirms the session
  exists to someone who shouldn't know.
- `thread_id` becomes `{user_id}:{session_id}` so checkpoints are partitioned by user.
- Rehydrating a handle from a checkpoint must restore the owner too, or a restart reopens the hole.

### Writing results

When `summarize` completes, the backend writes one `sessions` row and N `turns` rows with the
service_role key. This replaces the app writing to `shared_preferences`.

### Endpoint matrix

| Endpoint | Auth |
|---|---|
| `GET /healthz`, `GET /v1/meta` | public |
| `GET /v1/topics` | public — a catalogue, not user data |
| everything under `/v1/sessions` | **Bearer required + ownership checked** |

---

## 6. App changes

- Add `supabase_flutter`, plus `google_sign_in` for the **native** Google flow. Native beats the
  browser redirect on Android: no chrome tab, no visible redirect, and it works offline-ish to the
  point of failure.
- **Use the official Google button or logo asset.** The `GoogleMark` currently on the sign-in screen
  is a hand-drawn `CustomPainter` standing in so the screen renders without a dependency. Google's
  brand guidelines require their supplied mark on a sign-in affordance, so replace it before any
  public release.
- The sign-in screen is built (`features/auth`) with a `SignInCubit` driving mode (sign in / sign
  up), validation, obscure-toggle and remember-device. It talks to an `AuthRepository` interface
  with **no implementation yet** — wiring Supabase behind that interface is step 5/6 below.
- `Splash` gains the branch it doesn't have today: valid session → Home, otherwise → `/sign-in`.
- `ApiClient` attaches the bearer token and, on a **401**, refreshes once via Supabase and retries
  exactly once before surfacing an error. Without the retry, every expired token looks like a server
  failure to the user.
- A `SupabaseSessionDataSource` implementing the existing `SessionLocalDataSource` interface, so
  Home, Progress and History keep working against the shape they already consume.
- Keep `shared_preferences` as a **read-through cache** so Home still renders offline. The current
  local-only path becomes the cache layer rather than being deleted.

---

## 7. The problem nobody plans for: existing local data

M1 users have sessions in `shared_preferences` and no account. On first launch after the update
those rows belong to nobody.

**Use Supabase anonymous sign-in, then link.** On first launch, sign in anonymously — this yields a
real user id and a real JWT with no UI at all. Local sessions get uploaded under it. When the user
later signs in with Google, link the Google identity to that *same* anonymous user, and the history
survives.

This also resolves the tension M2 otherwise creates with M1's "zero friction to try it": the
onboarding flow stays skippable because an anonymous user is a *real* user from the backend's point
of view. Nothing is gated; signing in upgrades an account that already exists.

Two cautions: anonymous users accumulate in `auth.users` and want periodic cleanup, and linking
fails if that Google identity is already attached to another account — which needs a real decision
(merge, or adopt the existing account and discard the anonymous one) rather than an unhandled error.

---

## 8. What will bite

| Thing | Detail |
|---|---|
| **Android SHA-1 fingerprints** | Google OAuth needs the signing certificate fingerprint registered. **Debug and release keystores differ** — register both, or sign-in works in development and fails in the Play build. The single most common cause of "it worked on my machine". |
| **Two OAuth client IDs** | Android needs its own client ID *and* the Web client ID (Supabase uses the web one as the audience). Mixing them up yields an opaque `invalid_audience`. |
| **SSE cannot carry a bearer header on web** | `EventSource` cannot set headers — the same constraint that made the stream a GET. On mobile (`package:http`) headers work fine. The web build will need a short-lived token in the query string or a cookie, which is one more reason web is postponed. |
| **Token lifetime vs long interviews** | Access tokens are short-lived (an hour by default). A long interview can outlive one. `supabase_flutter` refreshes in the background, but an **already-open SSE connection keeps the token it was opened with** — so the stream must tolerate being reopened, which the rehydration work already supports. |
| **service_role key** | Full database access, bypasses every policy. Server-side only, never in the app, never in a `--dart-define`, never in a client-readable env file. |
| **Deep link scheme** | Even the native flow needs the callback scheme registered in the manifest and in Supabase's allowed redirect URLs. |
| **Free-tier project pausing** | Supabase pauses inactive free projects. A paused project means auth *and* database *and* checkpointer all down at once — one failure taking out three things. |

---

## 9. Build order

Each step leaves the app working.

1. **Supabase project + Google OAuth** — console config, both client IDs, both SHA-1s. No app code.
   Verify by signing in from a throwaway script.
2. **Schema + RLS** — create the tables and policies. Verify RLS by querying with the anon key as
   two different users and confirming neither sees the other's rows. *Test the policy before any
   code depends on it.*
3. **Backend verification + ownership** — the dependency, the owner check, `thread_id` partitioning.
   Close the ownership hole here, before any data is worth stealing.
4. **Backend writes results** — `summarize` persists to Postgres. Both storage paths run in parallel
   for one release.
5. **App: anonymous sign-in + upload** — no UI yet. Existing users migrate silently.
6. **App: Google sign-in + linking** — `SignIn` screen, Splash branch, identity linking.
7. **App: read from Supabase** — swap the data source; keep `shared_preferences` as cache.
8. **Checkpointer onto Supabase Postgres** — last, because it is the step most likely to need the
   connection-pooling workaround (see `backend-plan.md` §6: the transaction pooler on port 6543 does
   not support prepared statements).

Steps 1–3 are the security-relevant ones. Steps 4–7 are migration. Step 8 is infrastructure and can
slip without blocking anything.

---

## 10. Setting up Google sign-in, step by step

Console work, no app code. Do this before step 5 of the build order. Anything marked **copy this**
is a value you will need later, so keep a scratch file.

Supabase and Google both move their UI around — if a label below does not match what you see, the
*concept* is still right; find the equivalently-named thing rather than assuming it was removed.

### Values specific to this project

| What | Value |
|---|---|
| Android package name | `com.zeeshanhaider.mettle` |
| Debug SHA-1 | `CE:02:BF:95:6E:AD:25:EC:6A:B2:1C:EE:A5:FE:DD:00:D9:2A:1D:35` |
| Release SHA-1 | Not generated yet — see step 3 |

### 1. Create the Supabase project

1. supabase.com → **New project**. Pick a region near your users; it cannot be changed later.
2. Save the database password it generates — it is in the Postgres connection string you will need
   for the checkpointer.
3. **Settings → API**: **copy this** — the *Project URL* and the *anon public* key. These two are
   safe in the app.
4. On the same page is the **service_role** key. **Server-side only.** It bypasses every RLS policy.
   Never in the app, never in a `--dart-define`, never committed.

### 2. Create the Google Cloud project and consent screen

1. console.cloud.google.com → new project.
2. **APIs & Services → OAuth consent screen**. Choose *External*.
3. Fill in app name, support email, developer email. Nothing else is required while testing.
4. While the app is in *Testing*, only accounts you add under **Test users** can sign in. Add your
   own Google account now — forgetting this produces a confusing `access_denied` later.

### 3. Get both SHA-1 fingerprints

The debug one is above. Android OAuth clients are tied to the signing certificate, and **the debug
and release certificates are different** — register both or sign-in works in development and fails
in the Play build. This is the single most common cause of "it worked on my machine".

```bash
# debug (already captured above)
keytool -list -v -alias androiddebugkey   -keystore ~/.android/debug.keystore -storepass android -keypass android

# release - once you create a release keystore
keytool -list -v -alias <your-alias> -keystore <path-to-release.jks>
```

If you ship via Play App Signing, Google re-signs the app, so the fingerprint that matters is the
one in **Play Console → Setup → App signing**, not your upload key. Register that one too.

### 4. Create *two* OAuth client IDs

This is the part that trips people up. You need both, and they do different jobs.

| Client type | Why | Where it goes |
|---|---|---|
| **Web application** | Supabase exchanges the token as this client; it is also the `aud` claim | Supabase dashboard, and the app's `serverClientId` |
| **Android** | Lets the *native* sign-in sheet trust your app | Nowhere in code — Google matches it by package + SHA-1 |

**Web application client:**

1. **Credentials → Create credentials → OAuth client ID → Web application**.
2. Under *Authorized redirect URIs* add: `https://<your-project-ref>.supabase.co/auth/v1/callback`
3. **copy this** — the client ID *and* client secret.

**Android client:**

1. **Create credentials → OAuth client ID → Android**.
2. Package name: `com.zeeshanhaider.mettle`
3. SHA-1: the debug fingerprint above. Repeat this step for the release fingerprint — one Android
   client per certificate.
4. There is no secret for Android clients. That is expected, not a mistake.

### 5. Enable Google in Supabase

1. **Authentication → Providers → Google**, toggle on.
2. Paste the **Web** client ID and secret from step 4. Not the Android one.
3. **Authorized Client IDs** — add the **Android** client ID here. This is what lets the native
   `signInWithIdToken` flow be accepted; without it, native sign-in returns a bad-audience error even
   though the browser flow works.
4. **Authentication → URL Configuration → Redirect URLs** — add your app's deep link, e.g.
   `com.zeeshanhaider.mettle://login-callback`. Needed for the browser fallback and for password
   reset links.

### 6. Wire the app

```yaml
dependencies:
  supabase_flutter: ^2.0.0
  google_sign_in: ^6.0.0
```

```dart
await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
```

Pass both values with `--dart-define-from-file` rather than committing them. The anon key is safe in
a client — RLS is what protects the data, not the key's secrecy — but keeping it out of git means
rotating it does not need a code change.

Native sign-in, in outline:

```dart
final google = GoogleSignIn(serverClientId: webClientId);   // the WEB id, not Android
final account = await google.signIn();
final auth    = await account!.authentication;

await supabase.auth.signInWithIdToken(
  provider: OAuthProvider.google,
  idToken:  auth.idToken!,
  accessToken: auth.accessToken,
);
```

The `serverClientId` being the *web* client ID is counter-intuitive and is the second most common
mistake after the SHA-1.

Finally, register the deep link scheme in `android/app/src/main/AndroidManifest.xml` so the browser
fallback and password-reset links return to the app.

### 7. Verify before writing more code

In order, because each step rules out a different failure:

1. Sign in on an emulator. A `sign_in_failed` with a numeric code almost always means the SHA-1 or
   package name does not match the Android client.
2. Check **Authentication → Users** in Supabase — the user should appear with a Google identity.
3. Decode the access token at jwt.io and confirm `sub`, `iss` and `aud`. `sub` is what the backend
   will treat as the user.
4. Only then point the backend at the JWKS endpoint and start verifying.
