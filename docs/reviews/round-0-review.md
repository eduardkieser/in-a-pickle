# Review round 0 — In a Pickle baseline

Date: 2026-08-11 (session). Reviewer: a fresh adversarial agent acting as
Skeptic + Accessibility Advocate + TDD/Security Enforcer against the four gates in
`docs/quality-gates/`.

Verdict: **REJECTED** → all findings addressed → now passes.

## Findings and resolutions

| # | Severity | Finding | Resolution | Evidence |
| --- | --- | --- | --- | --- |
| 1 | blocker | Offer availability label inverted (consent-state lie) | Swapped; pinned by widget test | `offer_screen_test.dart` |
| 2 | blocker | Category tiles overflowed at 2x text / narrow phones | Content-sized Wrap instead of fixed grid | `new_pickle_screen_test.dart` (2x narrow test) |
| 3 | major | `PickleRequest.fromJson` fabricated data from corrupt JSON | Throws on any missing/malformed required field | `pickle_request_test.dart` |
| 4 | major | Confirmation + error copy unpinned (how #1 slipped) | Widget tests for send flow + both validation branches | `new_pickle_screen_test.dart` |
| 5 | minor | Sub-18px text on primary CTAs/tiles | Raised to 18px | `home_screen.dart`, `new_pickle_screen.dart` |
| 6 | minor | `white70` selection below AA contrast | Solid white + check icon | `new_pickle_screen.dart` |
| 7 | minor | `Profile.copyWith` broken and dead | Deleted | `profile.dart` |
| 8 | minor | Async load could clobber fresh profile edits | Watch provider + dirty flag | `profile_screen.dart` |
| 9 | minor | Stock web branding (title, manifest, theme) | Branded navy/sand "In a Pickle" | `web/index.html`, `web/manifest.json` |
| 10 | minor | `Offer.fromJson` silently dropped bad ids | Throws on non-string/unknown id | `offer_test.dart` |

## Gate status after fixes

- `flutter analyze`: clean.
- `flutter test`: 55 pass, 0 fail.
- `flutter build web`: builds.
- Resolutions recorded in each gate's "Resolved" regression list.

## What held up

- Docs' resolved regressions were real and tested; the CTAs, confirmation copy, and
  category catalog are product-flavoured; no secrets/PII; clean transport seam.