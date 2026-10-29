# **System Design Specification (SDS)**

## **Document Control**

| Attribute | Details |
| ----- | ----- |
| **Document Type** | System Design Specification (SDS) |
| **Document Version** | 1.0 |
| **Document Status** | LOCKED |
| **Derivation Level** | Derived Document — Level 2 |
| **Project Name** | Workout Tracker |
| **Parent Document** | Software Requirements Specification (SRS), Version 1.0 |
| **Grandparent Document** | Business Requirements Document (BRD), Version 1.0 |
| **Target Platforms** | iOS and Android mobile application |
| **Architecture Model** | Mobile client \+ managed cloud backend |
| **Authentication** | Firebase Authentication — email/password |
| **Primary Data Store** | Cloud Firestore |
| **Local Database** | None |
| **Offline Persistence / Sync** | None |
| **Status** | Architecture baseline for MVP |

---

# **1\. Introduction**

## **1.1 Purpose**

This System Design Specification defines the technical architecture and system design for the Workout Tracker MVP.

The document translates the requirements established in SRS Version 1.0 into implementable architectural components, interfaces, data structures, security boundaries, data flows, error handling mechanisms, and non-functional design decisions.

The design supports the complete MVP lifecycle:

> **Authenticate → Plan → Schedule → Perform → Record → Review → Progress**

The design uses a mobile client connected to Firebase-managed backend services. Firebase Authentication provides identity and authentication services, while Cloud Firestore provides persistent application data storage.

The system intentionally does **not** use a local database or local persistent application data store.

---

## **1.2 Scope**

The SDS covers:

* User authentication and account access.  
* User profile association.  
* Exercise catalogue access.  
* Workout plan management.  
* Basic workout scheduling.  
* Workout execution.  
* Workout recording.  
* Workout history.  
* Progress tracking.  
* Statistics and personal-best calculation.  
* Data validation and integrity.  
* Cloud persistence.  
* User data isolation.  
* Error and recovery behavior.  
* Performance, reliability, security, scalability, usability, and maintainability design.

The design is limited to behavior already represented in SRS Version 1.0.

The following remain outside the design scope:

* Social authentication.  
* Phone/OTP authentication.  
* Biometric authentication.  
* MFA.  
* Anonymous authentication.  
* Email verification.  
* AI coaching.  
* Advanced scheduling.  
* Health-platform integrations.  
* Wearables.  
* Social features.  
* Advanced workout programming.  
* Local database persistence.  
* Offline synchronization.  
* Multi-device conflict resolution.  
* Account deletion and data export.

---

## **1.3 Definitions, Acronyms, Abbreviations**

| Term | Definition |
| ----- | ----- |
| **SDS** | System Design Specification |
| **SRS** | Software Requirements Specification |
| **BRD** | Business Requirements Document |
| **Firebase Authentication** | Managed authentication service used for email/password identity management |
| **Firestore** | Cloud document database used as the application's persistent data store |
| **UID** | Unique Firebase user identifier |
| **Workout Plan** | A predefined collection of exercises and intended performance targets |
| **Workout Session** | An actual workout performed by the user |
| **Exercise** | A defined physical activity |
| **Set** | A single instance of performing an exercise |
| **Training Volume** | Accumulated weight × repetitions across valid applicable completed sets |
| **Personal Best** | Best recorded performance for a defined exercise metric |
| **Completed Workout** | A workout session satisfying the defined completion criteria |
| **Incomplete Workout** | A workout session that does not satisfy completion criteria and is excluded from applicable progress/statistics |
| **Owner** | Authenticated user identified by Firebase UID |
| **MVP** | Minimum Viable Product |

---

## **1.4 References**

1. **Business Requirements Document — Workout Tracker, Version 1.0**.  
   The available BRD establishes the core Plan → Schedule → Perform → Record → Review → Progress lifecycle, mobile iOS/Android scope, functional requirements, and NFR baseline.  
2. **Software Requirements Specification — Workout Tracker, Version 1.0**.  
3. **Authentication Module — Decision Record & Spec, Version 1.0**.  
4. Firebase Authentication and Cloud Firestore are architectural constraints established by the finalized Authentication Module.

---

# **2\. Design Overview**

## **2.1 Design Goals and Guiding Principles**

The architecture follows these principles:

1. **Single source of truth**  
   Persistent application data is stored in Cloud Firestore.  
2. **Managed authentication**  
   Authentication responsibility is delegated to Firebase Authentication.  
3. **No local database**  
   The mobile application does not maintain a local relational or document database.  
4. **Online-first operation**  
   Application reads and writes require connectivity.  
5. **Authenticated ownership**  
   User-owned data is isolated using the authenticated Firebase UID.  
6. **Separation of planned and actual performance**  
   Workout plans remain independent from historical workout sessions.  
7. **Immutable historical meaning**  
   Changes to a workout plan must not rewrite historical performance.  
8. **Validation before persistence**  
   Invalid workout data must be rejected before being treated as valid performance.  
9. **Minimal MVP architecture**  
   Architecture should avoid infrastructure that exists only to support out-of-scope capabilities.  
10. **Traceability-first design**  
    Every component, interface, data structure, and design decision maps to an SRS requirement.

The BRD explicitly establishes the core lifecycle as Plan → Schedule → Perform → Record → Review → Progress.

---

## **2.2 Architectural Style / Approach**

The system uses a **managed cloud-backed mobile client architecture**.

### **Architectural layers**

┌─────────────────────────────────────────────┐  
│              Mobile Application             │  
│                                             │  
│  Authentication                             │  
│  Workout Planning                           │  
│  Scheduling                                 │  
│  Workout Execution                          │  
│  History / Progress / Statistics             │  
└──────────────────────┬──────────────────────┘  
                       │  
                       │ Authenticated access  
                       ▼  
┌─────────────────────────────────────────────┐  
│          Managed Firebase Services          │  
│                                             │  
│  Firebase Authentication                    │  
│  Cloud Firestore                            │  
└─────────────────────────────────────────────┘

The architecture is intentionally not offline-first because the finalized authentication/data architecture specifies no local database, no offline cache, and no synchronization layer.

### **Architectural rationale**

| Decision | Design Rationale | SRS Traceability |
| ----- | ----- | ----- |
| Managed authentication | Avoid application-managed password storage and authentication lifecycle | SRS-FR-1 to SRS-FR-6 |
| Cloud document persistence | Supports user-owned workout data and historical records | SRS-FR-33 to SRS-FR-52 |
| UID-based ownership | Provides deterministic user data isolation | SRS-NFR-4 |
| No local database | Eliminates synchronization and conflict-management complexity | SRS-NFR-6 |
| Separate plans and sessions | Prevents plan changes from modifying history | SRS-FR-38 |
| Nested workout structures | Keeps one plan/session logically self-contained | SRS-FR-10 to SRS-FR-14, SRS-FR-33 to SRS-FR-38 |

---

## **2.3 Assumptions and Design Constraints**

### **Assumptions**

1. Users operate the application as individual users.  
2. Each authenticated user owns their workout plans and workout records.  
3. Exercise catalogue data is centrally maintained and read-only from the client.  
4. Workout plans can contain repetition-based and time-based exercises.  
5. Actual performance can differ from planned targets.  
6. Statistics are derived from valid completed records.  
7. The application is primarily used on mobile devices.  
8. Internet connectivity is available when application data is read or written.

The BRD establishes mobile iOS/Android deployment and an MVP centered on the core workout lifecycle.

### **Design Constraints**

* Firebase Authentication shall be used for authentication.  
* Email/password is the only authentication mechanism.  
* Cloud Firestore shall be the persistent application data store.  
* No local database shall be introduced.  
* No password shall be stored in application data.  
* No social authentication shall be introduced.  
* No offline synchronization layer shall be introduced.  
* User-owned records shall be associated with the authenticated UID.  
* Exercise catalogue data shall be read-only from the client.

---

## **2.4 Out-of-Scope Design Elements**

The following architectural elements are deliberately excluded:

* Local SQLite/Realm database.  
* Offline write queue.  
* Synchronization engine.  
* Conflict-resolution engine.  
* Social login providers.  
* Phone authentication.  
* Biometric authentication.  
* MFA.  
* Custom authentication backend.  
* Custom password storage.  
* AI recommendation engine.  
* Wearable integration layer.  
* Health platform integration layer.  
* Social graph.  
* Advanced scheduling engine.  
* Background synchronization service.

---

# **3\. System Architecture**

## **3.1 High-Level Architecture Description**

### **Component Catalogue**

| ID | Component | Responsibility | SRS Traceability |
| ----- | ----- | ----- | ----- |
| **SDS-COMP-1** | Mobile Application Shell | Application lifecycle, authenticated entry point and navigation boundary | SRS-FR-1–SRS-FR-6, SRS-NFR-1, SRS-NFR-13 |
| **SDS-COMP-2** | Authentication Component | Registration, login, logout, password reset and auth-state handling | SRS-FR-1–SRS-FR-6, SRS-NFR-4 |
| **SDS-COMP-3** | User Profile Component | Creates and retrieves user profile information associated with authenticated identity | SRS-FR-1, SRS-FR-2, SRS-NFR-4, SRS-NFR-5 |
| **SDS-COMP-4** | Exercise Catalogue Component | Provides access to valid exercises | SRS-FR-7, SRS-FR-8, SRS-FR-48 |
| **SDS-COMP-5** | Workout Plan Component | Creates, validates, updates and deletes workout plans | SRS-FR-9–SRS-FR-14, SRS-FR-48–SRS-FR-52 |
| **SDS-COMP-6** | Scheduling Component | Manages basic weekly and recurring workout schedules | SRS-FR-15–SRS-FR-24 |
| **SDS-COMP-7** | Workout Execution Component | Controls active workout behavior, set/exercise completion, pause, skip, cancellation and timing | SRS-FR-25–SRS-FR-32 |
| **SDS-COMP-8** | Workout Record Component | Persists completed workout sessions and summaries | SRS-FR-33–SRS-FR-35, SRS-FR-50–SRS-FR-52 |
| **SDS-COMP-9** | History Component | Retrieves and presents historical completed workouts | SRS-FR-36–SRS-FR-38 |
| **SDS-COMP-10** | Progress Component | Compares valid performance across sessions | SRS-FR-39–SRS-FR-41, SRS-FR-52 |
| **SDS-COMP-11** | Statistics Component | Calculates workout counts, duration, volume, exercise statistics and PBs | SRS-FR-42–SRS-FR-47 |
| **SDS-COMP-12** | Validation Component | Performs business/data validation before persistence and calculation | SRS-FR-48–SRS-FR-52, SRS-NFR-5 |
| **SDS-COMP-13** | Firestore Persistence Boundary | Provides controlled persistence and retrieval of application data | SRS-FR-33–SRS-FR-52, SRS-NFR-4–SRS-NFR-7 |
| **SDS-COMP-14** | Firestore Security Boundary | Enforces authenticated ownership and read/write restrictions | SRS-NFR-4, SRS-NFR-5, SRS-NFR-8–SRS-NFR-10 |
| **SDS-COMP-15** | Firebase Authentication Service Boundary | Provides managed identity and authentication lifecycle | SRS-FR-1–SRS-FR-6, SRS-NFR-4 |

---

## **3.2 Component Responsibilities and Boundaries**

### **SDS-COMP-1 — Mobile Application Shell**

**Responsibilities**

* Start the application.  
* Observe authentication state.  
* Route authenticated users to protected application functionality.  
* Route unauthenticated users to authentication functionality.  
* Prevent protected functionality from being used without authentication.

**Inputs**

* Application lifecycle events.  
* Authentication state.

**Outputs**

* Authenticated application context.  
* Authentication entry context.

**Boundary**

The application shell does not authenticate users itself.

---

### **SDS-COMP-2 — Authentication Component**

**Responsibilities**

* Registration.  
* Login.  
* Logout.  
* Password reset.  
* Authentication-state observation.  
* Authentication error translation into user-facing application errors.

**Boundary**

Passwords are never passed to Firestore.

---

### **SDS-COMP-3 — User Profile Component**

The component manages application profile information separately from authentication credentials.

The Firebase UID establishes the relationship between authentication identity and profile.

---

### **SDS-COMP-4 — Exercise Catalogue Component**

The exercise catalogue is treated as shared reference data.

Client users can read valid exercise definitions but cannot modify catalogue data.

---

### **SDS-COMP-5 — Workout Plan Component**

The component manages user-owned workout plans.

A workout plan contains:

* Plan identity.  
* Plan name.  
* Planned exercises.  
* Target sets.  
* Target repetitions.  
* Target weight.  
* Applicable duration.  
* Applicable rest periods.

Plan data is independent of completed workout history.

---

### **SDS-COMP-6 — Scheduling Component**

The scheduling component manages:

* Day assignments.  
* Recurring schedule information.  
* Scheduled-plan retrieval.  
* Schedule modification.  
* Schedule removal.  
* Schedule validation.

The component does not provide intelligent or adaptive scheduling.

---

### **SDS-COMP-7 — Workout Execution Component**

The execution component maintains the active workout state required to:

* Follow the selected plan.  
* Record actual performance.  
* Complete sets.  
* Complete exercises.  
* Skip items.  
* Pause/resume applicable activity.  
* Run work/rest timing.  
* Finish or cancel the session.

The component does not persist incomplete activity as a valid completed workout record.

---

### **SDS-COMP-8 — Workout Record Component**

The record component converts a valid completed workout into a persistent historical record.

The persisted record contains actual performance rather than relying on the current version of the workout plan.

This is the principal mechanism protecting historical integrity.

---

### **SDS-COMP-9 — History Component**

The history component retrieves completed workout records belonging to the authenticated user.

It does not retrieve another user's records.

---

### **SDS-COMP-10 — Progress Component**

The progress component derives comparisons from valid historical workout records.

It must exclude records that do not satisfy validity/completion rules.

---

### **SDS-COMP-11 — Statistics Component**

The statistics component derives:

* Total completed workouts.  
* Training volume.  
* Workout duration.  
* Exercise-level statistics.  
* Personal-best values.

All derived values are calculated from valid records.

---

### **SDS-COMP-12 — Validation Component**

Validation is applied before a record can become a valid business record.

The component validates:

* Required information.  
* Exercise references.  
* Set values.  
* Repetition values.  
* Weight values.  
* Duration values.  
* Workout completion state.

---

### **SDS-COMP-13 — Firestore Persistence Boundary**

This component provides the only persistent application-data boundary.

It manages:

* User profile persistence.  
* Workout plans.  
* Workout sessions.  
* Exercise catalogue retrieval.

No local database sits behind this boundary.

---

### **SDS-COMP-14 — Firestore Security Boundary**

Security rules enforce:

Authenticated User  
       │  
       ▼  
request.auth.uid  
       │  
       ▼  
users/{uid}  
       │  
       ├── workoutPlans  
       └── workoutSessions

A user can access only documents beneath their authenticated UID.

---

### **SDS-COMP-15 — Firebase Authentication Service Boundary**

Firebase Authentication owns:

* User identity.  
* Password handling.  
* Authentication session.  
* UID generation.  
* Password reset.

Application data never stores passwords.

---

## **3.3 Component Interaction / Data Flow Overview**

### **Registration**

User  
 │  
 ▼  
SDS-COMP-2 Authentication  
 │  
 ▼  
Firebase Authentication  
 │  
 └── UID  
      │  
      ▼  
SDS-COMP-3 User Profile  
      │  
      ▼  
SDS-COMP-13 Firestore  
      │  
      ▼  
Authenticated Application

### **Workout Planning**

User  
 │  
 ▼  
SDS-COMP-5 Workout Plan  
 │  
 ├── SDS-COMP-12 Validation  
 │  
 └── SDS-COMP-13 Firestore

### **Workout Execution**

Saved Plan  
    │  
    ▼  
SDS-COMP-7 Workout Execution  
    │  
    ├── Validation  
    │  
    ▼  
Completed Workout  
    │  
    ▼  
SDS-COMP-8 Workout Record  
    │  
    ▼  
SDS-COMP-13 Firestore

### **Progress / Statistics**

Firestore  
    │  
    ▼  
Valid Workout Sessions  
    │  
    ├──► SDS-COMP-9 History  
    │  
    ├──► SDS-COMP-10 Progress  
    │  
    └──► SDS-COMP-11 Statistics  
---

## **3.4 Deployment View**

┌────────────────────────────────────────────┐  
│             Mobile Device                  │  
│                                            │  
│ ┌────────────────────────────────────────┐ │  
│ │ Workout Tracker Mobile Application      │ │  
│ │                                        │ │  
│ │ Authentication                         │ │  
│ │ Workout Planning                       │ │  
│ │ Scheduling                             │ │  
│ │ Execution                              │ │  
│ │ History / Progress / Statistics        │ │  
│ └───────────────────────┬────────────────┘ │  
└─────────────────────────┼──────────────────┘  
                          │  
                   Internet Connection  
                          │  
                          ▼  
┌────────────────────────────────────────────┐  
│             Firebase Services              │  
│                                            │  
│ ┌──────────────────┐  ┌─────────────────┐ │  
│ │ Authentication   │  │ Cloud Firestore │ │  
│ │                  │  │                 │ │  
│ │ Email/Password   │  │ User Data       │ │  
│ │ UID              │  │ Plans           │ │  
│ │ Sessions         │  │ Exercises       │ │  
│ └──────────────────┘  └─────────────────┘ │  
└────────────────────────────────────────────┘

There is **no local database tier**.

---

# **4\. Component Design**

## **SDS-COMP-1 — Mobile Application Shell**

**SRS:** SRS-FR-1–SRS-FR-6, SRS-NFR-1, SRS-NFR-13

| Aspect | Design |
| ----- | ----- |
| Responsibility | Application lifecycle and authenticated application boundary |
| Input | Authentication state |
| Output | Protected or unauthenticated application context |
| Persistence | None |
| Boundary | Does not implement authentication |

---

## **SDS-COMP-2 — Authentication Component**

**SRS:** SRS-FR-1–SRS-FR-6, SRS-NFR-4

| Function | Design |
| ----- | ----- |
| Registration | Email/password submitted to Firebase Authentication |
| Login | Email/password submitted to Firebase Authentication |
| Logout | Firebase authentication session terminated |
| Reset | Firebase password-reset mechanism |
| Auth state | Authentication-state stream observed by application |
| Password storage | Firebase Authentication only |
| Application storage | Password never persisted |

### **Authentication state model**

UNKNOWN  
   │  
   ├── Authenticated ──► PROTECTED  
   │  
   └── Unauthenticated ──► AUTH\_REQUIRED  
---

## **SDS-COMP-3 — User Profile Component**

**SRS:** SRS-FR-1, SRS-FR-2, SRS-NFR-4, SRS-NFR-5

The user profile is stored beneath the authenticated UID.

Conceptual profile:

users/{uid}  
    ├── displayName  
    ├── dateOfBirth  
    ├── heightCm  
    ├── weightKg  
    ├── fitnessGoal  
    ├── experienceLevel  
    ├── createdAt  
    └── updatedAt

Only the authenticated owner can access their profile.

---

## **SDS-COMP-4 — Exercise Catalogue Component**

**SRS:** SRS-FR-7, SRS-FR-8, SRS-FR-48

Conceptual structure:

exercises/{exerciseId}

The catalogue is:

* Shared.  
* Read-only from the client.  
* Referenced by workout plans.  
* Validated before a plan is persisted.

---

## **SDS-COMP-5 — Workout Plan Component**

**SRS:** SRS-FR-9–SRS-FR-14, SRS-FR-48–SRS-FR-52\*\*

Conceptual structure:

users/{uid}/workoutPlans/{planId}

plan  
 ├── name  
 ├── planExercises\[\]  
 │    ├── exerciseId  
 │    ├── targetSets  
 │    ├── targetRepetitions  
 │    ├── targetWeight  
 │    ├── targetDuration  
 │    └── restPeriod  
 ├── createdAt  
 └── updatedAt

The design keeps plan exercises inside the plan document rather than introducing additional persistence boundaries.

---

## **SDS-COMP-6 — Scheduling Component**

**SRS:** SRS-FR-15–SRS-FR-24

Schedule information belongs to the user's workout planning context.

The component validates:

1. Referenced workout plan exists.  
2. Referenced workout plan is available.  
3. Selected schedule configuration is valid.  
4. Scheduling changes affect future scheduling only.

Previously completed workout sessions are never rewritten because of scheduling changes.

---

## **SDS-COMP-7 — Workout Execution Component**

**SRS:** SRS-FR-25–SRS-FR-32, SRS-NFR-2, SRS-NFR-3, SRS-NFR-6\*\*

The component maintains the current workout execution state in application memory.

Conceptual state:

NOT\_STARTED  
     │  
     ▼  
ACTIVE  
 ┌───┼───────────────┐  
 ▼   ▼               ▼  
PAUSED  ITEM\_COMPLETE  SKIPPED  
 │                       │  
 └──────────┬────────────┘  
            ▼  
         ACTIVE  
            │  
            ▼  
       FINISH/CANCEL

The active execution state is not treated as a completed historical record until completion requirements are satisfied.

---

## **SDS-COMP-8 — Workout Record Component**

**SRS:** SRS-FR-33–SRS-FR-35, SRS-FR-50–SRS-FR-52\*\*

Conceptual structure:

users/{uid}/workoutSessions/{sessionId}

session  
 ├── workoutPlanReference  
 ├── completedAt  
 ├── sessionDuration  
 ├── status  
 └── sessionExercises\[\]  
      ├── exerciseId  
      ├── actualSets\[\]  
      │    ├── repetitions  
      │    ├── weight  
      │    └── duration  
      └── completionState

The actual values are copied into the workout session record rather than dynamically referencing the current plan targets.

This prevents later plan modifications from changing historical performance.

---

## **SDS-COMP-9 — History Component**

**SRS:** SRS-FR-36–SRS-FR-38\*\*

History reads completed sessions belonging to the authenticated user.

The component does not modify historical records as a side effect of viewing them.

---

## **SDS-COMP-10 — Progress Component**

**SRS:** SRS-FR-39–SRS-FR-41, SRS-FR-52\*\*

Progress is calculated from valid completed workout records.

Supported measures include:

* Weight.  
* Repetitions.  
* Training volume.  
* Duration where applicable.

Invalid or incomplete sessions are excluded.

---

## **SDS-COMP-11 — Statistics Component**

**SRS:** SRS-FR-42–SRS-FR-47

The statistics component provides:

Completed Workout Count  
Training Volume  
Workout Duration  
Exercise Statistics  
Personal Best

The component uses the same validity rules used by progress calculations.

This prevents a record from being considered valid by statistics but invalid by progress.

---

## **SDS-COMP-12 — Validation Component**

**SRS:** SRS-FR-48–SRS-FR-52, SRS-NFR-5\*\*

Validation rules include:

| Data | Validation |
| ----- | ----- |
| Plan name | Required and non-blank |
| Exercise | Must reference a valid exercise |
| Sets | Must satisfy applicable positive-value requirements |
| Repetitions | Must satisfy applicable positive-value requirements |
| Weight | Must not be negative |
| Duration | Must not be negative |
| Workout status | Must satisfy completion rules |
| Performance record | Invalid/incomplete records excluded from calculations |

---

## **SDS-COMP-13 — Firestore Persistence Boundary**

**SRS:** SRS-FR-33–SRS-FR-52, SRS-NFR-4–SRS-NFR-7\*\*

All application persistence passes through this boundary.

The boundary does not provide:

* Local persistence.  
* Offline queues.  
* Conflict resolution.  
* Cross-user data access.

---

## **SDS-COMP-14 — Firestore Security Boundary**

**SRS:** SRS-NFR-4, SRS-NFR-5, SRS-NFR-8–SRS-NFR-10\*\*

Conceptual authorization:

request.auth \!= null  
        AND  
request.auth.uid \== requestedUserUid

User-owned data is structured beneath:

users/{uid}

The security boundary rejects unauthorized access even if the client attempts to construct another user's document path.

---

## **SDS-COMP-15 — Firebase Authentication Service Boundary**

**SRS:** SRS-FR-1–SRS-FR-6, SRS-NFR-4\*\*

Firebase Authentication owns:

* Credential processing.  
* Password storage.  
* Password reset.  
* Authentication session.  
* UID generation.

The application never implements or persists password credentials itself.

---

# **5\. Interface Design**

## **5.1 User Interfaces**

### **SDS-IF-1 — Registration Interface**

**SRS:** SRS-FR-1

Inputs:

* Email.  
* Password.

Outputs:

* Registration success.  
* Registration failure.  
* Authenticated application state.

---

### **SDS-IF-2 — Login Interface**

**SRS:** SRS-FR-2

Inputs:

* Email.  
* Password.

Outputs:

* Authentication success.  
* Authentication failure.  
* User-friendly error state.

---

### **SDS-IF-3 — Password Reset Interface**

**SRS:** SRS-FR-5

Inputs:

* Email.

Output:

* Password-reset request result.

The reset itself occurs through Firebase's hosted password-reset mechanism.

---

### **SDS-IF-4 — Workout Planning Interface**

**SRS:** SRS-FR-7–SRS-FR-14

Supports:

* Exercise selection.  
* Plan creation.  
* Target configuration.  
* Plan modification.  
* Plan deletion.

---

### **SDS-IF-5 — Scheduling Interface**

**SRS:** SRS-FR-15–SRS-FR-24

Supports:

* Day assignment.  
* Recurring schedule configuration.  
* Schedule viewing.  
* Schedule modification.  
* Schedule removal.

---

### **SDS-IF-6 — Active Workout Interface**

**SRS:** SRS-FR-25–SRS-FR-32

Supports:

* Planned exercise information.  
* Actual performance entry.  
* Work/rest timing.  
* Pause/resume.  
* Completion.  
* Skip.  
* Finish.  
* Cancel.

---

### **SDS-IF-7 — History Interface**

**SRS:** SRS-FR-36–SRS-FR-38

Supports:

* Completed workout list.  
* Individual workout details.

---

### **SDS-IF-8 — Progress and Statistics Interface**

**SRS:** SRS-FR-39–SRS-FR-47

Supports:

* Performance comparison.  
* Training volume.  
* Duration.  
* Exercise statistics.  
* Personal bests.

---

## **5.2 Internal Component Interfaces**

### **SDS-IF-9 — Authentication State Interface**

**SRS:** SRS-FR-2, SRS-FR-3, SRS-FR-6

Authentication Component  
        │  
        ▼  
Authentication State  
        │  
        ├── Authenticated \+ UID  
        └── Unauthenticated  
---

### **SDS-IF-10 — Validation Interface**

**SRS:** SRS-FR-48–SRS-FR-52

Feature Component  
      │  
      ▼  
Validation Component  
      │  
 ┌────┴────┐  
 ▼         ▼  
Valid    Invalid  
 │         │  
 ▼         ▼  
Persist   Reject  
---

### **SDS-IF-11 — Persistence Interface**

**SRS:** SRS-FR-33–SRS-FR-52

Feature components communicate with the persistence boundary for:

* Create.  
* Read.  
* Update.  
* Delete where permitted.

---

### **SDS-IF-12 — Statistics Calculation Interface**

**SRS:** SRS-FR-39–SRS-FR-47

Valid Workout Records  
          │  
          ▼  
Statistics Component  
          │  
          ├── Workout Count  
          ├── Volume  
          ├── Duration  
          ├── Exercise Statistics  
          └── Personal Best  
---

## **5.3 External System Interfaces**

### **SDS-IF-13 — Firebase Authentication Interface**

**SRS:** SRS-FR-1–SRS-FR-6

Purpose:

* Registration.  
* Login.  
* Logout.  
* Password reset.  
* Authentication state.

Authentication is the external identity boundary.

---

### **SDS-IF-14 — Cloud Firestore Interface**

**SRS:** SRS-FR-7–SRS-FR-52

Purpose:

* User profile persistence.  
* Exercise catalogue retrieval.  
* Workout plan persistence.  
* Workout session persistence.  
* Historical record retrieval.

---

## **5.4 Communication/Integration Patterns**

The system uses **synchronous request/response interactions** for application data operations.

### **Authentication**

Mobile  
  │  
  │ Authentication request  
  ▼  
Firebase Authentication  
  │  
  │ Authentication result / UID  
  ▼  
Mobile

### **Firestore**

Mobile  
  │  
  │ Authenticated read/write  
  ▼  
Cloud Firestore  
  │  
  │ Result  
  ▼  
Mobile

No background synchronization or offline write queue is defined.

---

# **6\. Data Design**

## **6.1 Data Entities and Relationships**

### **SDS-DATA-1 — Authenticated User Identity**

**SRS:** SRS-FR-1–SRS-FR-6, SRS-NFR-4

Managed by Firebase Authentication.

Primary identifier:

uid

The UID is the identity anchor for user-owned Firestore data.

---

### **SDS-DATA-2 — User Profile**

**SRS:** SRS-FR-1, SRS-FR-2, SRS-NFR-4, SRS-NFR-9

users/{uid}

Contains only MVP-required profile information.

---

### **SDS-DATA-3 — Exercise**

**SRS:** SRS-FR-7, SRS-FR-8, SRS-FR-48\*\*

exercises/{exerciseId}

Relationship:

Exercise  
   ▲  
   │  
   │ referenced by  
   │  
Workout Plan  
   │  
   │ produces actual performance  
   ▼  
Workout Session  
---

### **SDS-DATA-4 — Workout Plan**

**SRS:** SRS-FR-9–SRS-FR-14, SRS-FR-48–SRS-FR-52\*\*

users/{uid}/workoutPlans/{planId}

Plan exercises are represented as nested structures.

---

### **SDS-DATA-5 — Workout Schedule**

**SRS:** SRS-FR-15–SRS-FR-24, SRS-NFR-7\*\*

Schedule data represents future planned activity.

Schedule changes do not mutate completed sessions.

---

### **SDS-DATA-6 — Workout Session**

**SRS:** SRS-FR-25–SRS-FR-41, SRS-FR-46, SRS-FR-50–SRS-FR-52\*\*

users/{uid}/workoutSessions/{sessionId}

The session stores actual performance independently of the current workout plan.

---

### **SDS-DATA-7 — Derived Statistics**

**SRS:** SRS-FR-42–SRS-FR-47

Statistics are derived from valid workout sessions.

They are logically derived rather than treated as independent authoritative workout records.

---

## **6.2 Data Flow and Transformation Rules**

### **Plan-to-Session Transformation**

Workout Plan  
     │  
     │ Start workout  
     ▼  
Active Workout  
     │  
     │ Actual performance  
     ▼  
Completed Session  
     │  
     ▼  
Historical Record

The transformation copies relevant planned context and stores actual performance separately.

### **Statistics Transformation**

Workout Sessions  
       │  
       ▼  
Validity Filter  
       │  
       ▼  
Valid Completed Records  
       │  
       ├──► Count  
       ├──► Volume  
       ├──► Duration  
       ├──► Exercise Statistics  
       └──► Personal Best  
---

## **6.3 Data Validation Design**

### **SDS-DATA-8 — Validation Rules**

**SRS:** SRS-FR-48–SRS-FR-52

Validation is performed before persistence or calculation.

Rules:

1. Required values must be present.  
2. Workout plan names must not be blank.  
3. Exercises must exist in the valid exercise catalogue.  
4. Invalid set values are rejected.  
5. Invalid repetition values are rejected.  
6. Negative weight is rejected.  
7. Negative duration is rejected.  
8. Invalid/incomplete records are excluded from derived calculations.

---

## **6.4 Data Retention and Archival Design**

**SRS:** SRS-NFR-5, SRS-NFR-6, SRS-NFR-10, SRS-NFR-11

The MVP does not define a separate archival store.

### **Design constraints**

* Completed workout records remain available through Firestore.  
* No automatic archival process is introduced.  
* No local archive is maintained.  
* No account deletion/cascading cleanup mechanism is included in MVP.  
* Data handling must remain consistent with applicable privacy requirements.

---

# **7\. Non-Functional Design**

## **7.1 Performance Design Decisions**

**SRS:** SRS-NFR-1, SRS-NFR-2, SRS-NFR-3

### **SDS-NFR-1**

**Parent:** SRS-NFR-1  
**BRD:** BRD-NFR-001

The mobile application shall avoid unnecessary sequential operations for normal planning, scheduling, history, and statistics interactions.

### **SDS-NFR-2**

**Parent:** SRS-NFR-2  
**BRD:** BRD-NFR-002

Workout timers shall operate independently of Firestore round trips.

**Design constraint:** Timer transitions shall not depend on a network response.

### **SDS-NFR-3**

**Parent:** SRS-NFR-3  
**BRD:** BRD-NFR-003

Workout input operations shall not introduce persistence operations into every timer transition.

**Design constraint:** Work/rest timer state shall remain local to the active application execution context.

---

## **7.2 Scalability Design Decisions**

**SRS:** SRS-NFR-17, SRS-NFR-18

### **SDS-NFR-4**

**Parent:** SRS-NFR-17  
**BRD:** BRD-NFR-017

User-owned data shall be partitioned by UID.

**Design constraint:** No single global user-workout collection shall be used as the primary ownership boundary.

### **SDS-NFR-5**

**Parent:** SRS-NFR-18  
**BRD:** BRD-NFR-018

Functional components shall communicate through defined boundaries so future capabilities can be introduced without modifying the ownership/security model.

**Design constraint:** Future functionality must not require changing the identity relationship between user UID and user-owned data.

---

## **7.3 Availability and Reliability Design Decisions**

**SRS:** SRS-NFR-4–SRS-NFR-7

### **SDS-NFR-6**

**Parent:** SRS-NFR-4  
**BRD:** BRD-NFR-004

Successfully persisted completed workout records shall be treated as authoritative historical data.

### **SDS-NFR-7**

**Parent:** SRS-NFR-5  
**BRD:** BRD-NFR-005

Progress and statistics shall use the same validity rules as workout records.

### **SDS-NFR-8**

**Parent:** SRS-NFR-6  
**BRD:** BRD-NFR-006

Interrupted active workouts shall not modify previously completed sessions.

### **SDS-NFR-9**

**Parent:** SRS-NFR-7  
**BRD:** BRD-NFR-007

Schedule and plan references shall be validated before scheduling persistence.

**Design constraint:** A schedule cannot persist a reference to an unavailable workout plan.

---

## **7.4 Security Design Decisions**

**SRS:** SRS-NFR-4, SRS-NFR-8–SRS-NFR-12

### **SDS-NFR-10**

**Parent:** SRS-NFR-8  
**BRD:** BRD-NFR-008

All protected user-owned data shall require authentication.

### **SDS-NFR-11**

**Parent:** SRS-NFR-9  
**BRD:** BRD-NFR-009

Only MVP-required personal profile information shall be collected.

### **SDS-NFR-12**

**Parent:** SRS-NFR-10  
**BRD:** BRD-NFR-010

Application data access shall be constrained to the authenticated owner.

### **SDS-NFR-13**

**Parent:** SRS-NFR-11  
**BRD:** BRD-NFR-011

Privacy controls shall support applicable target-market data-protection obligations.

### **SDS-NFR-14**

**Parent:** SRS-NFR-12  
**BRD:** BRD-NFR-012

The system shall keep workout statistics within the general-fitness product boundary.

**Design constraint:** No clinical or medical interpretation engine shall be implemented.

### **Security ownership model**

Firebase Auth  
     │  
     ▼  
Authenticated UID  
     │  
     ▼  
users/{uid}  
     │  
     ├── workoutPlans  
     └── workoutSessions  
---

## **7.5 Usability and Accessibility Design Decisions**

**SRS:** SRS-NFR-13–SRS-NFR-16

### **SDS-NFR-15**

**Parent:** SRS-NFR-13  
**BRD:** BRD-NFR-013

The application shall use consistent interaction patterns across workout planning, execution, history, and statistics.

### **SDS-NFR-16**

**Parent:** SRS-NFR-14  
**BRD:** BRD-NFR-014

Workout recording shall minimize unnecessary interaction.

**Design constraint:** Timer transitions shall not require additional user confirmation.

### **SDS-NFR-17**

**Parent:** SRS-NFR-15  
**BRD:** BRD-NFR-015

Validation failures shall be returned as clear user-facing states.

### **SDS-NFR-18**

**Parent:** SRS-NFR-16  
**BRD:** BRD-NFR-016

Scheduling operations shall use explicit day and recurrence semantics rather than adaptive scheduling behavior.

---

## **7.6 Maintainability and Observability Design Decisions**

The SRS does not define a dedicated logging/monitoring NFR beyond reliability and maintainability implications.

Therefore, no independent observability subsystem is introduced as a new functional capability.

Design constraints:

* Components shall maintain clear responsibility boundaries.  
* Authentication errors shall be translated into application-level states.  
* Firestore operation failures shall be distinguishable from validation failures.  
* Business validation shall remain separate from persistence operations.  
* Statistics calculation logic shall be independently testable.

No additional business-facing monitoring capability is introduced.

---

# **8\. Error Handling and Recovery Design**

## **SDS-ERR-1 — Authentication Failure**

**SRS:** SRS-FR-1, SRS-FR-2, SRS-FR-6

Authentication failures are converted into application-level error states.

Raw provider error messages are not directly presented as the primary user-facing message.

---

## **SDS-ERR-2 — Registration Failure**

**SRS:** SRS-FR-1

Possible conditions:

* Invalid email.  
* Invalid password.  
* Existing account.  
* Network/service failure.

Recovery:

* Remain on authentication context.  
* Preserve non-sensitive input where appropriate.  
* Allow retry.

---

## **SDS-ERR-3 — Login Failure**

**SRS:** SRS-FR-2

Recovery:

* Remain unauthenticated.  
* Display actionable error.  
* Allow retry.

---

## **SDS-ERR-4 — Password Reset Failure**

**SRS:** SRS-FR-5

Recovery:

* Display password-reset request failure.  
* Permit retry.  
* Do not expose authentication implementation details.

---

## **SDS-ERR-5 — Firestore Read Failure**

**SRS:** SRS-FR-7–SRS-FR-52

Recovery:

Firestore Read  
     │  
     ├── Success ──► Continue  
     │  
     └── Failure  
           │  
           ▼  
     Error State  
           │  
           ▼  
       Retry Action

No local database fallback is provided.

---

## **SDS-ERR-6 — Firestore Write Failure**

**SRS:** SRS-FR-9–SRS-FR-52

A failed write must not be represented to the user as successfully persisted data.

The application shall:

1. Detect failure.  
2. Display failure state.  
3. Preserve currently available in-memory input where appropriate.  
4. Allow retry.  
5. Avoid creating a duplicate successful record through incorrect UI state.

---

## **SDS-ERR-7 — Validation Failure**

**SRS:** SRS-FR-48–SRS-FR-52

Invalid input is rejected before persistence.

Examples:

Negative Weight     → Reject  
Negative Duration   → Reject  
Invalid Exercise    → Reject  
Blank Plan Name     → Reject  
Invalid Repetitions → Reject  
---

## **SDS-ERR-8 — Interrupted Workout**

**SRS:** SRS-FR-25, SRS-FR-32, SRS-NFR-6

An interrupted active workout must not modify previously completed sessions.

The system must distinguish:

Active / Incomplete  
        ≠  
Completed Historical Record  
---

## **SDS-ERR-9 — Statistics Recalculation Failure**

**SRS:** SRS-FR-47, SRS-FR-52

If underlying workout records change, derived statistics must be calculated from the current valid source records rather than relying on stale derived values.

---

# **9\. Design Quality Attributes & Compliance Mapping**

| Quality Attribute | Design Response |
| ----- | ----- |
| Security | Firebase Authentication \+ UID-based Firestore ownership |
| Data Integrity | Validation boundary \+ separate plan/session structures |
| Reliability | Authoritative cloud persistence |
| Performance | Local active timer state; minimized persistence operations |
| Scalability | UID-based user data partitioning |
| Maintainability | Explicit component boundaries |
| Usability | Simple state-driven workflows |
| Privacy | Minimal profile information |
| Compliance | Privacy boundary aligned with applicable requirements |
| Historical Integrity | Actual workout data separated from plan data |
| Consistency | Shared validity rules for records, progress and statistics |
| Scope Control | No advanced scheduling, AI, social or health integrations |

---

# **10\. Traceability**

## **10.1 SRS-to-SDS Traceability Table**

| SRS Requirement | SDS Components | SDS Interfaces / Data / Design |
| ----- | ----- | ----- |
| SRS-FR-1 | SDS-COMP-1, 2, 3, 15 | SDS-IF-1, SDS-DATA-1, SDS-DATA-2 |
| SRS-FR-2 | SDS-COMP-1, 2, 15 | SDS-IF-2, SDS-IF-9 |
| SRS-FR-3 | SDS-COMP-2, 15 | SDS-IF-9 |
| SRS-FR-4 | SDS-COMP-2 | SDS-ERR-3 |
| SRS-FR-5 | SDS-COMP-2, 15 | SDS-IF-3, SDS-ERR-4 |
| SRS-FR-6 | SDS-COMP-1, 2 | SDS-IF-9 |
| SRS-FR-7 | SDS-COMP-4 | SDS-IF-14, SDS-DATA-3 |
| SRS-FR-8 | SDS-COMP-4, 12 | SDS-IF-4, SDS-DATA-8 |
| SRS-FR-9–14 | SDS-COMP-5, 12, 13, 14 | SDS-IF-4, SDS-DATA-4 |
| SRS-FR-15–24 | SDS-COMP-6, 12, 13 | SDS-IF-5, SDS-DATA-5 |
| SRS-FR-25–32 | SDS-COMP-7, 12 | SDS-IF-6, SDS-ERR-8 |
| SRS-FR-33–35 | SDS-COMP-8, 12, 13 | SDS-DATA-6 |
| SRS-FR-36–38 | SDS-COMP-9, 13, 14 | SDS-IF-7 |
| SRS-FR-39–41 | SDS-COMP-10, 11, 12 | SDS-IF-8, SDS-DATA-7 |
| SRS-FR-42–47 | SDS-COMP-11, 12 | SDS-IF-8, SDS-DATA-7 |
| SRS-FR-48–52 | SDS-COMP-12, 13, 14 | SDS-IF-10, SDS-DATA-8, SDS-ERR-7 |
| SRS-NFR-1 | SDS-COMP-1, 7 | SDS-NFR-1 |
| SRS-NFR-2 | SDS-COMP-7 | SDS-NFR-2 |
| SRS-NFR-3 | SDS-COMP-7, 13 | SDS-NFR-3 |
| SRS-NFR-4 | SDS-COMP-13, 14, 15 | SDS-NFR-6, 10, 12 |
| SRS-NFR-5 | SDS-COMP-10, 11, 12 | SDS-NFR-7 |
| SRS-NFR-6 | SDS-COMP-7, 8 | SDS-NFR-8 |
| SRS-NFR-7 | SDS-COMP-5, 6 | SDS-NFR-9 |
| SRS-NFR-8 | SDS-COMP-14, 15 | SDS-NFR-10 |
| SRS-NFR-9 | SDS-COMP-3 | SDS-NFR-11 |
| SRS-NFR-10 | SDS-COMP-14 | SDS-NFR-12 |
| SRS-NFR-11 | SDS-COMP-14 | SDS-NFR-13 |
| SRS-NFR-12 | SDS-COMP-1, 11 | SDS-NFR-14 |
| SRS-NFR-13 | SDS-COMP-1–12 | SDS-NFR-15 |
| SRS-NFR-14 | SDS-COMP-7 | SDS-NFR-16 |
| SRS-NFR-15 | SDS-COMP-12 | SDS-NFR-17 |
| SRS-NFR-16 | SDS-COMP-6 | SDS-NFR-18 |
| SRS-NFR-17 | SDS-COMP-13, 14 | SDS-NFR-4 |
| SRS-NFR-18 | SDS-COMP-1–14 | SDS-NFR-5 |

---

## **10.2 Full-Chain Traceability Table**

| BRD Requirement | SRS Requirement | SDS Design |
| ----- | ----- | ----- |
| BRD-FR-1 | SRS-FR-7 | SDS-COMP-4, SDS-DATA-3 |
| BRD-FR-2 | SRS-FR-8 | SDS-COMP-4, SDS-COMP-12 |
| BRD-FR-3–8 | SRS-FR-9–14 | SDS-COMP-5, SDS-DATA-4 |
| BRD-FR-9–18 | SRS-FR-15–24 | SDS-COMP-6, SDS-DATA-5 |
| BRD-FR-19–26 | SRS-FR-25–32 | SDS-COMP-7 |
| BRD-FR-27–29 | SRS-FR-33–35 | SDS-COMP-8, SDS-DATA-6 |
| BRD-FR-30–32 | SRS-FR-36–38 | SDS-COMP-9 |
| BRD-FR-33–35 | SRS-FR-39–41 | SDS-COMP-10 |
| BRD-FR-36–41 | SRS-FR-42–47 | SDS-COMP-11 |
| BRD-FR-42–46 | SRS-FR-48–52 | SDS-COMP-12 |
| BRD-NFR-1 | SRS-NFR-1 | SDS-NFR-1 |
| BRD-NFR-2 | SRS-NFR-2 | SDS-NFR-2 |
| BRD-NFR-3 | SRS-NFR-3 | SDS-NFR-3 |
| BRD-NFR-4 | SRS-NFR-4 | SDS-NFR-6 |
| BRD-NFR-5 | SRS-NFR-5 | SDS-NFR-7 |
| BRD-NFR-6 | SRS-NFR-6 | SDS-NFR-8 |
| BRD-NFR-7 | SRS-NFR-7 | SDS-NFR-9 |
| BRD-NFR-8 | SRS-NFR-8 | SDS-NFR-10 |
| BRD-NFR-9 | SRS-NFR-9 | SDS-NFR-11 |
| BRD-NFR-10 | SRS-NFR-10 | SDS-NFR-12 |
| BRD-NFR-11 | SRS-NFR-11 | SDS-NFR-13 |
| BRD-NFR-12 | SRS-NFR-12 | SDS-NFR-14 |
| BRD-NFR-13 | SRS-NFR-13 | SDS-NFR-15 |
| BRD-NFR-14 | SRS-NFR-14 | SDS-NFR-16 |
| BRD-NFR-15 | SRS-NFR-15 | SDS-NFR-17 |
| BRD-NFR-16 | SRS-NFR-16 | SDS-NFR-18 |
| BRD-NFR-17 | SRS-NFR-17 | SDS-NFR-4 |
| BRD-NFR-18 | SRS-NFR-18 | SDS-NFR-5 |

**Authentication requirements:** The authentication-specific design is derived from the finalized Authentication Module specification and is represented in SRS-FR-1–SRS-FR-6.

---

# **11\. Verification and Validation Criteria**

| Design Element | Verification Method | Acceptance Condition |
| ----- | ----- | ----- |
| SDS-COMP-1 | Architecture review \+ system test | Correct authenticated/unauthenticated application boundary |
| SDS-COMP-2 | Integration test | Registration, login, logout and reset operate correctly |
| SDS-COMP-3 | Integration test | Profile is created and associated with correct UID |
| SDS-COMP-4 | Integration test | Valid exercise catalogue can be read and cannot be modified by clients |
| SDS-COMP-5 | Functional test | Plans can be created, edited and deleted according to requirements |
| SDS-COMP-6 | Functional test | Valid schedules persist and invalid schedules are rejected |
| SDS-COMP-7 | System test | Active workout transitions operate without requiring timer network round trips |
| SDS-COMP-8 | Integration test | Completed sessions persist with actual performance |
| SDS-COMP-9 | System test | Only authenticated user's history is displayed |
| SDS-COMP-10 | Calculation test | Progress excludes invalid/incomplete records |
| SDS-COMP-11 | Calculation test | Statistics and PB results match approved calculation rules |
| SDS-COMP-12 | Unit \+ integration test | Invalid values cannot become valid persisted performance |
| SDS-COMP-13 | Integration test | All persistent application data uses Firestore |
| SDS-COMP-14 | Security test | Unauthorized user paths are rejected |
| SDS-COMP-15 | Security/integration test | Authentication is delegated to Firebase Authentication |
| SDS-IF-1 | UI/system test | Valid registration produces authenticated account state |
| SDS-IF-2 | UI/system test | Valid login reaches protected application |
| SDS-IF-3 | Integration test | Password reset request is successfully initiated |
| SDS-IF-4 | Functional test | Workout plan operations meet SRS behavior |
| SDS-IF-5 | Functional test | Scheduling operations meet SRS behavior |
| SDS-IF-6 | System test | Workout execution supports required state transitions |
| SDS-IF-7 | System test | Historical records are correctly retrieved |
| SDS-IF-8 | Calculation/system test | Progress/statistics display valid derived values |
| SDS-IF-9 | Integration test | Auth state controls protected application access |
| SDS-IF-10 | Unit/integration test | Invalid data is rejected |
| SDS-IF-11 | Integration test | Persistence failures are correctly surfaced |
| SDS-IF-12 | Calculation test | Derived statistics are consistent with valid records |
| SDS-IF-13 | Integration/security test | Firebase Authentication integration operates correctly |
| SDS-IF-14 | Integration/security test | Firestore read/write boundaries operate correctly |
| SDS-DATA-1 | Security test | UID uniquely identifies authenticated user |
| SDS-DATA-2 | Data test | Profile data is associated with correct UID |
| SDS-DATA-3 | Data test | Exercise references resolve to valid catalogue records |
| SDS-DATA-4 | Data test | Plan structures retain required target information |
| SDS-DATA-5 | Functional test | Schedule changes do not modify completed sessions |
| SDS-DATA-6 | Data integrity test | Actual session performance is independent of current plan |
| SDS-DATA-7 | Calculation test | Statistics derive only from valid records |
| SDS-DATA-8 | Validation test | Invalid data is rejected |
| SDS-NFR-1 | Performance benchmark | Normal application operations remain responsive |
| SDS-NFR-2 | Timing benchmark | Work/rest transitions remain timely and consistent |
| SDS-NFR-3 | Performance test | Recording does not introduce unnecessary interaction delays |
| SDS-NFR-4 | Architecture/security review | UID-based partitioning is consistently applied |
| SDS-NFR-5 | Architecture review | Components remain extensible without MVP scope expansion |
| SDS-NFR-6 | Reliability test | Successfully persisted records remain available |
| SDS-NFR-7 | Consistency test | Statistics agree with underlying valid records |
| SDS-NFR-8 | Interruption test | Interrupted activity cannot corrupt completed records |
| SDS-NFR-9 | Scheduling test | Invalid plan references cannot be persisted |
| SDS-NFR-10 | Security penetration test | Unauthorized access is rejected |
| SDS-NFR-11 | Privacy review | Only required profile information is collected |
| SDS-NFR-12 | Security test | Cross-user data access is rejected |
| SDS-NFR-13 | Compliance review | Data handling aligns with applicable requirements |
| SDS-NFR-14 | Product review | System does not provide clinical/medical interpretation |
| SDS-NFR-15 | Usability test | Core workflows are understandable |
| SDS-NFR-16 | Workout usability test | Workout recording minimizes unnecessary interaction |
| SDS-NFR-17 | Validation usability test | Invalid input produces clear feedback |
| SDS-NFR-18 | Scheduling usability test | Basic scheduling behaves predictably |
| SDS-ERR-1–9 | Negative-path integration/system tests | Defined failure states are handled without corrupting valid data |

---

# **12\. Appendix**

## **Appendix A — Authoritative Data Ownership Model**

Firebase Authentication  
        │  
        │ UID  
        ▼  
Cloud Firestore  
        │  
        ├── users/{uid}  
        │      │  
        │      ├── profile fields  
        │      │  
        │      ├── workoutPlans/{planId}  
        │      │  
        │      └── workoutSessions/{sessionId}  
        │  
        └── exercises/{exerciseId}

### **Ownership Rules**

Authenticated User  
       │  
       └── request.auth.uid  
                    │  
                    ▼  
              users/{uid}  
                    │  
          ┌─────────┴─────────┐  
          ▼                   ▼  
    workoutPlans       workoutSessions

The authenticated UID is the ownership boundary.

---

## **Appendix B — Authentication Boundary**

┌─────────────────────────┐  
│      Mobile Client      │  
│                         │  
│ Email \+ Password        │  
└────────────┬────────────┘  
             │  
             ▼  
┌─────────────────────────┐  
│ Firebase Authentication │  
│                         │  
│ Account                 │  
│ Password                │  
│ Session                 │  
│ UID                     │  
└────────────┬────────────┘  
             │  
             ▼  
       Authenticated UID  
             │  
             ▼  
┌─────────────────────────┐  
│     Cloud Firestore     │  
│                         │  
│ users/{uid}             │  
│ workoutPlans            │  
│ workoutSessions         │  
└─────────────────────────┘

**Password data does not cross into the Firestore application-data boundary.**

---

## **Appendix C — Persistence Constraint**

The Workout Tracker MVP has exactly one application persistence mechanism:

> **Cloud Firestore**

The mobile application does **not** use:

* SQLite  
* Realm  
* Core Data  
* Room  
* SharedPreferences for application records  
* Local workout database  
* Offline write queue  
* Synchronization engine

The absence of local persistence is intentional and forms part of the MVP architecture.

---

## **Appendix D — Historical Integrity Principle**

The architecture enforces the following separation:

                ┌────────────────────┐  
                 │   Workout Plan     │  
                 │   Planned Targets  │  
                 └─────────┬──────────┘  
                           │  
                       Start  
                           │  
                           ▼  
                 ┌────────────────────┐  
                 │ Active Workout     │  
                 │ Actual Performance │  
                 └─────────┬──────────┘  
                           │  
                       Complete  
                           │  
                           ▼  
                 ┌────────────────────┐  
                 │ Workout Session    │  
                 │ Historical Record  │  
                 └────────────────────┘

A subsequent change to the workout plan must not rewrite the historical session.

---

## **Appendix E — Architectural Baseline**

The following decisions are locked for SDS Version 1.0:

1. Firebase Authentication is the authentication boundary.  
2. Email/password is the only authentication mechanism.  
3. Cloud Firestore is the application data store.  
4. User-owned Firestore data is nested beneath `users/{uid}`.  
5. Exercise catalogue data is shared and client-read-only.  
6. Workout plans and workout sessions are separate logical entities.  
7. Actual workout performance is retained independently from plan targets.  
8. Statistics and progress are derived from valid completed workout records.  
9. No local database is used.  
10. No offline synchronization mechanism is used.  
11. No password is stored in Firestore.  
12. No new MVP capabilities are introduced by the SDS.

