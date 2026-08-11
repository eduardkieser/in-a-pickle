# Gate: accessibility

Everything is written for Pringle Bay: older neighbours, tired eyes, ordinary phones.
This gate is the last door before any UI ships.

## Always

- Body text is never smaller than 18 px; primary actions are never smaller than 22 px.
- Touch targets are at least 60 px tall (larger than the 48 px WCAG minimum).
- There is exactly one primary action per screen.
- No gesture-only interactions; every action has a visible button.
- Text and icons never rely on color alone to carry meaning.
- Contrast between text and its background meets WCAG AA.
- Screens do not overflow at large system text scales or short viewports; anything
  tall can scroll.
- Buttons say what they do ("Send the pickle", never an icon without a label).

## Resolved (found in review, now enforced)

- `home overflow` — the home screen overflowed by 18 px in a 600 px-tall viewport,
  the same conditions a boxy phone at 2x text scale produces. Fixed by making the
  whole home scrollable instead of using fixed Expanded flex boxes.
- `category-tile-overflow` — a fixed-aspect-ratio grid made category tiles overflow
  at 2x text and on ~350 px-wide phones. Tiles now size to their content (a Wrap);
  a widget test runs the tile grid at 2x text on a narrow surface and asserts no
  render error.
- `below-18px` — the helper text on the two home CTA tiles (17 px) and category
  tiles (15 px) sat under the 18 px floor. Promoted to 18 px.
- `color-only-selection` — the selected category tile used `white70` on pickle green
  (~3.2:1). Now solid white with a check icon, so selection does not rely on color.

## Known deviations

- None yet.

## Checking

- `flutter test` covers widget layout at the default test size.
- A human should also try the app with system font scale set to 2.0.