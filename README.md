# Fitness AI – PPL + Nutrition App

A comprehensive Flutter mobile application for fitness tracking with AI-powered workout generation and nutrition logging.

## Features

- **Onboarding Flow**: Collect user profile data (gender, age, height, weight, experience, goals)
- **PPL Workout System**: AI-generated Push/Pull/Legs workouts
- **Muscle Map**: 2D visualization of muscle group training volume
- **Nutrition Tracking**: Barcode scanning and food image recognition
- **AI Integration**: Personalized workout and nutrition recommendations
- **Firebase Backend**: Authentication, Firestore, Storage, and Cloud Functions

## Tech Stack

- Flutter 3+
- Firebase (Auth, Firestore, Storage, Functions)
- OpenAI/OpenRouter API
- Google ML Vision API
- Riverpod (State Management)
- GoRouter (Navigation)

## Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Set up Firebase:
   - Add `google-services.json` (Android) to `android/app/`
   - Add `GoogleService-Info.plist` (iOS) to `ios/Runner/`

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── core/           # Core utilities, constants, themes
├── features/       # Feature modules
├── models/         # Data models
├── providers/      # Riverpod providers
├── services/       # Firebase, API services
└── widgets/        # Reusable widgets
```




