# In a Pickle

Neighbour-help for Pringle Bay. A Flutter PWA (and later iOS/Android app) that lets
people ask the village for a hand — or offer one — in plain words and big letters.

Designed to be boring on purpose: one action per screen, ≥18 px text, ≥60 px touch
targets, high contrast, and no gestures that trip up an older neighbour.

## Status

First increment: minimal profile (name / optional address / bio), the "I need help"
and "I can help" flows with local persistence (a queued outbox). No accounts or real
matching yet — the transport is an interface (`PickleTransport`) so a backend can slot
in behind a quality gate later.

## Product

- `docs/app-design.md` — the brief and brand (ocean navy / sand / pickle green).
- `docs/app-core-flows.excalidraw`, `docs/app-home-wireframe.excalidraw` — wireframes
  (open in excalidraw.com).

## Process (the part this repo is for)

This project runs an adversarial review loop with quality gates:

- `docs/skill-system.md` — how the loop works.
- `docs/quality-gates/` — one gate per concern; each keeps a regression list of past
  findings so the gates get smarter.
- `docs/reviews/` — the review log.

## Run

```sh
flutter pub get
flutter run -d chrome      # PWA
flutter test               # 55 tests
flutter analyze
flutter build web --release
```
