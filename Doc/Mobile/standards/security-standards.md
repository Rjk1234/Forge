# ForgeApp — Local Data & Security Standards

This document defines the client-side data-handling and security responsibilities of ForgeApp.

Since ForgeApp has no backend, there is no split of responsibility between client and server
security — the concerns below are the entirety of ForgeApp's security surface.

---

## 1. Security Principles

- Assume the mobile client is untrusted in the general sense (a POC with a static credential is
  not designed to resist a malicious device owner) — but there are no remote secrets, tokens, or
  backend systems to protect, so this mainly governs local data hygiene.
- Collect only the minimum data required (SDS §7 — profile fields only, no device identifiers, no
  analytics).
- The single local user's own data is the only data in the app — there is nothing to protect
  *from* that user, only accidental loss or corruption to guard against (see §4).

---

## 2. Local Storage & Static Credentials

ForgeApp's static login credential is a **hardcoded demo credential** (SDS Appendix B) — it is not
a real secret and is not treated as one. It must not be stored in Drift as if it were sensitive, and
must not be logged.

All application data — profile, exercise catalogue, workout plans, schedules, workout sessions,
and derived statistics — is stored in Drift with no restriction (ADR-008). Unlike a backend-driven
app, there is no "non-sensitive preferences only" boundary: Drift is ForgeApp's only and complete
data store (SDS-COMP-13 Persistence Boundary).

Prohibited regardless:

- Hardcoded values other than the one documented static demo credential
- Secrets or API keys committed to source control (none currently exist, and none should be added
  without a new ADR justifying a scope change — see `app/platform-requirements.md`)

---

## 3. Authentication & App Lock

ForgeApp uses a static local login check (SDS-COMP-3 / SDS-COMP-15) and an app-lock boundary
(SDS-COMP-14) gating access to the rest of the app. There is no session token, no refresh flow, no
RBAC, and no backend authorization — the entire authentication model is "locked" vs. "unlocked" for
the single local user (ADR-010, ADR-011 — both removed as not applicable; see SDS Appendix B).

---

## 4. Local Data Integrity

Since Drift is the sole and permanent data store (no backend to recover from), the primary local
risk is data loss or corruption, not disclosure:

- Drift read/write failures must surface through the typed failure taxonomy (`ADR-007`,
  SDS-ERR-5/6), never silently drop data.
- There is no cloud backup or sync — if the user asks whether their data is backed up anywhere,
  the honest answer per SDS is no; this is accepted POC scope, not a defect.

---

## 5. Privacy & Data Disclosure

ForgeApp collects only what the user enters directly (display name, fitness goal, experience level,
height, weight, workout data) and stores it exclusively on-device. There is no data transmission,
no analytics, no crash reporting, and no third party with any access to this data — so there is no
applicable privacy regulation, data-safety label, or nutrition-label disclosure to prepare (no
store distribution; see `standards/release-readiness-standards.md`).

| Category | Collected | Purpose | Leaves the device? |
|----------|-----------|---------|---------------------|
| Profile fields | Yes | Personalization only, no calculations | No |
| Workout data (plans, sessions, history) | Yes | Core app function | No |
| Device identifiers | No | — | — |
| Location, camera, contacts | No | — | — |

---

## 6. Secure Coding Checklist

Verify the following during every review:

- [ ] No hardcoded values other than the one documented static demo credential.
- [ ] No profile field values or credential values logged verbatim (ADR-020).
- [ ] Raw Drift exceptions never exposed to the UI — mapped to typed failures (ADR-007).
- [ ] Input validation follows ADR-026 and `standards/coding-standards.md`.
- [ ] No dependency is added that introduces network, file-upload, or remote-storage capability
      without a new ADR (see `app/platform-requirements.md` — Prohibited).

---

## 7. Export Compliance & Encryption

Not applicable — ForgeApp is not distributed through an app store and uses no encryption beyond
whatever the OS/Drift provide by default. No custom cryptography is implemented.

---

## 8. Dependency Security

The governed package set is small and fixed (ADR-030): `flutter_bloc`/`bloc`/`equatable`,
`get_it`, `go_router`, `drift`, `sqlite3_flutter_libs`, `path_provider`, `path`, `build_runner`/`drift_dev`,
`flutter_test`/`bloc_test`/`mocktail`. Any addition — especially anything touching network,
storage encryption, or device permissions — requires a new or amended ADR before adoption.

---

## 9. Security Incident Handling

This is a single-developer local POC with no production users and no remote systems. If a data
integrity or logic defect is found, it is fixed as a normal code change against the quality gates
in `standards/testing-standards.md`; there is no incident-response or user-notification process to
invoke.

---

## Related Documents

- `app/PRODUCT_CONTEXT.md`
- `governance/architecture-boundaries.md`
- `app/platform-requirements.md`
- `standards/coding-standards.md`
- `standards/testing-standards.md`
- `ADRs/ADR-007_Error_Handling.md`, `ADRs/ADR-008_Local_Storage.md`,
  `ADRs/ADR-020_Logging_Strategy.md`, `ADRs/ADR-026_Form_Validation_Strategy.md`,
  `ADRs/ADR-030_Dependency_Versioning_Governance.md`

---
