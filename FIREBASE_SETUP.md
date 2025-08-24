# Firebase Setup Instructions

This document provides step-by-step instructions to set up Firebase for the Workshop Booking System.

## Prerequisites

1. A Google account
2. Flutter SDK installed
3. Android Studio or Xcode (for mobile development)

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `workshop-booking-system`
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click "Add app" and select Android
2. Enter package name: `com.example.workshop_booking_system`
3. Enter app nickname: `Workshop Booking System Android`
4. Download `google-services.json`
5. Replace the placeholder file at `android/app/google-services.json`

## Step 3: Add iOS App

1. In Firebase Console, click "Add app" and select iOS
2. Enter bundle ID: `com.example.workshopBookingSystem`
3. Enter app nickname: `Workshop Booking System iOS`
4. Download `GoogleService-Info.plist`
5. Replace the placeholder file at `ios/Runner/GoogleService-Info.plist`

## Step 4: Add Web App (Optional)

### Option A: Using FlutterFire CLI (Recommended)

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase for your project:
   ```bash
   flutterfire configure
   ```
   - Select your Firebase project
   - Choose platforms (android, ios, web, etc.)
   - This will automatically generate `lib/firebase_options.dart`

### Option B: Manual Setup

1. In Firebase Console, click "Add app" and select Web
2. Enter app nickname: `Workshop Booking System Web`
3. **Choose "<script> 태그 사용" (Use script tag)**
4. Copy the Firebase configuration object
5. Update `lib/firebase_options.dart` with your actual configuration values:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-api-key',
  appId: 'your-actual-app-id',
  messagingSenderId: 'your-sender-id',
  projectId: 'workshop-booking-system',
  authDomain: 'workshop-booking-system.firebaseapp.com',
  storageBucket: 'workshop-booking-system.appspot.com',
  measurementId: 'your-measurement-id',
);
```

**중요**: Firebase Console에서 Web 앱을 추가할 때 **"<script> 태그 사용"**을 선택하세요. npm 방식은 Flutter 프로젝트에서 사용하지 않습니다.

### Firebase Console에서 Web 앱 추가 단계별 가이드:

1. Firebase Console → 프로젝트 설정 → 일반 탭
2. "앱 추가" 클릭 → 웹 아이콘 선택
3. 앱 닉네임: `Workshop Booking System Web` 입력
4. Firebase Hosting 설정 체크 (선택사항)
5. "앱 등록" 클릭
6. **"Firebase SDK 추가" 단계에서 "<script> 태그 사용" 선택**
7. 표시되는 설정 객체를 복사:
   ```javascript
   const firebaseConfig = {
     apiKey: "your-api-key",
     authDomain: "your-project.firebaseapp.com",
     projectId: "your-project-id",
     storageBucket: "your-project.appspot.com",
     messagingSenderId: "123456789",
     appId: "your-app-id",
     measurementId: "your-measurement-id"
   };
   ```
8. 이 값들을 `lib/firebase_options.dart`의 web 설정에 입력

## Step 5: Enable Firebase Services

### Authentication
1. Go to Authentication > Sign-in method
2. Enable Email/Password authentication
3. Configure authorized domains if needed

#### Authorized Domains 설정 설명:

**Authorized Domains**는 Firebase Authentication 요청을 허용할 도메인들을 지정하는 보안 기능입니다.

**기본적으로 포함되는 도메인:**
- `localhost` (개발용)
- `your-project-id.firebaseapp.com` (Firebase Hosting)
- `your-project-id.web.app` (Firebase Hosting)

**추가로 설정해야 하는 경우:**
- 커스텀 도메인을 사용하는 경우 (예: `www.yourcompany.com`)
- 다른 호스팅 서비스를 사용하는 경우 (예: Vercel, Netlify)
- 개발 서버가 다른 포트를 사용하는 경우

**설정 방법:**
1. Firebase Console → Authentication → Settings → Authorized domains
2. "Add domain" 클릭
3. 도메인 입력 (예: `yourdomain.com`)
4. 저장

**개발 단계에서는 보통 기본 설정으로 충분합니다.**

### Firestore Database
1. Go to Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" for development
4. Select a location close to your users

### Storage
1. Go to Storage
2. Click "Get started"
3. Choose "Start in test mode" for development

## Step 6: Configure Android

### For Kotlin DSL (build.gradle.kts) - Current Project Setup:

Add to `android/build.gradle.kts`:

```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

Add to `android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Add this line
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
```

### For Groovy DSL (build.gradle) - Alternative Setup:

If your project uses `.gradle` files instead of `.gradle.kts`:

Add to `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

Add to `android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'
```

**Note**: This project already has the Google Services plugin configured by FlutterFire CLI.

## Step 7: Configure iOS

1. Open `ios/Runner.xcworkspace` in Xcode
2. Add `GoogleService-Info.plist` to the Runner target
3. Ensure the file is added to the bundle

## Step 8: Test Configuration

Run the following command to test Firebase connection:

```bash
flutter run
```

The app should start without Firebase-related errors.

## Security Rules

### Firestore Rules (Development)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Storage Rules (Development)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Production Considerations

1. Update security rules for production
2. Enable App Check for additional security
3. Configure proper CORS settings for web
4. Set up proper backup and monitoring
5. Configure proper user roles and permissions

## Troubleshooting

### Common Issues

1. **Build errors**: Ensure all configuration files are in the correct locations
2. **Authentication errors**: Check if Email/Password is enabled in Firebase Console
3. **Permission errors**: Verify Firestore and Storage rules
4. **Network errors**: Check internet connection and Firebase project status

### Getting Help

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Support](https://firebase.google.com/support)