# Review round 1 — screen design (docs/design set)

Session: same day as round 0. Reviewer: a fresh adversarial agent acting on the
wireframe style guide + render-review reference + the round-2 product brief
(promptQ.md), against the six generated screen scenes.

Scope: geometry itself was already gated by the 720p legibility script (all scenes
pass, glyphs ≥14px, fit ~1.0, no overlaps). The reviewer therefore weighed content,
structure, accessibility-as-designed, and style voice — not pixels.

Verdict: **REJECTED** → 10 findings → all resolved → round 2 **APPROVED**.

## Round 1 findings → round 2 resolutions

| Severity | Scene / element | Finding | Resolution (evidence in round 2) |
| --- | --- | --- | --- |
| major | 01 `v-opt-*` | Overnight GPS verification path missing | `v-opt-night` "Not home? We can / check your spot overnight" added |
| major | 05 vs 06 | Resolve trigger contradicted (accept clears vs "Sue approved") | 06: "You said yes — badge cleared"; "numbers come when she confirms" — acceptance clears badges, OK gates only contacts |
| major | 02 `title` | Invented "2 of 8" counter reversed register order | Counter dropped; order (capabilities→location) now spelled out in design.md |
| minor | 01 `v-quiet` | "until a human checks you" misled about GPS-only verify | → "until your spot is confirmed" |
| minor | 02 tiles | stray blue/yellow read as decoration | all eight tiles grey; green left for Continue |
| minor | 03 `h-strip` | "Available to helpers: on" cryptic | → "Happy to help when called: on" |
| minor | 01 | no forward action after choosing | green "That's my spot" bar added |
| minor | 06 `b-match` | "numbers shown — say hi" privacy jargon | → "numbers come when she confirms" |
| minor | 02/04 `next` | vague "Next" | → "Continue" / "Write the ask" |
| minor | 01/04 | two greens on one screen; catch-all colour inconsistency | verifier opts → blue, CTA stays green; catch-all grey everywhere |

## Round 2 residuals (documented, non-blocking)

- Distance-shared card shows less info than the responder card — an intended privacy
  gradient (noted in design.md).
- "Waiting for Sue's OK" gates contact sharing only — an explicit privacy decision,
  not a spec addition (noted in design.md).

## Gate state after the loop

- `validate_excalidraw.py`: all six scenes OK.
- `review_legibility.py` (720p): zero blockers on all six.
- Renders: every scene has an up-to-date `docs/design/*.png`.
- Round 2 verdict: **APPROVED**.