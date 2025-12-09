# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Firebase

#### Option A: Using FlutterFire CLI (Recommended)
```bash
# Install FlutterFire CLI if not already installed
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

#### Option B: Manual Configuration
1. Download `google-services.json` from Firebase Console → Project Settings
2. Place in `android/app/`
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/`
5. Update `lib/firebase_options.dart` with your Firebase credentials

### 3. Set Up Cloud Functions
```bash
cd functions
npm install

# Set your OpenAI/OpenRouter API key
firebase functions:config:set openai.key="YOUR_API_KEY"

# Deploy functions
firebase deploy --only functions
```

### 4. Run the App
```bash
flutter run
```

## 📱 First Run

1. **Onboarding**: Complete the 5-step onboarding flow
2. **Home**: View your dashboard with stats
3. **Generate Workout**: Go to Workout → Select Push/Pull/Legs
4. **Log Meal**: Go to Nutrition → Log Meal → Scan barcode or take photo
5. **View Muscle Map**: See your training volume distribution

## 🔑 Required Firebase Services

Enable these in Firebase Console:
- ✅ Authentication (Anonymous)
- ✅ Firestore Database
- ✅ Storage
- ✅ Cloud Functions

## 🎨 Customization

### Update App Name
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

### Update Colors
- Edit `lib/core/theme/app_theme.dart`

### Add Body Model Images
- Place SVG/PNG files in `assets/svgs/`
- Update `lib/features/muscle_map/presentation/pages/muscle_map_page.dart`

## 🐛 Troubleshooting

**"Firebase not initialized"**
- Check `firebase_options.dart` has correct credentials
- Ensure Firebase is initialized in `main.dart`

**"Cloud Functions error"**
- Verify functions are deployed: `firebase functions:list`
- Check API key is set: `firebase functions:config:get`

**"Barcode scanner not working"**
- Check camera permissions in AndroidManifest.xml and Info.plist
- Test on a physical device (emulator may not have camera)

**"Build errors"**
```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Learn More

- See `SETUP.md` for detailed setup instructions
- See `PROJECT_SUMMARY.md` for feature overview
- Check code comments for implementation details

## 🎯 Ready to Build!

Your Fitness AI app is ready to go! Start customizing and adding your own features.




