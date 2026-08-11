# In a Pickle — product & design brief

Neighborhood assistance for Pringle Bay (Western Cape, South Africa). A small coastal
village with a strong sense of community and a mostly older population. "In a Pickle"
lets neighbours ask for help or volunteer to help, in plain words, on a phone.

## Principles

1. **Boring on purpose.** One action per screen. Buttons say what they do. No gestures.
2. **Large everything.** Minimum 18 pt body text, 28 pt+ buttons, touch targets ≥ 60 px.
   Subtitles echo button labels. Works at system text scale 2.0x.
3. **High contrast.** Ocean navy text on sand/white. A single warm pickle-green accent for
   the primary action. Never rely on color alone.
4. **Low stakes, high safety.** "Asking a neighbour" tone, not a marketplace. Consent
   always explicit: you say when you're available to help; you approve a match before a
   helper can contact you.
5. **Works when the network is spotty.** Pringle Bay has real coverage gaps. Requests are
   queued locally and sync when possible; the UI never blocks on the network.

## Personas

- **Gogo (78)** — a retiree, brand-new smartphone, shaky eyesight, needs a lift to
  the clinic or someone to fetch a script. Wants one giant button: **I need help**.
- **Jan (70)** — sharp, proud, would rather give than ask. Wants one giant button:
  **I can help**.
- **Tara (34)** — works from home, part-time helper, likes that the village app is a
  closed, small circle.

## Core flows

### Onboarding / profile (minimal)
Name (required), address (optional, shown to matched helpers only), short bio
(optional, one sentence). Skip anything except the name. Editable forever from the
Profile screen. No password drama — a simple PIN chosen at setup for now, keychain/PWA
storage.

### I need help (send a pickle)
1. Tap **I need help**.
2. Pick the type in one tap — big tiles: *A lift*, *Shopping*, *Around the house*,
   *Medical*, *Company*, *Pet care*, *Technology*.
3. Say it in one sentence (large text field, example hint). Optional: up to 3 photos.
4. Pick *who*: **Nearby helpers now** (pings people who ticked "I can help")
   → refinement: some privacy-level choice.
5. **Send.** Confirmation on screen: "Your pickle is out. We'll ring you when someone
   says yes."

### A helper says yes
- Helper sees the pickle, taps **I can help**.
- The requester is asked first — **Approve Jan?** big and unambiguous. Requester
  approves once and phone numbers are revealed to both sides. Done.

### I can help (become available)
1. Tap **I can help**.
2. Tick what you can help with (same categories) — saved as your *offer*.
3. Stay available or pause with one toggle. While available, pickles in your chosen
  categories near you arrive as big notification cards.

### Notifications
- System notifications when something needs you. In-app, pickles show as one card per
  request: what + who + a thumbs-up button. Never a wall of text.

## Brand & styling (Pringle Bay)

- **Ocean navy** `#0F3B52` — headings, primary text, trust.
- **Sand** `#F6F1E7` — screen background, warmth.
- **White** cards with generous padding.
- **Pickle green** `#3E7C4F` — the one accent: primary action, "yes".
- **Coral** `#C2544A` — reserved for "Help is delayed" style warnings only.
- Big rounded corners, airy spacing, Excalidraw-style honest UI.

## Scope for this phase (Flutter PWA)

- Profile (name/address/bio) saved locally.
- Category definitions shared across request + offer.
- "I need help" and "I can help" flows with local persistence (queued outbox).
- No real networking yet — the transport layer is behind an interface so real push
  can slot in later without touching the UI.

## Out of scope (later)

- Accounts/backend, App Store distribution, image upload, geofencing that isn't asked
  for, group chats, ratings.