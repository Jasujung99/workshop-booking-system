# 워크샵 & 대관 예약 관리 앱

Flutter와 Firebase를 사용한 워크샵 및 공간 대관 예약 관리 시스템입니다.

## 주요 기능

### 사용자 기능
- 🔐 사용자 인증 (회원가입/로그인)
- 📅 워크샵 및 공간 예약 (관리자가 설정한 시간대에서 선택)
- 🔍 워크샵 검색 및 필터링
- 📋 예약 내역 관리
- 🔔 예약 알림
- 💬 피드백 및 후기 작성 (앱 피드백, 워크샵/공간 이용 후기)

### 관리자 기능
- 🏢 워크샵 등록 및 관리
- ⏰ 공간 예약 가능 시간대 설정 및 관리
- � 사예약 현황 대시보드
- � 사용자 관분리
- � 수통계 및 분석
- �  수익 관리
- 📢 공지사항 관리
- 💬 피드백 및 후기 관리 (사용자 피드백 확인 및 응답)

## 기술 스택

- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Firebase
  - Authentication (사용자 인증)
  - Firestore (데이터베이스)
  - Storage (이미지 저장)
  - Functions (서버리스 로직)
  - Messaging (푸시 알림)
- **상태 관리**: Provider
- **UI**: Material Design 3

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── user.dart
│   ├── workshop.dart
│   ├── time_slot.dart
│   ├── booking.dart
│   └── feedback.dart
├── services/                 # Firebase 서비스
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
├── providers/                # 상태 관리
│   ├── auth_provider.dart
│   ├── booking_provider.dart
│   └── workshop_provider.dart
├── screens/                  # 화면
│   ├── auth/
│   ├── user/
│   └── admin/
├── widgets/                  # 재사용 위젯
└── utils/                    # 유틸리티
```

## 설치 및 실행

### 1. 프로젝트 클론
```bash
git clone <repository-url>
cd workshop-booking-app
```

### 2. 의존성 설치
```bash
flutter pub get
```

### 3. Firebase 설정
1. [Firebase Console](https://console.firebase.google.com/)에서 새 프로젝트 생성
2. Flutter 앱 등록 (Android/iOS/Web)
3. `google-services.json` (Android) 및 `GoogleService-Info.plist` (iOS) 다운로드
4. Firebase CLI 설치 및 FlutterFire 설정
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
flutterfire configure
```

### 4. 앱 실행
```bash
flutter run
```

## Firebase 설정 요구사항

### Firestore 컬렉션 구조
```
users/
├── {userId}
│   ├── email: string
│   ├── name: string
│   ├── role: string (user/admin)
│   └── createdAt: timestamp

workshops/
├── {workshopId}
│   ├── title: string
│   ├── description: string
│   ├── price: number
│   ├── capacity: number
│   ├── imageUrl: string
│   └── createdAt: timestamp

timeSlots/
├── {timeSlotId}
│   ├── date: timestamp
│   ├── startTime: string (HH:mm)
│   ├── endTime: string (HH:mm)
│   ├── type: string (workshop/space)
│   ├── itemId: string (workshop ID for workshop slots)
│   ├── isAvailable: boolean
│   ├── maxCapacity: number
│   └── createdAt: timestamp

bookings/
├── {bookingId}
│   ├── userId: string
│   ├── timeSlotId: string
│   ├── type: string (workshop/space)
│   ├── itemId: string (workshop ID for workshop bookings)
│   ├── status: string (pending/confirmed/cancelled)
│   ├── totalAmount: number
│   └── createdAt: timestamp

feedbacks/
├── {feedbackId}
│   ├── userId: string
│   ├── type: string (app/workshop/space)
│   ├── itemId: string (workshop ID for workshop feedback, null for app feedback)
│   ├── rating: number (1-5)
│   ├── comment: string
│   ├── isRead: boolean (관리자 읽음 여부)
│   └── createdAt: timestamp
```

### Firestore 보안 규칙
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자는 자신의 데이터만 읽기/쓰기 가능
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 워크샵은 모든 인증된 사용자가 읽기 가능, 관리자만 쓰기 가능
    match /workshops/{workshopId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // 시간대는 모든 인증된 사용자가 읽기 가능, 관리자만 쓰기 가능
    match /timeSlots/{timeSlotId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // 예약은 해당 사용자와 관리자만 접근 가능
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // 피드백은 작성자와 관리자만 접근 가능
    match /feedbacks/{feedbackId} {
      allow read, write: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

## 개발 로드맵

### Phase 1: 기본 기능
- [ ] 사용자 인증 시스템
- [ ] 워크샵/공간 목록 표시
- [ ] 기본 예약 기능
- [ ] 관리자 대시보드

### Phase 2: 고급 기능
- [ ] 결제 시스템 연동
- [ ] 푸시 알림
- [ ] 피드백 시스템 고도화
- [ ] 고급 검색 및 필터링

### Phase 3: 최적화
- [ ] 성능 최적화
- [ ] 오프라인 지원
- [ ] 다국어 지원
- [ ] 접근성 개선

## 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 문의

프로젝트에 대한 질문이나 제안사항이 있으시면 이슈를 생성해 주세요.
