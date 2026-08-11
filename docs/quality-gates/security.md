# Gate: security

A neighbor-help app stores minimal personal data. The bar is "little data, kept where
the user expects, never logged".

## Always

- No secrets, tokens, or keys in the repository. Anything like a key is an env/secret.
- Phone numbers and addresses are never logged, and never leave the app except to a
  matched helper.
- Personal data is stored locally on-device by default; the design brief keeps the
  social graph local for now.
- JSON decoding of stored data fails loudly on unknown shapes rather than silently
  presenting corrupt state.
- No networking stack assumed: the transport is an interface (`PickleTransport`) so a
  backend can be added behind a review gate, not by reaching across the UI layer.

## Resolved

- `pickle-fromjson` — parsing a pickle with an unknown category id now throws
  `ArgumentError` (tested) instead of presenting a broken request.
- `loud-json` — the same decoder still fabricated a fresh id, `DateTime.now()` and
  default audience/status from missing or corrupt fields, silently rewriting outbox
  history. It now throws on any missing/malformed required field (id, message,
  created time, audience, status) — all tested in `pickle_request_test.dart`.
- `offer-json` — `Offer.fromJson` silently dropped malformed and unknown category
  ids. It now throws on a non-string or unknown id (tested in `offer_test.dart`).

## Known deviations

- Pins and passwords do not exist yet; distribution and accounts are explicitly out of
  scope for this phase, tracked in `docs/app-design.md`.