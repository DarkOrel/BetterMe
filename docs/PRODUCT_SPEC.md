# Fitness AI - Product Specification

**Version:** 1.0  
**Last Updated:** 2024  
**Status:** Phase 0 - Local-Only Mode

## Project Vision

A **gym-only fitness coach** app that acts as a "personal trainer in your pocket" for people who train in a gym. The app combines:

- **PPL Training** (Push / Pull / Legs) with balanced weekly volume
- **Nutrition Tracking** (calories + macros)
- **AI-based Recommendations** and program building
- **Research-based Principles** (volume per muscle, recovery, etc.)
- **2D Muscle Map** that visualizes weekly training load

### Target Users

- Men and women of all ages who train in a gym
- Both beginners and advanced lifters

### High-Level Goal

Help users grow muscle / cut fat in a **smart**, **structured**, and **data-based** way, without needing a full-time personal trainer.

---

## Phase 0 - Current Priority

**Focus:** Stability and clean architecture

1. ✅ App MUST RUN STABLY on device
2. ✅ Authentication is local-only / stubbed
3. ✅ AI is stubbed / mocked
4. ✅ Nutrition DB calls are mocked
5. ✅ Clean navigation flow
6. ✅ Stable screens for:
   - Onboarding
   - Home / Dashboard
   - Training day screen (P / P / L)
   - Basic logging of sets / reps / weight
7. ✅ No crashes, no infinite spinners

**Later (Phase 1+):**
- Re-enable real Firebase backend
- Add real AI integration
- Add real barcode / image food recognition

---

## Feature Blocks

The app is built around these pillars:

1. **TRAINING** (GYM, PPL Balanced)
2. **NUTRITION** (Calories + macros)
3. **AI COACH** (dynamic recommendations)
4. **MUSCLE MAP 2D** (visual load)
5. **PROGRESS TRACKING**
6. **MONETIZATION** (Free + Premium)

---

## 1. TRAINING – PPL (PUSH / PULL / LEGS ONLY)

### Core Behaviors

- User chooses:
  - Trainings per week: 2–6
  - Goal: BULK / CUT / MAINTAIN
  - Experience: beginner / intermediate / advanced

- App builds a **PPL schedule**:
  - Example (4 days): Push / Pull / Legs / Push
  - Example (5 days): Push / Pull / Legs / Push / Pull

- For each training day:
  - Exercises list (compound + accessories)
  - Each exercise has:
    - Sets
    - Reps
    - RPE (optional now, but plan for it)
    - Logged weight per set

### User Capabilities

- Replace an exercise with another targeting same muscle group
- Add custom exercises
- Remove exercises
- Even if user edits, the app should internally track muscle load per muscle group

### Data Model

```
Exercise
  - id
  - name
  - mainMuscleGroup (Chest, Back, Quads, etc.)
  - secondaryMuscles
  - type (compound / isolation)

WorkoutDay
  - date
  - type (Push / Pull / Legs)
  - exercises: List<WorkoutExercise>

WorkoutExercise
  - exerciseId
  - sets: List<SetLog>

SetLog
  - setIndex
  - reps
  - weight
  - rpe (nullable for now)
```

### Implementation Notes

- Code should make it EASY later to:
  - Compute weekly sets per muscle
  - Compute total volume (weight × reps)

**Current Implementation:**
- `ExerciseModel` - represents exercise template
- `SetModel` - represents individual set log
- `WorkoutModel` - represents a workout session
- Note: Current `ExerciseModel` has `sets` (int) and `reps` (int) directly. For Phase 0, this is acceptable, but future refactoring should align with spec's `WorkoutExercise` + `SetLog` structure.

---

## 2. NUTRITION

### Goal

Combine training with nutrition in one place.

### User Base Data

- Height
- Weight
- Age
- Sex
- Activity level

### Calculations

- BMR + TDEE
- Based on goal (bulk / cut / maintain):
  - Suggests daily calories
  - Suggests macros:
    - Protein / Carbs / Fats targets

### Daily Nutrition Tracking – 3 Input Modes

1. **Barcode scan**
   - User scans a product
   - App fetches: Calories, Protein / Carbs / Fats
   - Adds it to the daily log

2. **Photo of meal**
   - User takes a photo
   - AI tries to detect: Food types, Estimated calories + macros
   - User can edit before saving

3. **Manual add**
   - User searches / types a food
   - Chooses from DB or enters calories + macros manually

### Daily Summary

- Calories eaten vs daily target
- Protein / Carbs / Fats consumption vs targets

### AI Mini Tips

- "You're missing 30g protein today."
- "You are ~250 kcal over your daily target."

### Phase 0 Status

- ✅ Mock the nutrition DB and AI
- ✅ Clear interfaces for later real API integration

---

## 3. 2D MUSCLE MAP (MUSCLE LOAD VISUALIZATION)

### Visual Representation

A 2D body (male/female variant), where each muscle group is color-coded by weekly load:

- **GREEN**: high / optimal load
- **YELLOW**: medium load
- **BLUE**: low load / neglected

### Logic

- For each muscle group, compute weekly volume or weekly sets
- Based on thresholds:
  - e.g. < X sets/week = BLUE
  - between X–Y = YELLOW
  - > Y = GREEN

### On Press (tap) of a muscle

Show:
- Exercises that hit that muscle
- Weekly stats (sets, volume)
- Suggestions: "Add 3 sets of X next week"

### Implementation Notes

- Start with a simple 2D SVG or vector representation
- Separate:
  - UI layer (drawing / coloring muscles)
  - Logic layer (calculating load per muscle)

**Current Implementation:**
- `MuscleLoadModel` - tracks weekly sets, reps, volume per muscle group
- `MuscleMapPage` - displays the visualization
- Load levels: high (≥20 sets), medium (≥12 sets), low (<12 sets)

---

## 4. AI COACH LOGIC

### AI Responsibilities

1. **Build initial PPL program:**
   - Input: Sex, age, experience, goal, training days/week
   - Output: Weekly PPL split, Exercises per day, Sets/reps recommended per exercise

2. **Manage weekly volume:**
   - Aim for research-based sweet spot: ~10–20 sets per muscle per week
   - If a muscle group has too low sets → suggest adding
   - If too high sets → suggest reducing

3. **Adapt over time:**
   - Look at: Progress in weight per exercise, RPE values
   - If user is:
     - Progressing → maybe increase load slightly
     - Stalling → suggest change (increase weight, add a set, swap exercise)

4. **Combine training with nutrition:**
   - If user is in CUT (calories deficit): Slightly reduce weekly volume
   - If in BULK: Allow a bit more volume / emphasis on strength

### Phase 0 Status

- ✅ `AIService` interface implemented
- ✅ Simple rule-based local implementation as placeholder
- ⏳ Later: Plug real LLM / remote AI

---

## 5. PROGRESS TRACKING

### Visuals Needed

- Body weight graph over time
- Weekly training volume graph (total kg per week, or per muscle group)
- PR list:
  - For each exercise: Best weight × reps (e.g. 100kg × 5 on bench)
- Weekly comparison:
  - Compare this week's volume / sets vs last week

### "Muscle Card" Concept

For each muscle group (Chest, Back, Quads, etc.):
- Weekly sets
- Main exercises
- Trend (up / down / flat)

### Phase 0 Status

- ⏳ **TODO**: Create progress tracking feature module
- ⏳ **TODO**: Implement basic progress screens

---

## 6. MONETIZATION (LATER PHASE)

### Two-Level Model

1. **Free version with ads:**
   - Use AdMob
   - Show ads in: Home screen, After finishing workouts, Nutrition screens (not too aggressive)

2. **Premium subscription:**
   - Remove all ads
   - Unlock:
     - Full AI features
     - Advanced load analysis & muscle analytics
     - Premium built plans
     - AI-rich nutrition planning

### Phase 0 Status

- ✅ Architecture prepared for subscription checks and AdMob
- ⏳ Subscription service abstraction ready for implementation

---

## Daily User Flow

### ONBOARDING (first launch)

- Ask:
  - Sex (male/female)
  - Age
  - Height, weight
  - Experience level
  - Goal (bulk / cut / maintain)
  - Training days per week (2–6)
- App:
  - Calculates TDEE + calorie target
  - Generates initial PPL plan

### DAILY USAGE

**Home screen shows:**
- "Today's workout: Push / Pull / Legs" (or rest)
- Button: "Start workout"
- Button: "Scan food" / "Photo meal"
- Daily calorie & macro summary
- Mini muscle map preview (tap to go full screen)

**WORKOUT:**
- User enters "today's workout"
- Sees recommended exercises
- Can: Edit exercises, Log sets/reps/weights
- Data is auto-saved and influences: Muscle map, Weekly volume, AI suggestions (later)

**NUTRITION:**
- User logs food via: Barcode + manual, Photo + manual
- Sees: Calories remaining vs target, Macros progress
- Periodically receives tips

**PROGRESS:**
- User occasionally opens progress tab:
  - Check body weight trend
  - Check PR history
  - Check muscle map and muscle cards

---

## Implementation Guidelines

### Module Structure

```
lib/
  features/
    training/          # PPL workouts, exercise logging
    nutrition/         # Food logging, macro tracking
    ai/                # AI coach logic (stubbed for now)
    muscle_map/        # 2D visualization
    progress/          # Progress tracking (TODO)
    monetization/      # Subscription/ads (prepared)
    onboarding/        # First-time setup
    home/              # Dashboard
    profile/           # User profile
  core/
    models/            # Data models
    services/          # Business logic services
    constants/         # App-wide constants
    config/            # Configuration (e.g., Firebase toggle)
    router/            # Navigation
    theme/             # UI theming
```

### Design Principles

1. ✅ Keep modules clearly separated
2. ✅ Use in-memory or local storage only (Phase 0)
3. ✅ Mock AI and external APIs (Phase 0)
4. ✅ Design clean models and services
5. ✅ Avoid hard-coding logic inside UI widgets
6. ✅ Document assumptions in code comments

### When Touching/Redesigning Flows

- Make sure they align with this spec
- If something deviates, propose refactoring instead of patching

---

## Current Codebase Status

### ✅ Implemented

- Onboarding flow (gender, age, height, weight, experience, goal, frequency)
- Home dashboard with today's workout and stats
- Workout pages (PPL structure)
- Nutrition pages (food logging UI)
- Muscle map visualization
- Profile page
- Local-only mode (Firebase stubbed)
- Clean architecture with feature-based organization

### ⏳ TODO / Future Work

- Progress tracking feature module
- Refactor ExerciseModel to match spec's WorkoutExercise + SetLog structure
- Real AI integration
- Real Firebase backend
- Real barcode/image food recognition
- Subscription/AdMob implementation

---

## Notes

- **GYM ONLY**: No home workouts, no yoga, no random stuff
- **PPL Focus**: All training is structured around Push/Pull/Legs
- **Data-Driven**: Everything should be based on research and user data
- **Stability First**: Phase 0 prioritizes stability over features


