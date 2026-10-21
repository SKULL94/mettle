# Phase 1 UI review: Stitch mockups vs. scope

Reference: `docs/product-plan.md` (screens), `CONVENTIONS.md`, README "Phase 1 scope".
Reviewed: Stitch Home, Session setup sheet, Scorecard. Interview and Splash have not been generated yet; their section is the spec to generate against.

Legend: **KEEP** build as shown. **MODIFY** keep the element, change content or style. **REPLACE** swap for something else. **REMOVE** do not build in Phase 1. **ADD** missing from the mockup.

---

## Global rules (apply to every screen)

| Item | Action |
|---|---|
| Seniority/level language: "L6", "Staff", "Tech Lead", "Staff Bar", "Staff Cutoff", "Delta", "Calibration" | **REMOVE.** No leveling in Phase 1 (optional role setup is M3). |
| Profile avatar (top right) | **REMOVE.** No accounts in v1. |
| "SYS.READY" status chip | **REPLACE** with the `DEMO MODE` chip (`AppStrings.demoMode`), shown only when no backend is configured. |
| Serif font on small text and captions | **REPLACE** with Inter. JetBrains Mono only for code. |
| Text smaller than 12 sp | **MODIFY** to 12 sp minimum. |
| Wording "probes" | **REPLACE** with "questions". "Follow-up" is the only probing term. |
| Topic names outside the seven in `InterviewTopic` | **REPLACE** with: State Management, Widget Lifecycle, Keys, Async & Isolates, Performance, Navigation, Testing. |
| Score labels | One mapping everywhere: 0-39 weak, 40-59 developing, 60-79 solid, 80-100 strong. A 1-5 dimension score maps to score x 20. |
| Score shown by color alone | **MODIFY.** Always a number or label too. |
| States | **ADD.** Every screen needs loading (skeleton), empty, error, loaded. Mockups only show loaded. |

---

## 1. Splash `/splash`  (not generated)

Spec to generate: wordmark plus accent glyph centered on the dark background (#0E0E11). No spinner, no artificial delay, no tagline.

| State | Design |
|---|---|
| Bootstrapping | Wordmark only (usually 100-300 ms) |
| Error | Inline message plus Retry button |
| Done | Navigates to Home with `go` (not `push`) |

---

## 2. Home `/`

| Stitch element | Action |
|---|---|
| Wordmark "Mettle" | KEEP |
| Eyebrow "FLUTTER L6 STAFF CALIBRATION" | REMOVE |
| Title "Practice Dashboard" | KEEP |
| "SYS.READY" chip | REPLACE with DEMO MODE chip |
| "L6 / Tech Lead" label | REMOVE |
| Avatar | REMOVE |
| Card title "CALIBRATION MATRIX" | MODIFY to "Your progress" (or remove the title) |
| "+14 pts this week" | REMOVE unless computed from stored sessions |
| Score ring "72 SOLID", "Average Score (7 sessions)" | KEEP |
| 7-session sparkline | KEEP |
| Dashed "Staff Bar (80)" line | REMOVE |
| "S-1: 58" and "Latest: 72" | MODIFY: keep only if derived from stored sessions, otherwise remove |
| "Start session" button | KEEP |
| "Weak topics" plus "Needs attention (3)" pill | KEEP title; the pill is optional |
| "Tap to drill" | REMOVE (optional hint) |
| Chip "Platform Channels & FFI 38" | REPLACE with a topic from the seven |
| Chips "Async & Streams 48", "Performance 55" | MODIFY names to Async & Isolates, Performance. Keep the score and color. |
| Recent sessions list, "View all" | KEEP list; REMOVE "View all" (History is M2) |
| Topic names "Custom Render Obj...", "Concurrency & Isolates" | REPLACE with the seven topics. Do not truncate topic names. |
| "5 probes · 18 min" | MODIFY to "5 questions"; show duration only if timestamps are stored |
| Score pills "82 STRONG", "56 DEVELOPING", "71 SOLID" | KEEP |
| Bottom nav Home / Progress / Settings | KEEP (Progress and Settings are M2 stubs) |

States to ADD: skeleton (stat card plus 3 skeleton rows); empty first-run (dashes in the ring card, one-line explanation of what a session does, single Start button, no recent list); error (cached sessions still render plus a dismissible banner, never full-screen).

---

## 3. Session setup (modal bottom sheet)

| Stitch element | Action |
|---|---|
| Sheet with drag handle, title "New session", close (X) | KEEP |
| "DEMO MODE" chip beside the title | KEEP (shown only when no backend) |
| "SELECT TOPIC" label and topic chips | KEEP; REPLACE topics with the seven |
| "Architecture" chip | REPLACE (not in `InterviewTopic`) |
| Orange dot on "Async & Streams", "Performance" | MODIFY: add a small "weak" label or legend; color alone is not enough |
| Question count 3 / 5 / 10 | KEEP |
| "~10 / ~18 / ~35 min" captions | KEEP as fixed estimates; use Inter, not serif |
| "RESPONSE MODE" Text / Voice toggle | REMOVE (voice is M2). Optionally show Voice disabled with "Soon". |
| "Start interview" button | KEEP; disabled until a topic is selected |
| Footer "Selected: State Management • 5 probes" | MODIFY to "5 questions" |
| Selected-state styling | MODIFY: one style for all selectable controls (currently outline, fill and dark fill are mixed) |
| Blurred background still showing L6 text | MODIFY after Home is regenerated |

Data requirement: each topic needs at least 10 written questions, or a 10-question session repeats questions (the current question bank has 2-3 per topic).

---

## 4. Interview `/session/:id`  (not generated)

Spec to generate (no bottom nav; pushed above the shell):

- Top bar: back arrow, centered "Q 3 of 5", overflow menu. Thin progress bar below it.
- Question card with a `↳ FOLLOW-UP` badge and a "depth" label, shown only when the agent probes instead of advancing. This badge is the most important element on the screen. The question streams in with a blinking block cursor.
- The user's previous answer below the card, dimmed.
- Answer input ("Type your answer..."), no microphone icon. "Skip" text button, "Submit" filled button.
- The first question of a session must never read as a follow-up ("You mentioned...").

| State | Design |
|---|---|
| Connecting | Skeleton question card, "Preparing your interview..." |
| Streaming | Partial text plus cursor, input disabled |
| Awaiting answer | Input enabled and focused |
| Submitting | Input locked, inline spinner on Submit |
| Error | Inline retry on the failed turn; the transcript is preserved (never a full-screen error) |
| Complete | Auto-advance to Scorecard |

Expanded layout (>= 840 dp): two panes, transcript on the left and live rubric on the right.

---

## 5. Scorecard `/session/:id/result`

| Stitch element | Action |
|---|---|
| Back arrow, title "Assessment Scorecard" | KEEP |
| Share icon | REMOVE |
| Overflow menu | REMOVE unless it has an action |
| Avatar | REMOVE |
| Chip "FLUTTER ARCHITECTURE & STATE" | REPLACE with the session's actual topic (one of the seven) |
| "Just Now" chip | MODIFY to the session date |
| "5 Questions · 14m 20s" | KEEP questions; show duration only if stored |
| "L6 CALIBRATION" | REMOVE |
| Score ring "68 /100 SOLID" | KEEP; MODIFY so 68 is computed (see rule below) |
| "Staff Cutoff: 80" and "Delta: -12 pts" | REMOVE |
| "Evaluator Note" paragraph | MODIFY: templated sentence from the strongest and weakest dimension (no free-form AI prose in Phase 1) |
| "Rubric Dimensions" card, "L6 STAFF BAR" tag | KEEP card; REMOVE the tag |
| Four rubric bars with score, label and one-line description | KEEP. Descriptions are static rubric text. |
| "Question Audit (5)", "COLLAPSE ALL" | KEEP |
| Per-question accordion rows with score pill | KEEP |
| Expanded Q1: QUESTION PROMPT, YOUR ANSWER, GAP ANALYSIS, MODEL ARCHITECTURE, Model Note | KEEP structure; rename "EVALUATOR GAP ANALYSIS" to "What was missing" and "MODEL ARCHITECTURE" to "Model answer" |
| Q1 prompt "You mentioned keys..." shown as question 1 | MODIFY: a follow-up should be labeled FOLLOW-UP and sit under its parent question |
| Code block clipped on the right | MODIFY: horizontal scroll, JetBrains Mono, never clip |
| Sticky "Practice Weak Topics (Element Lifecycle)" button | KEEP; MODIFY the topic name to one of the seven |
| "Review Full Transcript" link | REMOVE |
| "Export Scorecard (.pdf)" link | REMOVE |

Scoring rule: overall score = average of the four dimension scores x 20, computed in one place. The mockup shows 4, 2, 4, 3 (average 3.25 = 65) but an overall of 68; the real number must follow the formula.

Content requirement: "what was missing" and "model answer" text must be authored in the question bank; the scripted provider only returns missed keywords.

| State | Design |
|---|---|
| Loading | Ring skeleton plus rubric row skeletons |
| Loaded | As above |
| Error | Retry; the session is already stored locally |

---

## 6. Progress and Settings tabs

Out of scope for Phase 1 (M2). Keep the bottom-nav entries and render a simple "Coming soon" stub page. Do not design them yet.

---

## Order of work

1. Regenerate Home and Setup in Stitch with the REMOVE/REPLACE items applied; generate the Home empty and loading states.
2. Generate Interview with the FOLLOW-UP badge and the streaming state.
3. Regenerate Scorecard with the cuts applied.
4. Export dark and light PNG plus HTML for each into `docs/design/reference/`.