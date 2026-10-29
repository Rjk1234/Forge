# Feature Specification: SCR-17 Rest Timer

**Feature Branch**: `001-scr-17-rest-timer`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "mobile spec for SCR-17"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View Countdown and Skip Rest (Priority: P1)

After completing a set in the Active Workout (SCR-16), the rest timer screen appears automatically and begins counting down from the configured rest duration. The user can watch the countdown and optionally tap Skip at any time to end the rest period early and proceed immediately to the next set or exercise.

**Why this priority**: This is the entire purpose of the screen. The rest timer auto-starts without user action, which is the defining behaviour from SRS-FR-23. Without this story the screen cannot function at all.

**Independent Test**: Can be tested by starting a workout with a plan that has a configured rest period (restPeriodSec > 0), completing one set that is not the last set of the last exercise, and verifying: (a) the rest timer screen opens automatically, (b) the countdown begins immediately from the configured rest duration, (c) tapping Skip returns to SCR-16 showing the next set before the timer expires, and (d) allowing the timer to reach zero also returns to SCR-16.

**Acceptance Scenarios**:

1. **Given** the user completes a set in SCR-16 that is not the last set of the last exercise, **When** the set is marked complete, **Then** the rest timer screen opens automatically with no user action; the countdown is already running from the configured rest period (`restPeriodSec` seconds) when the screen appears.

2. **Given** the rest timer screen is open and counting down, **When** the user taps Skip, **Then** the timer ends immediately and the user is returned to SCR-16 showing the next set or exercise.

3. **Given** the rest timer screen is open and counting down, **When** the countdown reaches zero, **Then** the screen automatically transitions back to SCR-16 showing the next set or exercise with no user action required.

4. **Given** the exercise's configured rest period is greater than zero, **When** the rest timer screen opens, **Then** the countdown display shows the full rest duration in MM:SS format (e.g., `1:30` for a 90-second rest period); the Skip control is visible and tappable from the first moment.

5. **Given** the rest timer screen is open, **When** the user taps Skip immediately after the screen appears (before any meaningful time has elapsed), **Then** the skip is honoured — the timer ends and SCR-16 is shown immediately.

---

### User Story 2 - Zero Rest Period Bypass (Priority: P2)

When an exercise has a configured rest period of zero seconds, the rest timer screen is bypassed entirely. Completing a set for such an exercise advances directly to the next set or exercise without any timer interstitial.

**Why this priority**: A rest period of zero is a valid configuration — it means no rest is intended between sets. Showing a zero-second rest timer would be confusing and incorrect. This story ensures a clean experience for exercises with no rest, but it depends on US1 (the timer screen must exist before bypassing it can be meaningful).

**Independent Test**: Can be tested by configuring an exercise with `restPeriodSec = 0`, completing a set in SCR-16, and verifying that SCR-17 never appears — SCR-16 advances directly to the next set.

**Acceptance Scenarios**:

1. **Given** the current exercise has `restPeriodSec = 0`, **When** the user completes a set, **Then** the rest timer screen does NOT appear; SCR-16 advances directly to the next set within the exercise, or to the first set of the next exercise.

2. **Given** a plan where some exercises have `restPeriodSec > 0` and others have `restPeriodSec = 0`, **When** the user moves through the workout, **Then** the rest timer appears only after sets from exercises with a non-zero rest period.

---

### Edge Cases

- What happens when the app is backgrounded while the rest timer is counting down? → **DEFERRED**: Whether the timer pauses, continues on wall-clock time, or terminates is an open product decision (SRS-NFR-2A, PD-007). The specification intentionally leaves this undefined; implementation MUST NOT silently default to one behaviour — this decision requires explicit product sign-off before implementation.
- What happens when the OS back gesture is performed on the rest timer screen? → The back gesture MUST be treated identically to tapping Skip — the timer ends and the user is returned to SCR-16 at the next set. The rest timer screen must never be popped without advancing the workout state in SCR-16.
- What happens when the rest timer appears between exercises (the last set of exercise N was just completed)? → Behaviour is identical to between-set rest: the countdown runs from the completed exercise's `restPeriodSec`; Skip or expiry returns to SCR-16 at the first set of the next exercise.
- What happens if the user completes the last set of the last exercise? → The rest timer does NOT appear. Completing that set triggers the Finish flow in SCR-16 (session write and navigation to SCR-19). The rest timer is only shown when a next set or exercise exists.
- What happens if the user rapidly double-taps Skip? → Only the first tap is processed; the screen transition has already begun on the first tap.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The rest timer screen MUST open and begin counting down automatically the moment a set is marked complete in SCR-16 — no user action is required to start the timer.
- **FR-002**: The screen MUST display the remaining rest duration as a visible countdown from the configured `restPeriodSec` value of the just-completed set's exercise. The countdown MUST be formatted as MM:SS (e.g., `1:30` for 90 seconds, `0:45` for 45 seconds, `0:00` when expired).
- **FR-003**: The user MUST be able to tap Skip at any time while the timer is running to end the rest period immediately.
- **FR-004**: When the countdown reaches zero, the screen MUST automatically return to SCR-16 without any user action.
- **FR-005**: Both Skip and timer expiry MUST advance the workout to the correct next position in SCR-16 — the next set within the current exercise, or the first set of the next exercise if all sets of the current exercise are complete.
- **FR-006**: If the current exercise's `restPeriodSec` is zero, the rest timer screen MUST NOT appear; SCR-16 MUST advance directly to the next set or exercise.
- **FR-007**: The OS back gesture on the rest timer screen MUST be treated identically to tapping Skip — it MUST advance the workout state and return to SCR-16; it MUST NOT silently pop the route without advancing state.
- **FR-008**: The rest timer MUST NOT appear after the last set of the last exercise; that completion triggers the Finish flow in SCR-16.
- **FR-009**: The timer state MUST be held in memory only; no timer progress or remaining duration MUST be persisted to local storage.
- **FR-010**: App-backgrounded timer behaviour is **explicitly deferred** (SRS-NFR-2A, PD-007). The implementation MUST NOT define this behaviour without a product decision; see Assumptions.
- **FR-011**: The rest timer screen MUST NOT expose a Pause action. Skip is the sole user control. The workout-level Pause concept (SCR-16) does not extend to SCR-17.

### Key Entities *(include if feature involves data)*

- **Rest Period**: The configured rest duration in seconds (`restPeriodSec: int`) stored on `PlanExercise`. Already loaded into memory in SCR-16 via `WorkoutPlanDetail`. The rest timer reads this value from the in-memory plan; no additional data fetch is required.
- **Timer State**: In-memory only. Comprises the initial duration (`restPeriodSec`), the remaining seconds (counting down), and the running/expired flag. Never persisted.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Every set completion where a next set or exercise exists and `restPeriodSec > 0` causes the rest timer screen to appear automatically — 0% of such completions require a manual tap to open the timer.
- **SC-002**: Skip always transitions the user back to SCR-16 at the correct next set or exercise — 0% of Skip taps leave the user stranded on the rest timer screen or navigate to the wrong position.
- **SC-003**: Timer expiry always auto-advances — 0% of cases result in the timer displaying "0:00" while remaining on screen awaiting user input.
- **SC-004**: Zero-rest-period exercises are never interrupted by the rest timer screen — 0% of `restPeriodSec = 0` set completions show SCR-17.

## Assumptions

- `restPeriodSec` is always a non-negative integer. Negative values are treated as zero (same bypass path as US2).
- The rest period value shown in SCR-17 is taken from the exercise that was just completed — not the upcoming exercise.
- Timer state (remaining seconds) is never persisted. If the app is killed during a rest period, the timer is lost; the user returns to SCR-16 at the next set on relaunch (normal session-recovery is also not supported in this version per SCR-16 spec).
- **App-backgrounded timer behaviour is explicitly deferred** (SRS-NFR-2A, PD-007). The product has not decided whether the timer should: (a) pause and resume when the app returns to foreground, (b) continue counting on wall-clock time and auto-advance if the time has passed, or (c) reset/skip when the app returns. Implementation MUST NOT silently default to any of these options — this open decision must be resolved in a dedicated product review before the backgrounding path is coded. For the initial ship, implementing (a) pause-on-background is the lowest-risk default only if explicitly approved by product.
- SCR-17 is a full screen (not an overlay on SCR-16). It is pushed onto the navigation stack on top of SCR-16; Skip or expiry pops it.
- The rest timer does not carry any concept of "workout paused" state. Skip is the sole user control on SCR-17; there is no Pause button on this screen. If the workout was paused in SCR-16, the user would not have been able to complete a set, and therefore SCR-17 would not have been reachable.
- No audio or haptic cue is specified for timer start, tick, or expiry in this version. If the design spec adds them, they require their own requirements.
- No visual animation beyond the countdown display itself (e.g., circular progress ring) is required at the spec level; visual treatment is a design concern resolved in the SDS/design artifacts.

## Clarifications

### Session 2026-09-23 (speckit-clarify)

- Q: Is the rest timer auto-started or manually started? → A: Auto-started immediately on set completion; no manual tap required (SRS-FR-23).
- Q: Is the timer shown after the final set of the final exercise? → A: No — that completion triggers the Finish flow to SCR-19; the rest timer only appears when a next set or exercise exists.
- Q: What happens when `restPeriodSec = 0`? → A: Bypass — SCR-17 does not appear; SCR-16 advances directly to the next set.
- Q: What is the OS back gesture behaviour on this screen? → A: Treated as Skip — advances workout state and returns to SCR-16; never a silent pop.
- Q: What happens when the app is backgrounded during the rest timer? → A: Deferred (SRS-NFR-2A, PD-007); no implementation default without product sign-off.
- Q: Is a Pause action available on the rest timer screen (SCR-17)? → A: No — SCR-17 exposes Skip only; the workout-level Pause concept does not extend to this screen. (FR-011 added.)
- Q: What format should the countdown display use? → A: MM:SS format (e.g., "1:30" for 90 seconds, "0:45" for 45 seconds). (FR-002 and US1 acceptance scenario 4 updated.)
