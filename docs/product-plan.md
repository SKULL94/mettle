# Mettle — Product & UI Plan

> An AI mock-interview app for mobile/Flutter technical interviews. You pick a topic, an agent
> interviews you — probing deeper when an answer is thin — and you get a rubric-scored breakdown
> plus progress tracked over time.
>
> **The differentiator is measurement, not chat.** Anything can ask questions. This scores you
> against a rubric and shows the trend.

Conventions this plan is built on: [`../CONVENTIONS.md`](../CONVENTIONS.md)

---

## 1. Platform targets

| Target | Status | Rationale |
|---|---|---|
| **Android** | Primary · fully tested | The artifact that proves mobile Flutter capability |
| **Web** | Primary · public demo | One-click trial for recruiters; converts far better than a repo link |
| **iOS** | Compile-verified in CI only | Development machine is Windows — cannot build or test locally |
| Desktop | Not a target | Cost without payoff |

**iOS honesty rule.** CI runs `flutter build ios --no-codesign`. The README says *"builds for iOS in
CI; not device-tested."* Never claim verified iOS support. The gap is a smaller problem than the
overclaim.

**Web constraints to design around:**

- Build with `flutter build web --wasm`; keep assets minimal.
- A real branded loading state in `index.html` so first paint doesn't look broken.
- FastAPI CORS configured for the Pages origin; HTTPS on both ends.
- **Voice degrades to text on web.** Deliberate platform degradation — not a broken mic button.

---

## 2. Visual direction — calm, dark-first study tool

Low-chroma surfaces, a single accent, and **saturation reserved exclusively for score semantics** so
color always carries meaning. Light theme fully supported; dark is the design origin.

### Palette

```dart
// Dark (design origin)
bg              #0E0E11
surface         #17171C
surfaceElevated #1F1F26
outline         #2E2E38
textPrimary     #EDEDF2
textSecondary   #9A9AA8
textMuted       #6B6B78
accent          #9D8DF1   // soft violet — not default Material indigo
onAccent        #16111F

// Light
bg              #FAFAFC
surface         #FFFFFF
surfaceElevated #F1F1F5
outline         #DEDEE6
textPrimary     #16161C
textSecondary   #5B5B6B
accent          #6D5AE0   // darkened for contrast on light
onAccent        #FFFFFF
```

### Score semantics — the only saturated colors in the app

```dart
weak        0–39    #F87171
developing  40–59   #FB923C
solid       60–79   #FBBF24
strong      80–100  #34D399
```

All four sit at the same lightness level, so the ramp reads as *one scale* rather than four
unrelated colors. This is the kind of detail that distinguishes considered design from picked colors.

### Type

| Role | Font | Size / line | Weight |
|---|---|---|---|
| Display | Inter | 32 / 40 | 600 |
| Headline | Inter | 24 / 32 | 600 |
| Title | Inter | 16 / 24 | 600 |
| Body | Inter | 16 / 24 | 400 |
| Body small | Inter | 14 / 20 | 400 |
| Label (muted caps) | Inter | 12 / 16 | 500, +0.5 tracking |
| **Code** | **JetBrains Mono** | 14 / 22 | 400 |

A monospace face is non-negotiable here — it's a *technical* interview app, so code appears in both
questions and answers.

### Surface language

- Radius: `12` default, `16` cards, `999` pills.
- **No shadows in dark mode.** Shadows are invisible on dark surfaces; a `1px outline` plus a lifted
  surface tone does the work. Light mode uses soft shadows instead.
- Borders carry hierarchy, not elevation overlays.

### Motion budget — two animations, total

1. **Streaming text** — append-only with a blinking block cursor. Animate *the cursor*, not each
   character; per-character animation destroys frame budget for zero perceived gain.
2. **Score ring fill** — 600ms `easeOutCubic`, once, on Scorecard entry.

Everything else uses platform-default transitions. A deliberate two-animation budget reads as design
judgment; animation everywhere reads as a tutorial project.

---

## 3. Navigation map

Three tabs in a `StatefulShellRoute.indexedStack`. The interview is pushed **above** the shell —
no tab bar competing for attention mid-answer.

```
/splash                Splash        initialLocation · bootstraps, then replaces itself
/                      Home        ┐
/progress              Progress    ├─ shell · bottom nav (NavigationRail when ≥840dp)
/settings              Settings    ┘
/session/:id           Interview   ┐ pushed full-screen, outside shell
/session/:id/result    Scorecard   ┘
```

Per conventions: navigate by name, pass **IDs only**, destination bloc fetches its own data.

### No authentication — by design

**There are no auth screens.** No login, signup, password reset, OTP, or social sign-in. Splash →
Home, every launch. This is a deliberate scope decision, and the consequences run all the way down:

- **Identity is device-local.** Sessions and scores live in Drift on the device. There is no account
  to create and nothing to lose by not having one.
- **The API needs no user table, no JWT, no refresh-token flow, no session middleware.** It takes an
  anonymous device id generated on first launch, purely so the backend can scope a LangGraph
  checkpoint thread. That's the whole identity story.
- **Zero friction for a reviewer.** Someone evaluating your portfolio opens the web demo and is
  interviewing within seconds. An auth wall in front of a demo app loses most of its visitors, and
  CRUD-plus-login is the single most commonly submitted portfolio project — skipping it spends your
  time on the parts that actually differentiate.
- **`redirect` stays essentially unused.** Nothing is gated, so there is no auth-guard logic to get
  wrong.

If a future milestone ever wants cross-device sync, it arrives as an *optional* account layered on
top of working local storage — never as a gate in front of it.

### Responsive strategy

Two breakpoints, one `AdaptiveScaffold` wrapper. Individual screens never solve responsiveness
themselves.

| Breakpoint | Nav | Layout |
|---|---|---|
| Compact `<600` | Bottom nav | Single column |
| Expanded `≥840` | NavigationRail | Two-pane where content justifies it |

Two-pane matters most on **Interview**: transcript left, live rubric right. Same widgets, different
`Scaffold` body — which is exactly the "one codebase, many form factors" argument you want to be
able to make out loud in an interview.

---

## 4. Screens

### M1 — the complete loop

#### `Splash` — `/splash`

The app's `initialLocation`. It does real bootstrap work, then replaces itself with Home.

- Wordmark + accent glyph, centered on `bg`, no spinner
- Runs in parallel: `configureDependencies()`, open the Drift database, read theme preference, read
  API base URL, generate-or-load the anonymous device id
- On completion: `context.go(AppRoutes.home)` — `go`, not `push`, so splash leaves the stack and
  back-from-Home exits the app

| State | Design |
|---|---|
| Bootstrapping | Wordmark only. Typically 100–300ms; no spinner at that duration |
| Error | Rare, local-only failures (corrupt DB). Inline message + `Retry`, never a dead end |
| Done | Replaces itself with `/` |

**No artificial delay.** A timed splash that waits to look impressive is a tell — real work or
nothing. Pair it with `flutter_native_splash` using the same `#0E0E11` ground so Android cold start
goes native-splash → Flutter-splash → Home with no white flash between.

*Proves:* correct async bootstrap ordering, DI composition root, and that you know `go` from `push`.

#### `Home` — `/`

Entry point and the screen most likely to be screenshotted.

- Average-score ring + 7-session sparkline (custom-painted)
- `▸ Start session` primary CTA
- Recent sessions list → tap into past Scorecard
- Weak-topic chips → start a targeted session

| State | Design |
|---|---|
| Loading | Skeleton stat card + 3 skeleton rows |
| Empty | Designed first-run state: what a session does, single CTA, dashes in the stat card |
| Error | **Never a full-screen error.** Cached sessions from Drift render; a dismissible banner reports the sync failure |
| Loaded | Full dashboard |

*Proves:* dashboard composition, `CustomPainter`, offline-first reads, designed empty states.

#### `Session setup` — modal bottom sheet, not a route

Topic area · question count (3/5/10) · text or voice. Submit disabled until valid. A `DEMO MODE`
chip appears when no backend is configured.

*Proves:* restraint. Not every choice deserves a screen.

#### `Interview` — `/session/:id`

The screen that sells the project.

```
┌────────────────────────────────────┐  compact
│ ←            Q 3 of 5          ⋯  │
│ ━━━━━━━━━━━━━━━━░░░░░░░░░░░░░░░░  │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ ↳ FOLLOW-UP            depth   │ │ ← the agent chose to probe
│ │ You mentioned keys — what      │ │   instead of advancing.
│ │ actually breaks without a      │ │   The graph, made visible.
│ │ ValueKey in a reorderable▊     │ │ ← streaming
│ └────────────────────────────────┘ │
│                                    │
│   your previous answer (dimmed)    │
│                                    │
│ ┌────────────────────────────────┐ │
│ │ Type your answer…         🎤  │ │
│ └────────────────────────────────┘ │
│        Skip            Submit      │
└────────────────────────────────────┘
```

| State | Design |
|---|---|
| Connecting | Skeleton question bubble, "Preparing your interview…" |
| Streaming | Partial text + block cursor; input disabled |
| Awaiting answer | Input enabled and focused |
| Submitting | Input locked, inline spinner on Submit |
| Error | **Inline retry on the failed turn — transcript preserved.** Dropping the transcript into a full-screen error would be the cardinal sin of this screen |
| Complete | Auto-advance to Scorecard |

**The `↳ FOLLOW-UP / depth` badge is the single most important UI element in the project.** It is the
visible evidence that a stateful graph made a routing decision. Without it, this is a ChatGPT
wrapper; with it, the architecture is on screen.

*Proves:* SSE streaming with cancellation, perceived-performance care, graph decisions surfaced in UI.

#### `Scorecard` — `/session/:id/result`

- Overall score ring (animated fill)
- Rubric bars: correctness · depth · clarity · structure
- Per-question accordion: your answer, what was missing, a model answer
- `Practice weak topics` CTA closing the loop back to Home

| State | Design |
|---|---|
| Loading | Ring skeleton + rubric row skeletons |
| Loaded | Full breakdown |
| Error | Retry; the session is already persisted locally so nothing is lost |

*Proves:* data visualization, and that measurement — not chat — is the product.

### M2 — depth

- **`Progress` `/progress`** — score trend across sessions, per-topic mastery, question coverage.
  *Proves:* charting, aggregation, offline reads.
- **`History`** — past sessions list, reusing `Scorecard`. Nearly free.
- **`Settings` `/settings`** — theme, **API base URL**, demo-mode toggle, clear data. A configurable
  endpoint lets a reviewer point your app at their own backend — a genuinely thoughtful touch.
- **Voice answers** — record + waveform `CustomPainter` + STT on Android; text fallback on web.

### M3 — differentiation

- **Role & target setup** — role, seniority, and an optional pasted job description that feeds the
  agent's question generation. This lives as a section in `Settings`, reachable from an editable
  `Flutter · Senior` chip on Home. It is **not** a gated first-run screen: there are sensible
  defaults from launch, and tuning them is an optional improvement rather than a toll booth.
- Session resume via LangGraph checkpointer.
- Human-in-the-loop: "ask me that again."

---

## 5. UI build order

Deliberately tokens-first. Retrofitting theming or dark mode costs roughly 10× more than building
both from the start.

1. `core/constants/` — colors, dimens, strings.
2. `core/theme/app_theme.dart` — `light()` + `dark()` from one seed. **Both, before any screen.**
3. `core/widgets/` — `AdaptiveScaffold`, `AppButton`, `SkeletonBox`, `ScoreRing`, `Sparkline`.
4. `core/router/` + `Splash` — routing skeleton and composition root, so navigation works end to end
   before any screen has content.
5. `Home` with all four states, wired to fakes.
6. `Session setup` sheet.
7. `Interview` with all six states, wired to fakes.
8. `Scorecard` with all three states, wired to fakes.
9. Replace fakes with real blocs → use cases → repository.

Building every screen against fakes first means the entire UI — including its error and empty
states — is complete and golden-tested before the API exists.

---

## 6. Quality gates

**State matrices are structural, not disciplinary.** Every screen's states above map 1:1 onto the
sealed bloc states from the conventions doc, so an unhandled state is a compile error rather than a
forgotten branch. Most portfolio apps ship only the loaded state, and it is immediately obvious to
anyone who opens them.

**Skeletons, never spinners.** A centered `CircularProgressIndicator` is the most common tell of an
unpolished Flutter app.

**Goldens are the cheap win.** 4 screens × {light, dark} × {compact, expanded} = 16 golden tests
from one small helper. Disproportionate visual coverage for an afternoon.

**Accessibility as a hard gate:**

- Semantic labels on every icon-only button
- 48dp minimum touch targets
- Layouts survive text scaling to 1.3× without clipping
- Score is never communicated by color alone — always paired with a number or label

---

## 7. Milestones

| | Scope | Proves |
|---|---|---|
| **M1** · wk 1 | Splash · Home · setup sheet · Interview · Scorecard. Text only, no auth. Keyless demo mode. End-to-end. | It's real and it runs |
| **M2** · wk 2 | Voice + waveform, Progress charts, History, Settings, offline via Drift | Flutter depth |
| **M3** · wk 3 | Rubric evaluation, onboarding + JD input, checkpointer resume, human-in-the-loop, deployed web build | Agent depth + a live link |

Each milestone ships as a tagged release with a changelog entry. `v0.1.0 → v0.3.0` reads as
*shipped*; 200 commits and no releases reads as *tinkering*.
