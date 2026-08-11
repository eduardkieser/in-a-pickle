# Skill improvement system

A lightweight adversarial review loop that doubles as a quality gate. Every piece of
work produced for In a Pickle (designs, code, docs, ADRs) goes through critique by a
strict reviewer agent before it is accepted. The review output is captured as evidence
and fed back into the gate definitions, so the gates themselves get smarter over time.

## Why

- Two independent models/sessions: an *author* and an *adversary*. The adversary is
  deliberately not cooperative — it looks for holes, not praise.
- A pass/fail *gate* that has to be satisfied explicitly. No "looks good to me".
- A *regression trail*: each round's findings and the fixes that resolved them are
  recorded. Future rounds reuse those lessons instead of relearning them.

## The loop

1. **Author produces work.** A unit of work (wireframe, feature, refactor, document).
2. **Submit to gate.** The work is handed to the adversary with a checklist for the
   relevant persona.
3. **Adversary critiques.** Structured findings: severity, location, rationale,
   suggested fix. Findings must be concrete — "unclear" is not a finding.
4. **Pass gate?**
   - *Yes* → approve & ship.
   - *No* → return to author with findings; author revises and resubmits.
   - Hard cap on rounds (default 3) so the loop cannot spin forever; after the cap a
     human decides.
5. **Distill lessons.** Resolved findings become cards in the gate's regression suite.
   Unresolved-but-ignored findings become "known deviations" tracked as debts.

## Gate personas

Each review run chooses one or more personas. The persona defines the stakes.

| Persona | Watches for | Example checks |
| --- | --- | --- |
| The Skeptic | Logical holes, edge cases, unverified claims | False-friend UI states, offline behavior, error paths |
| The Accessibility Advocate | Usability for older, less technical users | Text ≥18px, ≥48px touch targets, high contrast, one action per screen |
| The Security Auditor | Secrets, injection, unsafe defaults | No keys in repo, no PII logged, safe URL/scheme handling |
| The UX Critic | Flow coherence against real user need | Can a first-time user finish the primary flow in <4 taps? |
| The TDD Enforcer | Test discipline | Red test written first, failing on broken impl, passing on fix |

## Regression suite

Every gate ships a `docs/quality-gates/<gate>.md` with:

- An `always` section of immutable checks.
- A `resolved` section of past findings — each one a mini test case ("a label that
  says Send on a request that is actually one-way was rejected; now confirmed").
- A `known deviations` section of consciously accepted trade-offs.

The suite is the *skill improvement mechanism*: it converts one-off opinions into
reusable, checked knowledge.

## Quality gates in this project

| Gate | Applies to | Trigger |
| --- | --- | --- |
| `skill-system` gate | docs, diagrams | push to `main` |
| `tdd` gate | feature code | before commit of a feature |
| `accessibility` gate | UI | before release build |
| `security` gate | any PR | before merge |

## Adversary workflow (how to run one)

1. Author finishes work and writes `docs/reviews/round-N-<topic>.md` describing the
   intent, the acceptance criteria, and what the author believes is done.
2. A fresh reviewer session loads the relevant `docs/quality-gates/<gate>.md`, the
   work, and the context. It must reply with `APPROVED` or `REJECTED`, findings only
   allowed under REJECTED.
3. REJECTED → author revises → repeat. APPROVED → gate passes.
4. Review round log and outcome appended to `docs/reviews/`.

## Guardrails

- Findings must be specific and actionable; energy must go into the work, not the meta.
- The reviewer may not fix; it may only critique. Author stays single-owner.
- Evidence (test names, line numbers, diagram ids) is mandatory in findings.
- If the review disagrees with resolve, escalate to a human rather than override.