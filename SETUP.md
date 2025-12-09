# Fitness AI - Setup Guide

## Prerequisites

1. **Flutter SDK** (3.0+)
   ```bash
   flutter --version
   ```

2. **Firebase Account**
   - Create a Firebase project at https://console.firebase.google.com
   - Enable Authentication (Anonymous)
   - Enable Firestore Database
   - Enable Storage
   - Enable Cloud Functions

3. **OpenAI/OpenRouter API Key**
   - Get API key from OpenAI or OpenRouter
   - For OpenRouter: https://openrouter.ai/

## Setup Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Firebase Configuration

#### Android:
1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. Update `lib/firebase_options.dart` with your Firebase config

#### iOS:
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/`
3. Update `lib/firebase_options.dart` with your Firebase config

### 3. Generate Firebase Options

Run FlutterFire CLI:
```bash
flutterfire configure
```

Or manually update `lib/firebase_options.dart` with your Firebase project credentials.

### 4. Firebase Cloud Functions Setup

```bash
cd functions
npm install
```

Set environment variables:
```bash
firebase functions:config:set openai.key="YOUR_OPENAI_API_KEY"
# OR for OpenRouter:
firebase functions:config:set openrouter.base_url="https://openrouter.ai/api/v1"
firebase functions:config:set openrouter.key="YOUR_OPENROUTER_API_KEY"
```

Deploy functions:
```bash
firebase deploy --only functions
```

### 5. Android Setup

1. Update `android/app/build.gradle`:
   - Ensure `minSdkVersion` is 21 or higher
   - Add `google-services.json` to the project

2. Update package name in:
   - `android/app/build.gradle` (applicationId)
   - `android/app/src/main/AndroidManifest.xml`

### 6. iOS Setup

1. Update bundle identifier in:
   - `ios/Runner.xcodeproj/project.pbxproj`
   - `ios/Runner/Info.plist`

2. Add camera permissions (already in Info.plist)

### 7. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── core/              # Core utilities, constants, themes, router
├── features/          # Feature modules
│   ├── onboarding/
│   ├── home/
│   ├── workout/
│   ├── muscle_map/
│   ├── nutrition/
│   └── profile/
├── models/            # Data models
├── providers/         # Riverpod providers
├── services/          # Firebase, API services
└── widgets/           # Reusable widgets

functions/             # Firebase Cloud Functions
```

## Environment Variables

Create a `.env` file (optional, for local development):
```
OPENAI_API_KEY=your_key_here
OPENROUTER_API_KEY=your_key_here
```

## Testing

Run tests:
```bash
flutter test
```

## Building for Production

### Android:
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS:
```bash
flutter build ios --release
```

## Troubleshooting

1. **Firebase not initialized**: Check `firebase_options.dart` has correct credentials
2. **Cloud Functions errors**: Ensure functions are deployed and API keys are set
3. **Barcode scanner not working**: Check camera permissions in AndroidManifest.xml and Info.plist
4. **Build errors**: Run `flutter clean` and `flutter pub get`

## Next Steps

1. Add your 2D body model SVG/PNG assets to `assets/images/`
2. Implement AdMob integration (placeholders are ready)
3. Implement subscription system (placeholders are ready)
4. Add demo videos for exercises
5. Customize AI prompts in Cloud Functions for better results

## Support

For issues or questions, check the documentation or create an issue in the repository.




