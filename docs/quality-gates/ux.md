# Gate: ux

The measure is a first-time user, over sixty, completing a flow without help.

## Always

- Primary flow (I need help → pickle sent) reachable in ≤ 4 taps and no text walls.
- Words are plain and short; error messages name the missing thing.
- Confirmation is explicit after sending something that affects others
  (e.g. "Your pickle is out. We'll ring you when someone says yes.").
- Nothing that asks for money in this phase.
- Screen copy is tested in widget tests so the words cannot drift.

## Resolved

- `home-verbs` — call-to-action tiles were trimmed from "ask the village for a hand"
  phrasing to imperative first-person buttons: "I need help" / "I can help".
- `offer-state-label` — the availability tile stated the opposite of the state it
  showed. It now reads "You are available to helpers" when on and "Make me available
  to helpers" when off.

## Known deviations

- Helpers/requesters cannot yet match live (no transport); the flow ends at the outbox
  and completion is out of this phase.