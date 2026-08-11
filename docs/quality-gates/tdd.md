# Gate: tdd

A feature is a red test first, then the smallest implementation that turns it green,
then refactor while the test stays green.

## Always

- Every domain behavior has at least one test.
- A test that fails on purpose must be seen failing before the fix is written.
- Tests are the deliverable's spec; code exists to satisfy them.
- `flutter test` must pass before a feature commit; `flutter analyze` must be clean.
- No test randomly depends on wall-clock state that cannot be frozen.

## Resolved (found in review, now enforced)

- `pickle-message` — the constructor silently accepted a blank message. A red test
  (`a request requires a message`) drove the `ArgumentError` it now throws.
- `outbox-mutation` — the outbox controller mutated shared state without notifying
  listeners; the analyzer flagged the cascade and the fix reassigns state.
- `offer-state-label` — the availability label was inverted, and no test pinned it.
  Corrected and covered by `offer_screen_test.dart`.
- `copy-drift` — the flagship confirmation and the two error strings were untested
  and only the home CTAs were pinned. Added widget tests for the full send flow
  (confirmation + pop) and both validation branches in `new_pickle_screen_test.dart`.

## Known deviations

- `const-stream` — models trim inputs rather than throwing on whitespace; this is a
  deliberate lenient-input policy, verified by tests like `name is trimmed when read`.

## Checking

- `flutter test` (43 tests) and `flutter analyze` run on every change.