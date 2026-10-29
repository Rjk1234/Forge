# ForgeApp — Release Readiness Standards

Operational readiness criteria for calling a ForgeApp build "done" for this POC/MVP assignment,
beyond the code-level Definition of Done in `governance/definition-of-done.md`.

---

## 1. Before Calling a Build "Done"

- All automated quality gates must pass: `fvm flutter analyze` zero issues, `fvm flutter test` all
  green with coverage targets met (`standards/testing-standards.md` §2).
- There is a single build configuration — no environment flavors (development/staging/production)
  to verify (ADR-033: not applicable to ForgeApp).
- There is no force-update mechanism, no remote feature flags, and no backend to point at — none
  of these concepts exist in this app.
- Critical workflows (login, plan → schedule → execute, history/progress/statistics) must be
  manually verified on at least one Android phone and one iPhone (or simulator/emulator
  equivalent). Tablet/iPad and multi-window testing do not apply (ADR-022, reduced scope).
- Store submission is not applicable — this POC/assignment is not distributed through Google Play
  or the Apple App Store.

---

## 2. Runbook Expectations

This is a single-developer, offline POC with no production deployment, no on-call rotation, and no
remote rollback mechanism. A formal runbook is not required. If a defect is found after a "done"
checkpoint, the fix is a normal code change followed by re-running the quality gates in §1 — there
is no separate operational escalation path to define.

---

## 3. Monitoring

There is no crash reporting, performance monitoring, or remote analytics in ForgeApp (ADR-015,
ADR-014 — both deferred/not applicable). Any issue surfaces directly to the developer running the
app locally; there is no production fleet to monitor.

---

## Related Documents

- `governance/definition-of-done.md` — code-level release criteria.
- `standards/testing-standards.md` — quality gates and coverage targets.
- `ADRs/ADR-015_Crash_Reporting.md` (Deferred Scope), `ADRs/ADR-022_Responsive_Architecture.md`
  (Reduced Scope), `ADRs/ADR-033_Environment_Management.md`.

---
