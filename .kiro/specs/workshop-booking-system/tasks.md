# Implementation Plan

- [x] 1. 프로젝트 기본 구조 및 의존성 설정





  - pubspec.yaml에 필요한 Firebase, Provider, 기타 패키지 추가
  - 프로젝트 폴더 구조 생성 (presentation, domain, data 계층)
  - Firebase 프로젝트 설정 및 Flutter 앱 연결
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 2. 도메인 모델 및 인터페이스 구현





  - [x] 2.1 핵심 도메인 모델 클래스 작성


    - User, Workshop, TimeSlot, Booking, PaymentInfo 모델 구현
    - 각 모델의 불변성과 유효성 검증 로직 포함
    - _Requirements: 1.1, 2.1, 3.1, 8.1_
  
  - [x] 2.2 Repository 인터페이스 정의


    - AuthRepository, WorkshopRepository, BookingRepository 인터페이스 작성
    - 각 인터페이스의 메서드 시그니처와 반환 타입 정의
    - _Requirements: 1.1, 2.1, 3.1_

- [x] 3. 에러 처리 및 유틸리티 시스템 구현





  - [x] 3.1 Result 패턴과 예외 클래스 구현


    - Result<T> sealed class와 Success, Failure 구현
    - AppException 추상 클래스와 구체적인 예외 타입들 구현
    - _Requirements: 3.6, 8.3_
  
  - [x] 3.2 에러 핸들러와 로깅 시스템 구현


    - ErrorHandler 클래스로 통합 에러 처리 구현
    - 로깅 유틸리티와 사용자 친화적 에러 메시지 시스템 구현
    - _Requirements: 3.6, 8.3_

- [x] 4. Firebase 서비스 계층 구현





  - [x] 4.1 Firebase Authentication 서비스 구현


    - FirebaseAuthService 클래스로 로그인, 회원가입, 로그아웃 기능 구현
    - 비밀번호 재설정 및 인증 상태 스트림 구현
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  
  - [x] 4.2 Firestore 데이터 서비스 구현


    - FirestoreService 클래스로 CRUD 작업 구현
    - DTO 클래스들과 도메인 모델 변환 로직 구현
    - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.2_
  
  - [x] 4.3 Firebase Storage 서비스 구현


    - 이미지 업로드, 다운로드, 삭제 기능 구현
    - 이미지 압축 및 캐싱 로직 구현
    - _Requirements: 2.1, 2.2_

- [x] 5. Repository 구현체 작성





  - [x] 5.1 AuthRepository 구현


    - Firebase Auth 서비스를 사용한 AuthRepositoryImpl 구현
    - 에러 처리와 도메인 모델 변환 로직 포함
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  
  - [x] 5.2 WorkshopRepository 구현


    - Firestore를 사용한 WorkshopRepositoryImpl 구현
    - 검색, 필터링, CRUD 작업 구현
    - _Requirements: 2.1, 2.2, 2.3, 4.1, 4.2, 4.3, 4.4_
  
  - [x] 5.3 BookingRepository 구현


    - 예약 생성, 조회, 취소 기능 구현
    - 시간대 충돌 검사 및 정원 관리 로직 구현
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 5.1, 5.2, 5.3, 5.4_

- [x] 6. Use Case 클래스 구현





  - [x] 6.1 인증 관련 Use Case 구현


    - SignInUseCase, SignUpUseCase, SignOutUseCase 구현
    - 비즈니스 규칙과 유효성 검증 로직 포함
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  
  - [x] 6.2 워크샵 관리 Use Case 구현


    - GetWorkshopsUseCase, CreateWorkshopUseCase, UpdateWorkshopUseCase 구현
    - 관리자 권한 검증 로직 포함
    - _Requirements: 2.1, 2.2, 2.3, 4.1, 4.2, 4.3, 4.4_
  
  - [x] 6.3 예약 관리 Use Case 구현


    - CreateBookingUseCase, CancelBookingUseCase, GetBookingsUseCase 구현
    - 예약 가능성 검증과 결제 연동 로직 구현
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 5.1, 5.2, 5.3, 5.4_

- [x] 7. 디자인 시스템 및 공통 위젯 구현




  - [x] 7.1 앱 테마 및 디자인 토큰 구현


    - AppTheme 클래스로 색상, 타이포그래피, 간격 시스템 정의
    - 라이트/다크 테마 지원 구현
    - _Requirements: 9.2, 9.3_
  
  - [x] 7.2 재사용 가능한 UI 컴포넌트 구현


    - AppButton, AppTextField, AppCard 등 기본 컴포넌트 구현
    - 로딩 상태와 에러 상태를 처리하는 위젯들 구현
    - _Requirements: 9.1, 9.3, 9.4_
  
  - [x] 7.3 반응형 레이아웃 시스템 구현


    - ResponsiveLayout 위젯으로 모바일/태블릿/웹 대응
    - 브레이크포인트 기반 레이아웃 전환 구현
    - _Requirements: 9.1, 9.4_

- [x] 8. 상태 관리 Provider 구현




  - [x] 8.1 AuthProvider 구현


    - 사용자 인증 상태 관리 및 권한 확인 로직
    - 로그인/로그아웃 상태 변화 처리
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  
  - [x] 8.2 WorkshopProvider 구현


    - 워크샵 목록 상태 관리 및 검색/필터링 상태
    - 관리자용 워크샵 CRUD 작업 상태 관리
    - _Requirements: 2.1, 2.2, 2.3, 4.1, 4.2, 4.3, 4.4_
  
  - [x] 8.3 BookingProvider 구현


    - 예약 프로세스 상태 관리 및 예약 내역 관리
    - 결제 상태와 예약 확인 프로세스 관리
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 5.1, 5.2, 5.3, 5.4_
-

- [x] 9. 인증 화면 구현




  - [x] 9.1 로그인 화면 구현


    - 이메일/비밀번호 입력 폼과 유효성 검증
    - 로그인 버튼과 로딩 상태 처리
    - _Requirements: 1.2_
  


  - [x] 9.2 회원가입 화면 구현

    - 사용자 정보 입력 폼과 실시간 유효성 검증
    - 회원가입 완료 후 자동 로그인 처리

    - _Requirements: 1.1_
  
  - [x] 9.3 비밀번호 재설정 화면 구현

    - 이메일 입력 및 재설정 링크 발송 기능
    - 성공/실패 메시지 표시
    - _Requirements: 1.4_

- [x] 10. 사용자 메인 화면 구현





  - [x] 10.1 홈 화면 및 네비게이션 구현


    - 하단 네비게이션 바와 화면 전환 로직
    - 사용자 역할에 따른 메뉴 표시 분기
    - _Requirements: 4.1, 7.1_
  


  - [ ] 10.2 워크샵 목록 화면 구현
    - 워크샵 카드 리스트와 무한 스크롤 구현
    - 검색 바와 실시간 검색 기능 구현


    - _Requirements: 4.1, 4.2, 4.3, 4.4_
  
  - [ ] 10.3 워크샵 상세 화면 구현
    - 워크샵 정보 표시와 예약 버튼
    - 예약 가능한 시간대 목록 표시
    - _Requirements: 3.1, 4.1_

- [ ] 11. 예약 프로세스 화면 구현
  - [ ] 11.1 시간대 선택 화면 구현
    - 달력 위젯과 시간대 선택 인터페이스
    - 예약 불가능한 시간대 비활성화 처리
    - _Requirements: 3.1, 3.5_
  
  - [ ] 11.2 예약 확인 및 결제 화면 구현
    - 예약 정보 요약과 총 금액 표시
    - 결제 방법 선택과 결제 처리 로직
    - _Requirements: 3.2, 3.3, 8.1, 8.2, 8.4_
  
  - [ ] 11.3 예약 완료 화면 구현
    - 예약 확인서와 영수증 표시
    - 예약 내역으로 이동하는 네비게이션
    - _Requirements: 3.3, 8.1_

- [ ] 12. 예약 관리 화면 구현
  - [ ] 12.1 예약 내역 목록 화면 구현
    - 예약 상태별 탭 구성과 필터링
    - 예약 카드 컴포넌트와 상태 표시
    - _Requirements: 5.1, 5.2_
  
  - [ ] 12.2 예약 상세 및 취소 화면 구현
    - 예약 상세 정보와 취소 버튼
    - 취소 정책 표시와 환불 처리
    - _Requirements: 5.2, 5.4, 8.4_
  
  - [ ] 12.3 알림 시스템 구현
    - 예약 임박 알림과 상태 변경 알림
    - 푸시 알림 설정과 인앱 알림 표시
    - _Requirements: 5.3_

- [ ] 13. 피드백 시스템 구현
  - [ ] 13.1 후기 작성 화면 구현
    - 별점 선택과 텍스트 후기 입력
    - 워크샵별 후기와 앱 피드백 구분
    - _Requirements: 6.1, 6.2_
  
  - [ ] 13.2 후기 목록 및 관리 화면 구현
    - 워크샵별 후기 목록 표시
    - 관리자용 피드백 확인 및 응답 기능
    - _Requirements: 6.3, 6.4_

- [ ] 14. 관리자 기능 구현
  - [ ] 14.1 관리자 대시보드 구현
    - 예약 현황 차트와 수익 통계
    - 실시간 알림과 빠른 액션 버튼들
    - _Requirements: 7.1, 7.2_
  
  - [ ] 14.2 워크샵 관리 화면 구현
    - 워크샵 등록/수정 폼과 이미지 업로드
    - 워크샵 목록과 상태 관리 기능
    - _Requirements: 2.1, 2.2, 2.3_
  
  - [ ] 14.3 시간대 관리 화면 구현
    - 시간대 일괄 생성과 개별 수정 기능
    - 예약 현황과 연동된 시간대 상태 표시
    - _Requirements: 2.4_
  
  - [ ] 14.4 사용자 및 예약 관리 화면 구현
    - 사용자 목록과 예약 이력 조회
    - 예약 상태 변경과 환불 처리 기능
    - _Requirements: 7.3, 7.4, 8.2, 8.3_

- [ ] 15. 결제 시스템 통합
  - [ ] 15.1 결제 서비스 구현
    - 결제 게이트웨이 연동과 결제 처리 로직
    - 결제 실패 시 재시도 및 에러 처리
    - _Requirements: 3.2, 3.6, 8.1, 8.2_
  
  - [ ] 15.2 환불 시스템 구현
    - 자동 환불 처리와 수동 환불 승인
    - 환불 내역 추적과 알림 발송
    - _Requirements: 3.4, 8.2, 8.4_
  
  - [ ] 15.3 결제 내역 관리 구현
    - 사용자별 결제 내역과 영수증 관리
    - 관리자용 수익 분석과 정산 기능
    - _Requirements: 8.1, 8.3_

- [ ] 16. 테스트 구현
  - [ ] 16.1 Unit Test 작성
    - 도메인 모델과 Use Case 테스트
    - Repository와 Service 클래스 테스트
    - _Requirements: 모든 비즈니스 로직_
  
  - [ ] 16.2 Widget Test 작성
    - 주요 화면과 컴포넌트 위젯 테스트
    - Provider 상태 변화 테스트
    - _Requirements: 모든 UI 컴포넌트_
  
  - [ ] 16.3 Integration Test 작성
    - 전체 사용자 플로우 테스트
    - Firebase 연동 테스트
    - _Requirements: 전체 사용자 여정_

- [ ] 17. 성능 최적화 및 마무리
  - [ ] 17.1 이미지 최적화 및 캐싱 구현
    - 이미지 압축과 지연 로딩 구현
    - 네트워크 이미지 캐싱 최적화
    - _Requirements: 9.1_
  
  - [ ] 17.2 앱 성능 최적화
    - 불필요한 리빌드 최소화와 메모리 최적화
    - 네트워크 요청 최적화와 오프라인 지원
    - _Requirements: 9.1, 9.4_
  
  - [ ] 17.3 접근성 및 다국어 지원 구현
    - 스크린 리더 지원과 키보드 네비게이션
    - 다국어 리소스와 지역화 설정
    - _Requirements: 9.3, 9.4_