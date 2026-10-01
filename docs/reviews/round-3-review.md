# Round 3 adversarial review — onboarding and active help

## First pass

The five new Excalidraw scenes (`design-07` through `design-11`) were approved, and
the connector audit confirmed that scene 05's four arrows use actual boundary ports
with the declared 10 px gaps.

The ten-state app set was rejected for one blocker: the trust screen said an exact
address appeared when a helper accepted, while the later screens correctly withheld
it until the requester approved that helper. Minor findings also asked for a clear
pre-approval chat rule and screenshot coverage for captain fallback, capabilities,
and the completed home state.

The reviewer also found two older scene assumptions that no longer belonged in the
current specification: silent overnight location tracking and exchanging phone
numbers after approval.

## Corrections

- Trust copy now says the address appears only after requester approval.
- Waiting helpers may use in-app chat while the address remains hidden.
- Screenshot states 11–13 cover captain fallback, capability questions, and home.
- Scene 01 uses a deliberate return-later check, never passive tracking.
- Scene 06 hides the address until approval and promises an in-app route, not phone
  numbers.
- Documentation describes the same privacy boundary.

## Second pass

**APPROVED** — complete 13-screenshot app set and complete 11-scene specification.
All scenes pass structural validation and the 1280×720 geometric legibility gate;
the human/vision review found no remaining acceptance blocker.

Non-blocking follow-up for production: the map is illustrative, a capability-bottom
screenshot would add scroll coverage, and any requester-side live helper location
needs explicit consent and state semantics.
