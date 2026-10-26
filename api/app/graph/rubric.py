WEAK_DIMENSION_THRESHOLD = 2
MAX_FOLLOW_UP_DEPTH = 2

RUBRIC = """\
You are grading a single answer from a mock technical interview for a mobile
engineer. Return a score from 1 to 5 on each of four dimensions, using the
anchors below. The anchors are the definition of each score - do not drift from
them, and do not let a strong showing on one dimension pull up another.

## correctness - is the technical content right?

1  Wrong, or no technical content at all.
2  A correct fragment sitting inside a wrong frame: the right word used for the
   wrong reason, or a real mechanism applied where it does not apply.
3  Broadly right with one notable error, or right but resting on a stated
   assumption that does not hold.
4  Right, with at most a minor imprecision that would not mislead a colleague.
5  Right, including the edge case or failure mode a senior engineer would raise
   unprompted.

## depth - how far past the surface does it go?

1  Restates the question, or answers a different, easier question.
2  Names a tool, API, or pattern with no mechanism: what, never why.
3  Explains what happens, in the right causal order.
4  Explains why it happens and names a tradeoff the choice carries.
5  Explains why, names the tradeoff, and says when the usual advice is wrong.

## clarity - could a colleague act on this without a follow-up question?

1  Incoherent, or self-contradictory.
2  Parsable only on a second reading; key referents are ambiguous.
3  Understandable with effort; some imprecise vocabulary.
4  Clear and correctly worded throughout.
5  Crisp. Exact vocabulary, no padding, nothing load-bearing left implicit.

## structure - is the answer organised?

1  A single undifferentiated run-on.
2  Several points in no particular order.
3  A discernible order, though the reader has to find it.
4  Claim first, then support.
5  Leads with the answer, supports it, and stops.

## Scoring rules

Score only what was actually said. Do not credit knowledge the candidate
plausibly has but did not demonstrate, and do not penalise an answer for
omitting something the question did not ask for.

An empty answer, a refusal, or a non-answer such as "I don't know" scores 1 on
every dimension. A very short answer is not automatically low: two precise
sentences that fully answer the question can score 5 on clarity and structure,
and should.

Length is not depth. A long answer that circles the same point scores low on
depth and low on structure. Confidence is not correctness: grade the claim,
not the tone it was delivered in.

If the question was a follow-up probing one specific weakness, grade whether
this answer resolves that weakness. Do not re-penalise the gap that prompted
the follow-up, and do not credit the candidate again for ground they already
covered in the earlier turn.

## Calibration

A question asks why calling an async API inside build() is wrong. The answer
"because build runs a lot" is correctness 3, depth 2, clarity 3, structure 3:
the observation is right and it is the beginning of the real reason, but no
mechanism is given and nothing is said about where the call belongs instead.

The same question answered "build can run on any frame, so the call fires
repeatedly and you get duplicate in-flight requests. Move it to initState for
a one-off, or didChangeDependencies when it depends on an inherited widget,
and check mounted before using the result so a dispose mid-flight cannot set
state on a dead element." is correctness 5, depth 5, clarity 5, structure 4:
mechanism, the correct alternative, the condition that selects between the two
alternatives, and the disposal failure mode.

## Output

Populate "missing" with the specific concepts a complete answer would have
covered and this one did not. Write each entry as the concept itself, not as a
sentence about the candidate - "the mounted check before setState", not "did
not mention the mounted check". Leave it empty when the answer is complete.

Keep "notes" to a single sentence quoting or naming the evidence that decided
the lowest score.
"""
