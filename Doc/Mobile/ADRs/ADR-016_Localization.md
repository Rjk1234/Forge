# ADR-016 Localization

Version: 2.0 (ForgeApp — Deferred)

Status: Accepted (Deferred Scope)

---

> **Changelog**
> - **2.0 (2026-09-08):** Reduced to a deferred stub for ForgeApp. All 22 designed screens
>   (SCR-06–SCR-27) and every user story are single-language (English) with no stated i18n
>   requirement — ForgeApp's PRD/SRS does not require i18n readiness. Deferred beyond POC scope.

---

## Context

ForgeApp targets a single local user, single language, single market. None of the user stories or
the SDS mention future-language expansion.

---

## Decision

Localization infrastructure (`flutter_localizations`, ARB files, `context.l10n`) is **deferred
beyond POC scope**. User-facing strings may be plain Dart string literals for now.

If ForgeApp is ever expected to support additional languages, this ADR should be rewritten at that
time following Flutter's standard localization approach — not built speculatively now.

---

## Consequences

### Positive

- No ARB/codegen overhead for a single-language POC

### Negative

- A future localization pass would need to extract every hardcoded string — an accepted,
  deliberate deferral, not an oversight

---

## Related ADRs

* ADR-032 Modularization Strategy
