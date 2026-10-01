# In a Pickle

Neighbour-help for Pringle Bay. A Flutter PWA (and later iOS/Android app) that lets
people ask the village for a hand — or offer one — in plain words and big letters.

Designed to be boring on purpose: one action per screen, ≥18 px text, ≥60 px touch
targets, high contrast, and no gestures that trip up an older neighbour.

## Status

The current prototype now includes a trust-led one-time onboarding, pinned home
address, deterministic at-home location check or captain fallback, capability
questions, staged helper acceptance, requester approval, a route view, and matched
chat. The shared village service and GPS check are still local fakes: they exercise
the complete interaction without pretending the production backend exists.

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
flutter test               # 60 behavioural/widget tests; 10 capture states skipped
flutter analyze
flutter build web --release
./tool/capture_app_states.sh # refresh 13 states in tmp/screenshots/latest/
./tool/review_wireframes.sh  # regenerate, validate, render, and review 11 scenes
```

The screenshot crank uses Flutter's widget renderer at a fixed 390×844 viewport. It
loads Flutter's bundled Roboto and Material Icons during capture, uses no browser or
network map tiles, and replaces the latest PNG set on every run.
