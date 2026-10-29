# ForgeApp Mobile Architecture Decision Record Index

This index is the canonical navigation and status log for ForgeApp Mobile ADRs. The ADR file owns
the decision detail; this index owns discovery and approval visibility.

> **Review note:** This ADR set was reviewed on 2026-09-08 against ForgeApp's actual scope — a
> fully offline, single-local-user, Drift-only Flutter workout tracker (POC/MVP scope; see
> `Doc/SDS_v2.0.md`). Roughly half the original ADR set covered concerns ForgeApp does not have
> (network, API, auth/RBAC, QR, GPS, push notifications, photo upload) and has been marked
> **Removed — Not Applicable** rather than deleted from disk (file deletion could not be executed
> directly in this pass — see each removed ADR's own note). A further five ADRs (Crash Reporting,
> Localization, Responsive/tablet Architecture, Accessibility, App Update Strategy) were reduced to
> deferred/reduced-scope stubs, matching this project's "enough, not too much" POC scoping
> principle. Everything else was rewritten in place — same ADR number and topic, ForgeApp-specific
> content.

## Status and Authority

- **Accepted** ADRs are authoritative for their decision scope.
- **Accepted (Deferred Scope)** / **Accepted (Reduced Scope)** ADRs are authoritative that the
  capability is intentionally out of scope for this POC, not merely unwritten.
- **Removed — Not Applicable** ADRs are kept as placeholder files only (pending file deletion) and
  are not part of the active decision set — do not implement against them.

## Active ADR Log

| ADR | Decision | Status |
|---|---|---|
| [ADR-001](ADR-001_Architecture_Style.md) | Architecture Style | Accepted |
| [ADR-002](ADR-002_State_Management.md) | State Management | Accepted |
| [ADR-003](ADR-003_Routing.md) | Routing | Accepted |
| [ADR-004](ADR-004_Dependency_Injection.md) | Dependency Injection | Accepted |
| [ADR-007](ADR-007_Error_Handling.md) | Error Handling | Accepted |
| [ADR-008](ADR-008_Local_Storage.md) | Local Storage | Accepted |
| [ADR-015](ADR-015_Crash_Reporting.md) | Crash Reporting | Accepted (Deferred Scope) |
| [ADR-016](ADR-016_Localization.md) | Localization | Accepted (Deferred Scope) |
| [ADR-020](ADR-020_Logging_Strategy.md) | Logging Strategy | Accepted |
| [ADR-021](ADR-021_Performance_Architecture.md) | Performance Architecture | Accepted |
| [ADR-022](ADR-022_Responsive_Architecture.md) | Responsive Architecture | Accepted (Reduced Scope) |
| [ADR-026](ADR-026_Form_Validation_Strategy.md) | Form Validation Strategy | Accepted |
| [ADR-027](ADR-027_Loading_Empty_Error_States.md) | Loading Empty Error States | Accepted |
| [ADR-028](ADR-028_Accessibility_Strategy.md) | Accessibility Strategy | Accepted (Reduced Scope) |
| [ADR-030](ADR-030_Dependency_Versioning_Governance.md) | Dependency Versioning Governance | Accepted |
| [ADR-031](ADR-031_Path_Provider.md) | Path Provider | Accepted |
| [ADR-032](ADR-032_Modularization_Strategy.md) | Modularization Strategy | Accepted |
| [ADR-033](ADR-033_Environment_Management.md) | Environment Management | Accepted |
| [ADR-036](ADR-036_App_Update_Strategy.md) | App Update Strategy | Accepted (Deferred Scope) |
| [ADR-037](ADR-037_Theme_Architecture.md) | Theme Architecture | Accepted |

## Removed — Not Applicable to ForgeApp

These files remain on disk as placeholders only (pending file deletion) and are excluded from the
active set above. Each file states why it doesn't apply.

| ADR | Decision | Why removed |
|---|---|---|
| [ADR-005](ADR-005_Network_Layer.md) | Network Layer | No backend, no network calls |
| [ADR-006](ADR-006_API_Architecture.md) | API Architecture | No backend API |
| [ADR-009](ADR-009_Secure_Storage.md) | Secure Storage | No secrets to protect |
| [ADR-010](ADR-010_Authentication.md) | Authentication | Static local login only (see SDS Appendix B) |
| [ADR-011](ADR-011_Authorization.md) | Authorization | Single local user, no roles |
| [ADR-012](ADR-012_Deep_Linking.md) | Deep Linking | No external entry points |
| [ADR-013](ADR-013_Notification_Architecture.md) | Notification Architecture | No push notifications |
| [ADR-014](ADR-014_Analytics.md) | Analytics | No backend, no analytics requirement |
| [ADR-017](ADR-017_Security_Architecture.md) | Security Architecture | Covered directly by SDS §7.4/Appendix B |
| [ADR-023](ADR-023_Permission_Strategy.md) | Permission Strategy | No device permissions requested |
| [ADR-024](ADR-024_Cache_And_Data_Refresh.md) | Cache And Data Refresh | The Drift database is the source of truth, not a cache |
| [ADR-025](ADR-025_Offline_And_Network_Connectivity.md) | Offline And Network Connectivity | Fully offline by design, not online-first |
| [ADR-029](ADR-029_Route_Guard_Strategy.md) | Route Guard Strategy | Single app-lock guard, covered in ADR-003 |
| [ADR-034](ADR-034_API_Versioning.md) | API Versioning | No backend API |
| [ADR-035](ADR-035_Image_Loading_And_Caching.md) | Image Loading And Caching | No remote images |
| [ADR-038](ADR-038_QR_Scanner_Strategy.md) | QR Scanner Strategy | No QR scanning |
| [ADR-039](ADR-039_Background_Asset_Upload_And_Retry_Policy.md) | Background Asset Upload & Retry Policy | No media capture/upload |
| [ADR-040](ADR-040_Scoped_Local_Persistence_Policy.md) | Scoped Local Persistence Policy | ADR-008 already allows full persistence |

## Approval Workflow

1. Resolve all decision-level open questions or explicitly move them to feature ownership with a
   testable rule.
2. Validate Related ADR links against this index — a Related ADR reference to a Removed ADR
   number is stale and should be corrected.
3. Record the review date and reviewer in the change history for the ADR set.
4. Change the ADR status and update this log in the same review.

Last reviewed: 2026-09-08 (full review and rewrite against ForgeApp scope, per Doc/SDS_v2.0.md).
