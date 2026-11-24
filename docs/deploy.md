# Deploying Mettle

Three free services, no credit card anywhere.

| Piece | Host | URL |
|---|---|---|
| Flutter web build | GitHub Pages | `https://skull94.github.io/mettle/` |
| FastAPI + LangGraph | Render free web service | `https://mettle-api.onrender.com` |
| Postgres, auth, checkpoints | Supabase free project | `https://<ref>.supabase.co` |

The LLM calls are the only line item that costs money. `FREE_SESSIONS_PER_USER` and
`MONTHLY_SPEND_CAP_CENTS` are what keep that bounded, and both live behind the API — the app's
copy of the number is a label, not a control.

---

## 1. Supabase first

The backend derives everything from the project URL, so nothing else can be configured until this
exists.

1. Create the project. Pick the region nearest the Render region (§2) — every query crosses that gap.
2. **Settings → Database → Connection string → URI.** Prefer the **direct** connection on port
   `5432`. The `6543` pooler is transaction mode and does not support prepared statements;
   `PG_DISABLE_PREPARED_STATEMENTS` defaults to `true` so either works, but direct is faster.
3. **Settings → API Keys.** The Project URL becomes `SUPABASE_URL`; the issuer and JWKS endpoint are
   derived from it. The **publishable** key is the app's; the **secret** key (`sb_secret_...`) is the
   backend's and bypasses RLS — it never enters a dart-define.
4. Nothing to run by hand. `store/pool.py` applies its own schema on boot — quota tables, sessions,
   turns, RLS policies — and the LangGraph Postgres checkpointer creates its own tables, so
   interview state survives a restart.

---

## 2. Render

`render.yaml` at the repo root is a blueprint: **New → Blueprint**, point it at the repo, and the
service comes up with `rootDir: api` and the existing multi-stage `uv` Dockerfile. No build command
to get wrong.

Fill the four `sync: false` variables in the dashboard — they are deliberately absent from the
blueprint so secrets never reach git. All four already exist in your local `.env`; copy them across
verbatim:

| Variable | Value |
|---|---|
| `ANTHROPIC_API_KEY` | from the Anthropic console |
| `DATABASE_URL` | the Supabase URI from §1, step 2 |
| `SUPABASE_URL` | the Project URL |
| `SUPABASE_JWT_SECRET` | only if the project still signs HS256; empty with asymmetric keys |

Supabase's **secret** key is not on this list. The backend reads Postgres directly over
`DATABASE_URL` and never calls Supabase's REST API, so `sb_secret_...` is not referenced anywhere in
`api/app/`. Don't set it — an unused secret in a dashboard is just a thing to leak later.

`region: singapore` is the nearest free region to India — change it in the blueprint before the
first deploy, because a Render service cannot be moved between regions afterwards.

`DATABASE_URL` is the one that must not be forgotten. The Dockerfile defaults it to sqlite on a
container path, and the free tier has no persistent disk, so that default means a database that
vanishes on every restart *and* quota enforcement that silently no-ops. The app refuses to boot in
that state: with `SUPABASE_URL` set and `DATABASE_URL` not Postgres, startup raises rather than
coming up unprotected.

`healthCheckPath: /healthz` is wired, and the Dockerfile's `CMD` binds `$PORT`, which Render injects
(10000 by default) rather than the 8000 compose uses.

### Keeping it awake

A free service spins down after 15 minutes idle and takes roughly a minute to wake — a loading page
is the first thing a recruiter would see. One service fits inside the 750 instance-hours a month
(744 hours in the longest month), so running continuously costs nothing.

Point **cron-job.org** or **UptimeRobot** at `https://mettle-api.onrender.com/healthz` every 10
minutes. `/healthz` touches no database and no model, so the ping is free on every axis. Don't use a
GitHub Actions `schedule` for this — it burns Actions minutes and queues unpredictably under load.

---

## 3. GitHub Pages

`.github/workflows/web.yml` builds and deploys on every push to `main` that touches `app/`. Enable
it once at **Settings → Pages → Source → GitHub Actions**.

The four build-time values are repository **variables**, not secrets — **Settings → Secrets and
variables → Actions → Variables**:

| Variable | Value |
|---|---|
| `METTLE_BASE_URL` | `https://mettle-api.onrender.com` |
| `SUPABASE_URL` | the Project URL |
| `SUPABASE_PUBLISHABLE_KEY` | `sb_publishable_...` |
| `GOOGLE_WEB_CLIENT_ID` | the web OAuth client id |

Variables rather than secrets is the honest choice: anything compiled into a web bundle is readable
by anyone who opens devtools. Masking them in CI logs would imply a protection that does not exist.
RLS is what actually guards the data, which is why the secret key is not on this list.

Three things the workflow handles that are easy to miss by hand:

- `--base-href /mettle/`. Pages serves the repo at a subpath; without this the build loads blank.
- `404.html` is a copy of `index.html`. Pages has no SPA fallback, so a refresh on a deep `go_router`
  route would 404.
- `METTLE_BASE_URL` arrives as a dart-define. `ApiConstants.configuredBaseUrl` reads it at compile
  time, so the URL is never hardcoded per environment.

Also add these to Supabase under **Authentication → URL Configuration → Redirect URLs**, or Google
sign-in fails on web only:

```
https://skull94.github.io/mettle/
https://skull94.github.io/mettle/**
```

---

## 4. CORS

`CORS_ORIGINS` is set to `https://skull94.github.io` in the blueprint — origin only, no path and no
trailing slash, which is what the browser sends. Localhost stays allowed through
`LOCAL_ORIGINS` in `main.py`, so development needs no change.

`allow_credentials=False` is correct here: auth is a bearer token in a header, not a cookie.

---

## 5. What the free tier actually costs you

Worth knowing before a demo rather than during one.

| Limit | Consequence |
|---|---|
| 512 MB RAM, <1 CPU | One uvicorn worker. `PG_POOL_MAX` is 5, not 10. |
| Spin-down on idle | Solved by the pinger, but a **deploy** still restarts the process. |
| Restart drops the SSE mailbox | The session resumes from the Postgres checkpointer; the open `EventSource` does not. A client mid-interview must reconnect. |
| One instance only | Required, not just thrifty — `session/bus.py` is process memory. Scaling out needs Redis first. |
| Bandwidth exhaustion | With no card on file the service suspends rather than bills. |

The mailbox restart is the one that shows up in a demo: answering a question just as a deploy lands
leaves the stream hanging. Finishing a deploy before showing the link is the whole mitigation.

For the phase-2 voice interviewer, FastAPI WebSockets work on Render, but 512 MB and a fraction of a
CPU will not carry real-time audio. Budget for a paid instance at that point.

---

## 6. Why these three

Render's free web service needs no card, and one service fits in the monthly instance-hour pool, so
an always-warm backend is genuinely free. Its free Postgres is not — it expires 30 days after
creation — which is why the database is Supabase, where the auth and RLS already live.

Rejected, and why:

| Option | Why not |
|---|---|
| Fly.io | A free plan for personal orgs reportedly returned in November 2026, but it needs a card and has no hard spend cap. Too new to rely on — verify on Fly's own pricing page first. |
| Google Cloud Run | Generous always-free limits, but requires a card, and a budget alert does not cap spending. |
| Railway | ~$1 of monthly credit, about 100 MB of RAM. Too small for LangGraph. |
| Koyeb | Has required a paid plan for new users since February 2026. |
| Hugging Face Spaces | Workable fallback, but sleeps when idle and the repo must be public. |
| Celery worker | A second always-on service, which free tiers handle badly. FastAPI `BackgroundTasks` and plain async LangGraph calls carry this load. Upstash Redis (free, no card) is there if a queue ever becomes necessary. |
