GYMAI V0.6.4 — PRODUCTION WORKOUT & EXERCISE CATALOGUE DESIGN PROPOSAL

STATUS

Starting point:

* GymAI is committed at V0.6.3D.
* Existing workout execution, persistence, history, rest timer, resume, discard, and completion flows are stable.
* Existing domain hierarchy already includes Workout, WorkoutExercise, Exercise, ActiveWorkout, WorkoutSession, WorkoutExerciseResult, and workout-history records.
* V0.6.4 should extend this architecture additively.
* Existing workout lifecycle and persistence behaviour must not be rewritten as part of the catalogue foundation.

Primary goal:
Create a production-quality catalogue architecture that supports:

1. Curated GymAI programs and workouts.
2. A reusable exercise library.
3. Guided workout execution.
4. User-created and edited workouts.
5. Camera demonstrations and form guidance.
6. Exercise recognition and rep counting.
7. Free-Form AI Tracking.
8. Gender-specific customization where appropriate.
9. Localization across multiple languages.
10. Future remote catalogue updates without invalidating workout history.

The catalogue must be treated as product infrastructure, not as a larger sample-data file.

────────────────────────────────────────

1. CORE CATALOGUE HIERARCHY

The complete hierarchy should be:

Catalogue
└── Programs
└── Program Schedule Entries
└── Workouts
└── Workout Exercises
└── Exercises

The hierarchy has four primary domain levels.

A. PROGRAM

A Program is a structured training plan delivered over time.

Examples:

* Beginner Strength Foundation
* Women’s Lower Body Hypertrophy
* Men’s Upper Body Strength
* Fat-Loss Conditioning
* Mobility for Desk Workers
* Posture and Core Foundation
* Return-to-Training Foundation
* Football Pre-Season Conditioning

A Program owns:

* Identity and version.
* Localized title and description references.
* Goal.
* Intended audience.
* Experience level.
* Duration in weeks.
* Recommended sessions per week.
* Program schedule.
* Progression strategy.
* Equipment requirements.
* Estimated weekly time.
* Eligibility and caution information.
* Catalogue source and publication status.

A Program does not directly own exercise definitions. It references workouts through schedule entries.

B. PROGRAM SCHEDULE ENTRY

A Program Schedule Entry places a workout into a program schedule.

Examples:

* Week 1, Day 1: Full Body A
* Week 1, Day 3: Full Body B
* Week 2, Day 1: Full Body A with progression
* Optional Day: Recovery Mobility

A schedule entry should support:

* Week number.
* Day or sequence number.
* Referenced workout ID.
* Required, recommended, or optional status.
* Rest-day guidance.
* Program-specific workout overrides.
* Progression stage.
* Replacement or alternative workout IDs.
* Notes and coaching focus.

This separation allows the same workout template to appear in multiple programs without duplication.

C. WORKOUT

A Workout is an ordered training session template.

Examples:

* Full Body Beginner A
* Push Hypertrophy
* Lower Body Strength
* Low-Impact HIIT
* Morning Mobility Flow
* Beginner Pilates Core
* Knee-Friendly Leg Session

A Workout owns:

* Identity and version.
* Localized title and description references.
* Workout categories and goals.
* Ordered WorkoutExercise entries.
* Estimated duration.
* Difficulty.
* Intensity.
* Equipment requirements.
* Environment requirements.
* Session structure.
* Warm-up and cool-down references.
* Coaching mode compatibility.
* Camera-tracking compatibility.
* Adaptation and substitution rules.
* Source and ownership metadata.

A Workout may exist independently of a Program.

This supports:

* Standalone workouts.
* Program workouts.
* Recommended workouts.
* User-created workouts.
* AI-generated workouts.
* Imported coach workouts.

D. WORKOUT EXERCISE

A WorkoutExercise is a prescribed use of an Exercise inside one Workout.

This distinction is essential.

Exercise:
“Barbell Back Squat”

WorkoutExercise:
“Barbell Back Squat, 4 sets of 6 reps, 150-second rest, strength tempo, stop at RPE 8”

WorkoutExercise owns prescription data:

* Stable entry ID.
* Referenced exercise ID.
* Order.
* Section.
* Target sets.
* Target reps or rep range.
* Target duration.
* Target distance.
* Target calories.
* Target load or load guidance.
* Rest duration.
* Tempo.
* RPE or RIR target.
* Side handling.
* Set structure.
* Circuit or superset grouping.
* Progression rule.
* Coaching emphasis.
* Substitution options.
* Optional or required status.
* Program-specific notes.

An Exercise must not contain workout-specific sets, reps, rest, or load targets.

E. EXERCISE

An Exercise is the canonical reusable movement definition.

Examples:

* Bodyweight Squat
* Goblet Squat
* Barbell Back Squat
* Dumbbell Bench Press
* Running
* Jumping Jack
* Downward-Facing Dog
* Dead Bug
* Glute Bridge
* Side-Lying Hip Abduction

An Exercise owns:

* Stable identity.
* Localized naming references.
* Movement taxonomy.
* Muscles.
* Equipment.
* Mechanics.
* Measurement capabilities.
* Camera and AI metadata.
* Coaching rules.
* Demonstration assets.
* Safety information.
* Variations and relationships.
* Search aliases.
* Catalogue versioning.

────────────────────────────────────────

2. CATALOGUE CONTENT SOURCES

Every Program, Workout, WorkoutExercise, and Exercise should identify its source.

Recommended source type:

* builtIn
* gymAICloud
* userCreated
* coachCreated
* aiGenerated
* imported

Every catalogue item should also have:

* Stable UUID.
* Stable semantic key.
* Schema version.
* Content revision.
* Created date.
* Updated date.
* Publication status.
* Ownership.
* Editability.
* Deprecation status.
* Replacement ID when deprecated.

Stable semantic keys should be human-readable internal identifiers such as:

* exercise.bodyweight_squat
* exercise.barbell_back_squat
* workout.full_body_beginner_a
* program.beginner_strength_foundation

UUIDs remain the database identity.

Semantic keys support:

* Reliable localization.
* Analytics.
* Remote content updates.
* AI model mappings.
* Debugging.
* Migration.
* Test fixtures.

Built-in catalogue definitions should use deterministic identities. They must not generate new UUIDs every time WorkoutService is called.

────────────────────────────────────────

3. TOP-LEVEL WORKOUT CATEGORIES

A workout may belong to more than one category.

Primary categories:

* Strength
* Hypertrophy
* Muscular Endurance
* Cardio
* HIIT
* Circuit Training
* Cross-Training
* Functional Fitness
* Calisthenics
* Yoga
* Mobility
* Flexibility
* Pilates
* Core
* Balance
* Rehabilitation
* Prehabilitation
* Recovery
* Warm-Up
* Cool-Down
* Sports Performance
* Power
* Speed
* Agility
* Plyometrics
* Skill Practice
* Breathing
* Mind-Body

“Rehabilitation” content must be carefully scoped. GymAI should not represent itself as diagnosing or treating an injury. Such content should use:

* Clear suitability boundaries.
* Contraindication metadata.
* Professional-supervision recommendations.
* Non-medical language unless reviewed and approved for medical use.

Additional classification dimensions should remain separate from category:

Training goal:

* General Fitness
* Strength
* Muscle Gain
* Fat Loss
* Conditioning
* Endurance
* Mobility
* Flexibility
* Athletic Performance
* Balance
* Posture
* Recovery
* Return to Training
* Skill Development

Experience level:

* Beginner
* Novice
* Intermediate
* Advanced
* All Levels

Intensity:

* Very Low
* Low
* Moderate
* High
* Very High

Impact:

* No Impact
* Low Impact
* Moderate Impact
* High Impact

Environment:

* Gym
* Home
* Outdoors
* Studio
* Pool
* Track
* Court
* Field
* Office
* Travel

Session format:

* Straight Sets
* Superset
* Tri-Set
* Giant Set
* Circuit
* Interval
* EMOM
* AMRAP
* Tabata
* Timed Flow
* Continuous Cardio
* Skill Practice
* Recovery Flow

A single broad WorkoutType enum should not become the only classification mechanism. It can remain for backward compatibility, but the production catalogue should use richer category and attribute collections.

────────────────────────────────────────

4. EXERCISE TAXONOMY

Exercise taxonomy should be multidimensional rather than forcing each exercise into one category.

4.1 MOVEMENT FAMILY

* Squat
* Hinge
* Lunge
* Horizontal Push
* Vertical Push
* Horizontal Pull
* Vertical Pull
* Carry
* Rotation
* Anti-Rotation
* Flexion
* Extension
* Lateral Flexion
* Locomotion
* Jump
* Throw
* Climb
* Crawl
* Balance
* Mobility
* Stretch
* Breathwork
* Isometric Hold
* Cyclic Cardio
* Sport Skill

4.2 MOVEMENT PATTERN

More specific patterns under the family:

Squat:

* Bilateral Squat
* Split Squat
* Single-Leg Squat
* Lateral Squat

Hinge:

* Deadlift
* Romanian Deadlift
* Good Morning
* Hip Thrust
* Swing

Push:

* Bench Press
* Push-Up
* Overhead Press
* Dip
* Fly

Pull:

* Row
* Pull-Up
* Pulldown
* Face Pull
* Reverse Fly

Locomotion:

* Walk
* Run
* Sprint
* Cycle
* Rowing Ergometer
* Stair Climb
* Swim

Each Exercise should have one primary pattern and may have secondary patterns.

4.3 BODY REGION

* Full Body
* Upper Body
* Lower Body
* Core
* Neck
* Shoulder
* Chest
* Back
* Arms
* Forearms
* Hips
* Glutes
* Thighs
* Lower Legs
* Feet and Ankles

4.4 MUSCLE TAXONOMY

Each Exercise should record:

* Primary muscles.
* Secondary muscles.
* Stabilizers.
* Optional laterality where relevant.

Muscle groups should be more granular than the initial broad groups but should retain compatibility mappings.

Suggested muscle hierarchy:

Chest:

* Pectoralis Major
* Upper Chest
* Lower Chest
* Pectoralis Minor

Back:

* Latissimus Dorsi
* Trapezius
* Rhomboids
* Erector Spinae
* Teres Major

Shoulders:

* Anterior Deltoid
* Lateral Deltoid
* Posterior Deltoid
* Rotator Cuff

Arms:

* Biceps
* Brachialis
* Triceps
* Forearm Flexors
* Forearm Extensors

Core:

* Rectus Abdominis
* Transverse Abdominis
* Internal Obliques
* External Obliques
* Multifidus
* Quadratus Lumborum

Lower Body:

* Gluteus Maximus
* Gluteus Medius
* Gluteus Minimus
* Quadriceps
* Hamstrings
* Adductors
* Hip Flexors
* Gastrocnemius
* Soleus
* Tibialis Anterior

The UI may continue showing friendly grouped names while internal metadata uses precise identifiers.

4.5 EQUIPMENT

* Bodyweight
* Barbell
* Dumbbell
* Kettlebell
* Weight Plate
* Resistance Band
* Cable
* Smith Machine
* Selectorized Machine
* Plate-Loaded Machine
* Bench
* Rack
* Pull-Up Bar
* Dip Bars
* Suspension Trainer
* Medicine Ball
* Stability Ball
* Bosu
* Foam Roller
* Yoga Mat
* Yoga Block
* Pilates Ring
* Reformer
* Cardio Machine
* Treadmill
* Exercise Bike
* Rowing Machine
* Elliptical
* Stair Machine
* Sled
* Battle Rope
* Plyometric Box
* Agility Ladder
* Cone
* Landmine
* Trap Bar
* EZ Bar
* None

An Exercise should support:

* Required equipment.
* Optional equipment.
* Alternative equipment.
* Equipment setup notes.

4.6 MECHANICS

* Compound
* Isolation
* Cyclic
* Isometric
* Mobility
* Stretch
* Skill

4.7 FORCE AND DIRECTION

Force:

* Push
* Pull
* Push and Pull
* Hold
* Locomotion
* Rotation

Plane:

* Sagittal
* Frontal
* Transverse
* Multiplanar

Kinetic chain:

* Open Chain
* Closed Chain
* Mixed

4.8 POSITION

* Standing
* Seated
* Supine
* Prone
* Side-Lying
* Kneeling
* Half-Kneeling
* Quadruped
* Hanging
* Supported
* Inverted
* Moving

4.9 LATERALITY

* Bilateral
* Unilateral
* Alternating
* Independent Bilateral
* Not Applicable

4.10 DIFFICULTY AND SKILL

Exercise difficulty:

* Foundational
* Beginner
* Intermediate
* Advanced
* Expert

Technical demand:

* Low
* Moderate
* High
* Very High

Mobility demand:

* Low
* Moderate
* High

Balance demand:

* Low
* Moderate
* High

4.11 IMPACT AND CONTRAINDICATION TAGS

* No Impact
* Low Impact
* High Impact
* Overhead
* Deep Knee Flexion
* Loaded Spinal Flexion
* Loaded Spinal Extension
* High Balance Demand
* High Grip Demand
* High Shoulder Demand
* High Hip Mobility Demand
* High Ankle Mobility Demand

These are filtering and coaching signals, not medical diagnoses.

────────────────────────────────────────

5. EXERCISE MEASUREMENT MODEL

GymAI must not assume every exercise is counted only through sets and reps.

Each Exercise should declare one or more supported measurement types:

* Repetitions
* Duration
* Distance
* Load
* Calories
* Pace
* Speed
* Heart Rate
* Power
* Rounds
* Breath Cycles
* Hold Duration
* Steps
* Laps
* Free Practice

Examples:

Barbell Back Squat:

* Sets
* Repetitions
* Load
* Tempo
* RPE or RIR

Plank:

* Sets
* Hold Duration

Running:

* Duration
* Distance
* Pace
* Heart Rate

Yoga Flow:

* Duration
* Sequence completion
* Breath cycles

AMRAP:

* Duration
* Rounds
* Repetitions per movement

WorkoutExercise prescriptions should therefore use a target structure rather than relying permanently on only targetSets and targetReps.

Backward-compatible existing fields can remain while a future generalized prescription model is added.

────────────────────────────────────────

6. SET AND SESSION STRUCTURE

A production workout catalogue must support:

* Standard sets.
* Warm-up sets.
* Working sets.
* Back-off sets.
* Drop sets.
* Rest-pause sets.
* Cluster sets.
* Pyramid sets.
* Reverse pyramid sets.
* Timed sets.
* AMRAP sets.
* EMOM intervals.
* Circuit rounds.
* Supersets.
* Tri-sets.
* Giant sets.
* Unilateral side-specific sets.
* Assisted or partner sets.
* Failure-optional sets.

Recommended structure:

Workout

* Sections

  * Warm-Up
  * Main
  * Accessory
  * Conditioning
  * Cool-Down

Each WorkoutExercise references:

* Section ID.
* Sequence.
* Group ID.
* Group type.
* Order within group.

This avoids hard-coding supersets or circuits into unrelated Exercise definitions.

────────────────────────────────────────

7. EXERCISE RELATIONSHIPS

Exercises should form a relationship graph.

Relationship types:

* variationOf
* progressionFrom
* regressionFrom
* substituteFor
* unilateralVersionOf
* bilateralVersionOf
* equipmentAlternativeTo
* easierAlternativeTo
* harderAlternativeTo
* mobilityPreparationFor
* contraindicatedAlternativeTo
* commonlyConfusedWith
* aiRecognitionSiblingOf

Examples:

Goblet Squat:

* variationOf Bodyweight Squat
* regressionFrom Barbell Front Squat
* substituteFor Barbell Back Squat when equipment is unavailable

Dumbbell Bench Press:

* equipmentAlternativeTo Barbell Bench Press

Incline Push-Up:

* easierAlternativeTo Push-Up

Romanian Deadlift:

* commonlyConfusedWith Conventional Deadlift
* aiRecognitionSiblingOf Stiff-Leg Deadlift

These relationships will support:

* Exercise substitutions.
* Program adaptation.
* Equipment-aware recommendations.
* AI ambiguity resolution.
* Search.
* Coaching progression.

────────────────────────────────────────

8. GUIDED WORKOUT MODE

Guided Workouts begin from a known Workout template.

The system knows:

* Planned exercise order.
* Prescribed sets and targets.
* Expected transitions.
* Rest durations.
* Valid substitutions.
* Expected recognition candidates.

This context should improve camera recognition.

For each WorkoutExercise, Guided Mode should be able to determine:

* Whether camera tracking is supported.
* Expected exercise recognition profile.
* Expected body orientation.
* Recommended camera placement.
* Required visible joints.
* Rep counting method.
* Form metrics.
* Coaching cues.
* Setup instructions.
* Known ambiguity candidates.
* Fallback manual tracking behaviour.

Guided Mode should treat the planned exercise as a strong prior, but it must not blindly assume the user is performing it.

Example:
The workout expects a Dumbbell Shoulder Press, but the camera strongly detects a Dumbbell Lateral Raise. GymAI should:

* Surface a low-friction correction during or after the set.
* Preserve observations.
* Avoid incorrectly applying shoulder-press metrics to lateral raises.

────────────────────────────────────────

9. FREE-FORM AI TRACKING MODE

Free-Form AI Tracking starts without selecting a workout or exercise.

The user starts camera tracking and trains naturally.

The detection pipeline should conceptually produce:

Session
└── Detected Exercise Segments
└── Detected Sets
└── Detected Repetitions or Timed Activity

A. RAW OBSERVATION LAYER

The AI layer records observations independently from the final catalogue interpretation.

Raw observations may include:

* Timestamps.
* Pose landmarks.
* Joint angles.
* Motion vectors.
* Body orientation.
* Repetition boundaries.
* Rest or inactivity intervals.
* Equipment indicators.
* Range-of-motion features.
* Movement tempo.
* Side detection.
* Model outputs.
* Candidate exercise IDs.
* Confidence or probability values.
* Model version.

This raw layer must not be represented as a finalized WorkoutExerciseResult.

B. DETECTION CANDIDATE LAYER

Each detected segment should contain:

* Segment ID.
* Start time.
* End time.
* Candidate exercise IDs.
* Ranked internal candidate scores.
* Detected set count.
* Detected repetition counts.
* Rest intervals.
* Side information.
* Equipment observations.
* Form observations.
* Review status.

Internal confidence scores may be stored for system decisions and debugging.

C. AMBIGUITY POLICY

The confirmed product behaviour is:

* Do not display a confidence percentage when two exercises are plausibly ambiguous.
* Track both candidate interpretations during the session.
* Preserve observations that can apply to either candidate.
* At the end, ask the user which exercise was performed.
* After the choice, apply the observations to the selected exercise.
* Save only the finalized interpretation to normal workout history.
* Retain internal provenance so GymAI knows the result was user-resolved.

Example:

Candidate A:

* Romanian Deadlift

Candidate B:

* Stiff-Leg Deadlift

At session review:
“Which exercise did you perform?”

* Romanian Deadlift
* Stiff-Leg Deadlift
* Something else

D. TRANSITION DETECTION

Free-Form mode should detect a transition when:

* Motion pattern changes significantly.
* Equipment changes.
* Body orientation changes.
* A sustained rest interval occurs.
* A new candidate becomes dominant.
* The user manually marks the next exercise.

Transitions should not immediately finalize an exercise. They delimit provisional segments.

E. END-OF-SESSION REVIEW

The review should show only items requiring attention:

* Ambiguous exercise segments.
* Unknown exercises.
* Implausible rep counts.
* Merged or split segment suggestions.
* Side mismatch.
* Duplicate transition.
* Very short accidental segments.

High-confidence detections should be finalized automatically without asking the user to approve every exercise.

The user should be able to:

* Select the correct exercise.
* Search the catalogue.
* Merge segments.
* Split a segment.
* Edit reps or sets.
* Delete accidental detections.
* Mark an activity as untracked.
* Create a custom exercise when permitted.

F. FINALIZATION

After review:

1. Resolve each segment to a canonical Exercise ID.
2. Convert observations into finalized exercise results.
3. Create a completed workout-history session.
4. Mark source mode as freeFormAI.
5. Preserve detection provenance separately.
6. Save user corrections as future personalization signals, subject to privacy settings.

The finalized history should use the same user-facing history architecture as Guided Workouts, with source metadata distinguishing:

* guided
* freeFormAI
* manual
* imported

────────────────────────────────────────

10. AI RECOGNITION METADATA

Each Exercise should include an AI capability profile.

Recommended capability states:

* unsupported
* planned
* demoOnly
* poseTrackable
* repCountable
* formCoachable
* fullySupported

The capability profile should describe:

Recognition:

* Recognition profile ID.
* Supported model versions.
* Similar exercise candidates.
* Required equipment cues.
* Minimum visible body landmarks.
* Supported camera angles.
* Unsupported camera angles.
* Minimum framing requirements.

Rep counting:

* Counting strategy.
* Start-position criteria.
* End-position criteria.
* Repetition state machine ID.
* Partial-rep handling.
* Hold detection.
* Left/right handling.
* Minimum movement threshold.

Form coaching:

* Observable metrics.
* Acceptable ranges.
* Severity thresholds.
* Cue priority.
* Cue cooldown.
* Positive reinforcement cues.
* Unsafe-pattern escalation.
* Limitations.

Camera:

* Recommended distance.
* Recommended height.
* Portrait or landscape support.
* Front, side, rear, or oblique view.
* Full-body or partial-body requirement.
* Device placement instructions.

Recognition profiles should be referenced by ID rather than embedding all model logic inside Exercise.

This allows AI implementation to evolve independently from catalogue content.

────────────────────────────────────────

11. COACHING METADATA

Exercise coaching should use structured information rather than one unstructured description.

Each Exercise may define:

Setup cues:

* Foot position.
* Grip.
* Equipment setup.
* Starting posture.
* Camera setup.

Execution cues:

* Movement intent.
* Breathing.
* Tempo.
* Range of motion.
* Stability.

Completion cues:

* End position.
* Lockout or non-lockout guidance.
* Controlled return.

Common mistakes:

* Machine-readable mistake ID.
* Localized explanation.
* Severity.
* Corrective cue.
* Required observable metrics.
* Suitable camera views.

Safety notes:

* General caution.
* Stop conditions.
* Equipment safety.
* Spotter recommendation.
* Professional-guidance recommendation.

Coaching cues should have:

* Localization keys.
* Priority.
* Applicability conditions.
* Cooldown behaviour.
* Positive or corrective type.

────────────────────────────────────────

12. DEMONSTRATION AND MEDIA MODEL

Exercise media must not be represented by one hard-coded image name.

Each Exercise should support multiple media assets:

* Thumbnail.
* Static illustration.
* Animated demonstration.
* Short video.
* Front-view video.
* Side-view video.
* Rear-view video.
* Setup image.
* Camera-placement image.
* Muscle diagram.
* Accessibility transcript.
* Audio instruction.

Each asset should record:

* Asset ID.
* Asset type.
* Local or remote source.
* Locale applicability.
* Gender presentation where relevant.
* Body-view orientation.
* Equipment variation.
* Resolution.
* Duration.
* Revision.
* Download status.
* Accessibility text.
* Rights or attribution metadata.

Gender-specific demonstration assets may be provided where they improve:

* Relatability.
* Clothing or camera-visibility guidance.
* Pregnancy or postpartum suitability.
* Anatomical coaching relevance.
* Program positioning.

Core exercise mechanics should not be duplicated into separate male and female Exercise records unless the movement itself genuinely differs.

────────────────────────────────────────

13. GENDER-SPECIFIC CUSTOMIZATION

Gender-related support should be implemented as contextual metadata and recommendation logic, not broad duplication of the entire catalogue.

Potentially relevant dimensions:

* Demonstration presenter options.
* Program recommendations.
* Goal defaults.
* Equipment or load guidance presentation.
* Pelvic-floor considerations.
* Pregnancy and postpartum suitability.
* Menstrual-cycle-aware planning as an optional future feature.
* Anatomically relevant coaching cues.
* Body-composition language.
* Privacy-respecting profile preferences.

Every Program and Workout may define:

* Intended audience.
* Suitable audiences.
* Excluded or caution audiences.
* Gender-neutral status.
* Optional gender-specific variants.

The user must be able to select gender-neutral content and should not be forced into gender-specific programming.

Medical or reproductive-health customization requires separate expert review before release.

────────────────────────────────────────

14. LOCALIZATION ARCHITECTURE

Catalogue objects should not persist English display text as their only canonical content.

Recommended fields:

* titleLocalizationKey
* shortDescriptionLocalizationKey
* longDescriptionLocalizationKey
* instructionLocalizationKeys
* aliasLocalizationKeys
* coachingCueLocalizationKeys
* safetyLocalizationKeys

Initial planned languages:

* English
* Hindi
* Kannada
* Arabic
* Spanish

Localization design must support:

* Right-to-left layouts for Arabic.
* Locale-specific search aliases.
* Locale-specific exercise synonyms.
* Pluralization.
* Unit formatting.
* Number formatting.
* Voice instruction localization.
* Different word order in formatted coaching cues.

Built-in catalogue content should use String Catalog keys.

Remote catalogue content may eventually use localized content bundles, but the domain model should present a consistent localization interface.

Exercise identity must remain language-independent.

Example:
The same Exercise ID represents “Barbell Back Squat” in English and its translated names in all other locales.

────────────────────────────────────────

15. SEARCH AND DISCOVERY METADATA

Users should be able to search exercises and workouts using:

* Display name.
* Alternative names.
* Common gym names.
* Abbreviations.
* Muscle groups.
* Movement patterns.
* Equipment.
* Goal.
* Category.
* Difficulty.
* Body region.
* Camera support.
* Duration.
* Location.
* User favourites.
* Recently performed.
* AI-detected candidate names.

Exercise aliases should support entries such as:

* Romanian Deadlift
* RDL
* Dumbbell RDL
* Stiff-Leg Variation

Aliases must be locale-aware and must not create separate Exercise identities.

Filtering should use structured metadata, not text matching alone.

────────────────────────────────────────

16. USER-CREATED WORKOUTS

User-created Workout records should reuse canonical Exercise IDs wherever possible.

Users should be able to:

* Create a workout.
* Name and describe it.
* Add catalogue exercises.
* Reorder exercises.
* Configure sets, reps, duration, load guidance, rest, and notes.
* Build supersets or circuits.
* Choose substitutions.
* Duplicate an existing workout.
* Archive a workout.
* Edit future sessions without altering past history.

User-created workouts should have:

* source = userCreated
* owner ID
* editable = true
* local revision
* optional sync metadata

Past WorkoutSessions must persist an immutable snapshot of the workout as performed.

Editing a user-created workout later must not rewrite previous history.

────────────────────────────────────────

17. CUSTOM EXERCISES

Custom exercises should be supported carefully.

A user-created Exercise may define:

* Name.
* Description.
* Category.
* Muscle groups.
* Equipment.
* Measurement type.
* Unilateral status.
* Notes.
* Optional media.

Custom exercises should initially default to:

* Camera recognition unsupported.
* Rep counting manual.
* Form coaching unsupported.

Future options may allow users or coaches to map a custom exercise to a known canonical movement profile, but this should not be assumed automatically.

If Free-Form AI cannot identify a movement, the user may:

* Choose an existing catalogue exercise.
* Save it as an unclassified activity.
* Create a custom exercise.

────────────────────────────────────────

18. VERSIONING AND HISTORY INTEGRITY

Catalogue records will evolve. Workout history must remain historically accurate.

Required rules:

1. Stable IDs never change because a title or description changes.
2. Catalogue updates create a new content revision.
3. Deprecated exercises remain resolvable for old history.
4. Replacement exercises are linked, not silently substituted.
5. WorkoutSession persists the performed workout snapshot.
6. Workout history persists exercise names or snapshot content needed for display.
7. New catalogue metadata may enhance old history but must not alter recorded results.
8. AI model versions must be saved with AI-derived observations.
9. User corrections must record whether a result was manually changed.

Recommended revision fields:

* schemaVersion
* contentRevision
* aiProfileRevision
* updatedAt
* deprecatedAt
* replacementID

────────────────────────────────────────

19. DOMAIN BOUNDARIES

The catalogue foundation should preserve separation between:

Catalogue definitions:

* Program
* ProgramScheduleEntry
* Workout
* WorkoutExercise
* Exercise

Runtime state:

* ActiveWorkout
* Active set state
* Rest state
* Camera state
* Detection state

Persistence records:

* WorkoutEntity
* WorkoutSessionEntity
* WorkoutHistoryEntity
* Future catalogue entities or serialized catalogue snapshots

AI observations:

* Tracking session
* Detection segment
* Candidate
* Rep observation
* Form observation
* Review decision

User profile and recommendations:

* Goals
* Experience
* Equipment access
* Preferences
* Restrictions
* Gender-related preferences
* History-derived recommendations

Catalogue models must not absorb runtime camera state or user-specific progress.

────────────────────────────────────────

20. RECOMMENDED FUTURE DOMAIN TYPES

The following conceptual types are recommended. This is not yet an instruction to add them all in one milestone.

Catalogue:

* WorkoutCatalogue
* Program
* ProgramScheduleEntry
* Workout
* WorkoutSection
* WorkoutExercise
* Exercise
* ExerciseRelationship
* ExerciseMediaAsset
* ExerciseAICapability
* ExerciseCoachingProfile

Classification:

* WorkoutCategory
* TrainingGoal
* ExperienceLevel
* IntensityLevel
* ImpactLevel
* SessionFormat
* MovementFamily
* MovementPattern
* Muscle
* MuscleRole
* Equipment
* ExerciseMechanics
* ForceType
* MovementPlane
* KineticChain
* BodyPosition
* Laterality
* MeasurementType

Prescription:

* ExercisePrescription
* SetPrescription
* RepTarget
* DurationTarget
* LoadTarget
* EffortTarget
* TempoPrescription
* RestPrescription
* ExerciseGroup

AI tracking:

* TrackingMode
* AITrackingSession
* DetectedExerciseSegment
* ExerciseDetectionCandidate
* DetectedSet
* DetectedRep
* FormObservation
* DetectionReviewDecision
* DetectionProvenance

Ownership and versioning:

* CatalogueSource
* CatalogueOwnership
* ContentRevision
* PublicationStatus

Names may be refined during implementation after reviewing the actual source tree.

────────────────────────────────────────

21. CATALOGUE SERVICE ARCHITECTURE

The current WorkoutService should not permanently remain both:

* Catalogue storage.
* Sample-data generator.
* Workout recommendation service.

Recommended responsibilities:

WorkoutCatalogueRepository:

* Return programs.
* Return workouts.
* Return exercises.
* Resolve IDs.
* Search and filter.
* Apply built-in and future remote revisions.

WorkoutRecommendationService:

* Recommend programs or workouts from profile and history.

WorkoutBuilderService:

* Create or edit user workouts.

ExerciseSubstitutionService:

* Find compatible alternatives using structured relationships.

AIExerciseResolver:

* Convert AI candidates and user decisions into canonical Exercise IDs.

For the first additive implementation, these responsibilities do not need separate production services immediately. The domain should nevertheless avoid designs that make later separation difficult.

────────────────────────────────────────

22. INITIAL BUILT-IN CATALOGUE SCOPE

V0.6.4 should establish architecture with a controlled, representative dataset rather than attempting hundreds of exercises immediately.

Recommended initial exercise coverage:

Strength and hypertrophy:

* Bodyweight Squat
* Goblet Squat
* Barbell Back Squat
* Romanian Deadlift
* Conventional Deadlift
* Glute Bridge
* Hip Thrust
* Forward Lunge
* Reverse Lunge
* Bench Press
* Dumbbell Bench Press
* Push-Up
* Overhead Press
* Dumbbell Shoulder Press
* Lateral Raise
* Bent-Over Row
* One-Arm Dumbbell Row
* Lat Pulldown
* Pull-Up
* Biceps Curl
* Triceps Pushdown
* Calf Raise

Core:

* Plank
* Side Plank
* Dead Bug
* Bird Dog
* Sit-Up
* Crunch
* Russian Twist

Cardio and HIIT:

* Walking
* Running
* Cycling
* Rowing
* Jumping Jack
* High Knees
* Mountain Climber
* Burpee
* Box Step-Up
* Jump Rope

Mobility and yoga:

* Cat-Cow
* Child’s Pose
* Downward-Facing Dog
* Cobra Pose
* World’s Greatest Stretch
* Hip Flexor Stretch
* Hamstring Stretch
* Thoracic Rotation
* Ankle Dorsiflexion Mobilization

Pilates:

* Pilates Hundred
* Single-Leg Stretch
* Double-Leg Stretch
* Pilates Bridge
* Side-Lying Leg Lift

Foundational recovery and prehabilitation:

* Wall Slide
* Band Pull-Apart
* Face Pull
* Clamshell
* Side-Lying Hip Abduction
* Terminal Knee Extension
* Scapular Push-Up

These exercises provide enough diversity to validate:

* Repetition counting.
* Hold timing.
* Cyclic cardio.
* Unilateral movement.
* Equipment alternatives.
* Similar-exercise ambiguity.
* Mobility and non-repetition content.
* Camera capability differences.

────────────────────────────────────────

23. INITIAL PROGRAM AND WORKOUT STRUCTURE

Recommended initial programs:

1. Beginner Strength Foundation

* Full Body A
* Full Body B
* Recovery Mobility

2. Push/Pull/Legs Foundation

* Push
* Pull
* Legs
* Optional Core and Mobility

3. Home Fitness Foundation

* Bodyweight Strength
* Low-Impact Conditioning
* Mobility Flow

4. Beginner Mobility Foundation

* Lower Body Mobility
* Upper Body Mobility
* Full Body Recovery Flow

These are sufficient to validate Program → Workout relationships without over-expanding product content.

The existing sample workouts:

* Full Body Beginner
* Push Day
* Pull Day
* Leg Day

should be migrated conceptually into the new catalogue rather than discarded abruptly.

Their current stable behaviour should remain available during incremental implementation.

────────────────────────────────────────

24. V0.6.4 IMPLEMENTATION PHASING

V0.6.4 should be split into small stable milestones.

V0.6.4A — Catalogue Taxonomy Foundation

Scope:

* Define catalogue design in project documentation.
* Add additive taxonomy types required by the first catalogue.
* Preserve current WorkoutType compatibility.
* No UI redesign.
* No persistence migration unless strictly required.
* No AI runtime implementation.

Verification:

* Build all platforms.
* Full test suite.
* Unit tests for taxonomy identity and Codable behaviour.
* Existing workout flow manual verification.

V0.6.4B — Exercise Metadata Foundation

Scope:

* Add structured exercise metadata additively.
* Preserve existing Exercise initializer compatibility.
* Introduce deterministic built-in exercise IDs or semantic keys.
* Add a small representative exercise library.
* Keep current workouts operational.

Verification:

* Build.
* Full tests.
* Catalogue uniqueness tests.
* Exercise lookup tests.
* Existing session/history snapshot verification.

V0.6.4C — Workout Catalogue Foundation

Scope:

* Replace ad-hoc sample generation with a deterministic catalogue provider.
* Represent current workouts through canonical Exercise references.
* Preserve current Workout domain and UI contracts where possible.
* Add catalogue validation.

Verification:

* Build.
* Full tests.
* Confirm no duplicate UUID generation between catalogue loads.
* Manual Library → Details → Session → History flow.

V0.6.4D — Program Foundation

Scope:

* Introduce Program and ProgramScheduleEntry.
* Add initial programs.
* Do not yet overhaul Home recommendations.
* Keep Programs separate from existing workout execution.

Verification:

* Build.
* Full tests.
* Program schedule validation.
* Manual catalogue browsing if UI is introduced.

V0.6.4E — Catalogue UI Expansion

Scope:

* Browse by Programs and Workouts.
* Exercise library search and filters.
* Workout details display richer metadata.
* Preserve current start/resume lifecycle.

Verification:

* Build.
* Full tests.
* Manual compact iPhone, macOS, and visionOS-compatible layout review.
* Accessibility and localization review.

Free-Form AI Tracking should be a later milestone built on top of this foundation. V0.6.4 should design for it but not prematurely implement camera detection storage inside catalogue types.

────────────────────────────────────────

25. CATALOGUE VALIDATION RULES

A production catalogue should fail validation during development when:

* IDs are duplicated.
* Semantic keys are duplicated.
* Localization keys are missing.
* A WorkoutExercise references an unknown Exercise.
* A Program references an unknown Workout.
* Set or rep targets are invalid.
* Rest durations are negative.
* Required equipment is inconsistent.
* A relationship references an unknown Exercise.
* A deprecated item has an invalid replacement.
* A camera-capable exercise lacks its AI profile.
* A workout has no executable entries.
* A circuit or superset grouping is malformed.
* An exercise declares incompatible measurement types.
* Search aliases collide in ways that create ambiguous canonical mappings.

Validation should be unit-testable and runnable in debug builds.

────────────────────────────────────────

26. NON-GOALS FOR THE FIRST CHANGE

The first V0.6.4 implementation must not:

* Rewrite WorkoutRepository.
* Rewrite WorkoutPersistence.
* Change active-session ownership.
* Change Continue or Start Fresh behaviour.
* Change workout completion.
* Change history mapping.
* Add remote networking.
* Add camera recognition.
* Add an AI model.
* Add hundreds of exercises.
* Add medical claims.
* Replace all existing enums in one change.
* Break backward-compatible initializers.
* Perform a broad folder restructure.

The first change should establish one narrow foundation and preserve the stable V0.6.3D lifecycle.

────────────────────────────────────────

27. RECOMMENDED FIRST ADDITIVE CHANGE

The safest first implementation milestone is V0.6.4A:

“Add the catalogue taxonomy foundation and catalogue design documentation without changing runtime workout behaviour.”

Recommended contents:

* A project catalogue design document.
* New additive classification enums or value types.
* Stable semantic-key convention.
* Catalogue source and version metadata types.
* Unit tests covering raw values, Codable round trips, uniqueness expectations, and backward compatibility.
* No modification to workout persistence or session lifecycle.
* No replacement of WorkoutService yet.

This creates an architectural vocabulary before changing Exercise or Workout storage.

────────────────────────────────────────

28. DEFINITION OF DONE FOR THE CATALOGUE FOUNDATION

The catalogue foundation is production-ready when:

* Programs, Workouts, Workout Exercises, and Exercises have clear separate responsibilities.
* Canonical exercises use stable identities.
* Workouts reference reusable exercises.
* The system supports multiple workout categories and goals.
* Exercise taxonomy is multidimensional.
* Prescriptions are extensible beyond simple sets and reps.
* Existing guided workout behaviour remains stable.
* Catalogue records are localizable.
* User-created workouts can eventually reuse canonical exercises.
* Past history remains immutable when catalogue content changes.
* Camera and coaching capabilities are declared as metadata.
* AI observations remain separate from canonical catalogue records.
* Free-Form detections can resolve to catalogue Exercise IDs.
* Ambiguous detections can retain multiple candidates and be resolved only at session review.
* Finalized Guided and Free-Form sessions can share the same history experience.
* Catalogue integrity is validated by automated tests.
* Each implementation step follows:
  one small additive change → build → full test suite → manual verification → commit only after a stable milestone.

FINAL ARCHITECTURAL DECISION

GymAI should use a canonical, versioned Exercise Catalogue as the shared language across curated programs, guided workouts, user-created workouts, demonstrations, camera tracking, AI coaching, free-form detection, and workout history.

Programs organize time.
Workouts define sessions.
Workout Exercises define prescriptions.
Exercises define movements.
AI tracking produces observations.
Review resolves observations to canonical exercises.
History stores the finalized workout as performed.

This separation gives GymAI a scalable foundation without destabilizing the completed V0.6.3D workout lifecycle.

