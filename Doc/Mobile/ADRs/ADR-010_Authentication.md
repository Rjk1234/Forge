# ADR-010 Authentication

Version: 2.0 (ForgeApp — Removed)

Status: Removed — Not Applicable to ForgeApp

---

> **Changelog**
> - **2.0 (2026-09-08):** Removed for ForgeApp. This ADR's decision solves a problem ForgeApp does
>   not have. ForgeApp's login is a static local credential check, fully specified in SDS §4/§5 (SDS-COMP-2, SDS-COMP-15) and `Doc/UserStories/SCR-03-Login-Authenticate.md`. There is no OTP, biometric auth, or backend authentication to architect — this ADR's decision space does not exist for this app.
>   This file is kept as a placeholder (rather than deleted from disk) because the toolchain used
>   to update these docs could not delete files directly in this pass — delete this file the next
>   time you have local file access; see `ADRs/README.md` for the up-to-date index, which already
>   excludes this ADR number from the active set.

---

## Why this ADR does not apply to ForgeApp

ForgeApp's login is a static local credential check, fully specified in SDS §4/§5 (SDS-COMP-2, SDS-COMP-15) and `Doc/UserStories/SCR-03-Login-Authenticate.md`. There is no OTP, biometric auth, or backend authentication to architect — this ADR's decision space does not exist for this app.

See `Doc/SDS_v2.0.md` (System Design Specification) for ForgeApp's actual architecture, and
`ADRs/README.md` for the current active ADR index.
