import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// App localizations delegate and helper class
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('ko', 'KR'), // Korean
    Locale('ja', 'JP'), // Japanese
    Locale('zh', 'CN'), // Chinese Simplified
  ];

  // Common
  String get appName => _localizedValues[locale.languageCode]?['app_name'] ?? 'Workshop Booking System';
  String get loading => _localizedValues[locale.languageCode]?['loading'] ?? 'Loading...';
  String get error => _localizedValues[locale.languageCode]?['error'] ?? 'Error';
  String get success => _localizedValues[locale.languageCode]?['success'] ?? 'Success';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get confirm => _localizedValues[locale.languageCode]?['confirm'] ?? 'Confirm';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  String get edit => _localizedValues[locale.languageCode]?['edit'] ?? 'Edit';
  String get search => _localizedValues[locale.languageCode]?['search'] ?? 'Search';
  String get filter => _localizedValues[locale.languageCode]?['filter'] ?? 'Filter';
  String get retry => _localizedValues[locale.languageCode]?['retry'] ?? 'Retry';

  // Authentication
  String get login => _localizedValues[locale.languageCode]?['login'] ?? 'Login';
  String get logout => _localizedValues[locale.languageCode]?['logout'] ?? 'Logout';
  String get signup => _localizedValues[locale.languageCode]?['signup'] ?? 'Sign Up';
  String get email => _localizedValues[locale.languageCode]?['email'] ?? 'Email';
  String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Password';
  String get confirmPassword => _localizedValues[locale.languageCode]?['confirm_password'] ?? 'Confirm Password';
  String get forgotPassword => _localizedValues[locale.languageCode]?['forgot_password'] ?? 'Forgot Password?';
  String get resetPassword => _localizedValues[locale.languageCode]?['reset_password'] ?? 'Reset Password';
  String get name => _localizedValues[locale.languageCode]?['name'] ?? 'Name';

  // Workshops
  String get workshops => _localizedValues[locale.languageCode]?['workshops'] ?? 'Workshops';
  String get workshop => _localizedValues[locale.languageCode]?['workshop'] ?? 'Workshop';
  String get title => _localizedValues[locale.languageCode]?['title'] ?? 'Title';
  String get description => _localizedValues[locale.languageCode]?['description'] ?? 'Description';
  String get price => _localizedValues[locale.languageCode]?['price'] ?? 'Price';
  String get capacity => _localizedValues[locale.languageCode]?['capacity'] ?? 'Capacity';
  String get available => _localizedValues[locale.languageCode]?['available'] ?? 'Available';
  String get unavailable => _localizedValues[locale.languageCode]?['unavailable'] ?? 'Unavailable';
  String get bookNow => _localizedValues[locale.languageCode]?['book_now'] ?? 'Book Now';

  // Bookings
  String get bookings => _localizedValues[locale.languageCode]?['bookings'] ?? 'Bookings';
  String get booking => _localizedValues[locale.languageCode]?['booking'] ?? 'Booking';
  String get bookingConfirmed => _localizedValues[locale.languageCode]?['booking_confirmed'] ?? 'Booking Confirmed';
  String get bookingCancelled => _localizedValues[locale.languageCode]?['booking_cancelled'] ?? 'Booking Cancelled';
  String get cancelBooking => _localizedValues[locale.languageCode]?['cancel_booking'] ?? 'Cancel Booking';
  String get bookingHistory => _localizedValues[locale.languageCode]?['booking_history'] ?? 'Booking History';

  // Time and Date
  String get date => _localizedValues[locale.languageCode]?['date'] ?? 'Date';
  String get time => _localizedValues[locale.languageCode]?['time'] ?? 'Time';
  String get startTime => _localizedValues[locale.languageCode]?['start_time'] ?? 'Start Time';
  String get endTime => _localizedValues[locale.languageCode]?['end_time'] ?? 'End Time';
  String get duration => _localizedValues[locale.languageCode]?['duration'] ?? 'Duration';

  // Payment
  String get payment => _localizedValues[locale.languageCode]?['payment'] ?? 'Payment';
  String get payNow => _localizedValues[locale.languageCode]?['pay_now'] ?? 'Pay Now';
  String get paymentSuccessful => _localizedValues[locale.languageCode]?['payment_successful'] ?? 'Payment Successful';
  String get paymentFailed => _localizedValues[locale.languageCode]?['payment_failed'] ?? 'Payment Failed';
  String get refund => _localizedValues[locale.languageCode]?['refund'] ?? 'Refund';
  String get total => _localizedValues[locale.languageCode]?['total'] ?? 'Total';

  // Navigation
  String get home => _localizedValues[locale.languageCode]?['home'] ?? 'Home';
  String get profile => _localizedValues[locale.languageCode]?['profile'] ?? 'Profile';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get admin => _localizedValues[locale.languageCode]?['admin'] ?? 'Admin';
  String get dashboard => _localizedValues[locale.languageCode]?['dashboard'] ?? 'Dashboard';

  // Reviews
  String get reviews => _localizedValues[locale.languageCode]?['reviews'] ?? 'Reviews';
  String get review => _localizedValues[locale.languageCode]?['review'] ?? 'Review';
  String get writeReview => _localizedValues[locale.languageCode]?['write_review'] ?? 'Write Review';
  String get rating => _localizedValues[locale.languageCode]?['rating'] ?? 'Rating';

  // Accessibility
  String get accessibilityWorkshopImage => _localizedValues[locale.languageCode]?['accessibility_workshop_image'] ?? 'Workshop image';
  String get accessibilityUserAvatar => _localizedValues[locale.languageCode]?['accessibility_user_avatar'] ?? 'User avatar';
  String get accessibilityMenuButton => _localizedValues[locale.languageCode]?['accessibility_menu_button'] ?? 'Menu button';
  String get accessibilityBackButton => _localizedValues[locale.languageCode]?['accessibility_back_button'] ?? 'Back button';
  String get accessibilitySearchButton => _localizedValues[locale.languageCode]?['accessibility_search_button'] ?? 'Search button';
  String get accessibilityFilterButton => _localizedValues[locale.languageCode]?['accessibility_filter_button'] ?? 'Filter button';

  // Error Messages
  String get errorGeneric => _localizedValues[locale.languageCode]?['error_generic'] ?? 'Something went wrong. Please try again.';
  String get errorNetwork => _localizedValues[locale.languageCode]?['error_network'] ?? 'Network error. Please check your connection.';
  String get errorAuth => _localizedValues[locale.languageCode]?['error_auth'] ?? 'Authentication failed. Please try again.';
  String get errorValidation => _localizedValues[locale.languageCode]?['error_validation'] ?? 'Please check your input and try again.';

  // Format helpers
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: locale.toString(),
      symbol: _getCurrencySymbol(),
    );
    return formatter.format(amount);
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd(locale.toString()).format(date);
  }

  String formatTime(DateTime time) {
    return DateFormat.Hm(locale.toString()).format(time);
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat.yMMMd(locale.toString()).add_Hm().format(dateTime);
  }

  String _getCurrencySymbol() {
    switch (locale.languageCode) {
      case 'ko':
        return '₩';
      case 'ja':
        return '¥';
      case 'zh':
        return '¥';
      default:
        return '\$';
    }
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Workshop Booking System',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'search': 'Search',
      'filter': 'Filter',
      'retry': 'Retry',
      'login': 'Login',
      'logout': 'Logout',
      'signup': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'reset_password': 'Reset Password',
      'name': 'Name',
      'workshops': 'Workshops',
      'workshop': 'Workshop',
      'title': 'Title',
      'description': 'Description',
      'price': 'Price',
      'capacity': 'Capacity',
      'available': 'Available',
      'unavailable': 'Unavailable',
      'book_now': 'Book Now',
      'bookings': 'Bookings',
      'booking': 'Booking',
      'booking_confirmed': 'Booking Confirmed',
      'booking_cancelled': 'Booking Cancelled',
      'cancel_booking': 'Cancel Booking',
      'booking_history': 'Booking History',
      'date': 'Date',
      'time': 'Time',
      'start_time': 'Start Time',
      'end_time': 'End Time',
      'duration': 'Duration',
      'payment': 'Payment',
      'pay_now': 'Pay Now',
      'payment_successful': 'Payment Successful',
      'payment_failed': 'Payment Failed',
      'refund': 'Refund',
      'total': 'Total',
      'home': 'Home',
      'profile': 'Profile',
      'settings': 'Settings',
      'admin': 'Admin',
      'dashboard': 'Dashboard',
      'reviews': 'Reviews',
      'review': 'Review',
      'write_review': 'Write Review',
      'rating': 'Rating',
      'accessibility_workshop_image': 'Workshop image',
      'accessibility_user_avatar': 'User avatar',
      'accessibility_menu_button': 'Menu button',
      'accessibility_back_button': 'Back button',
      'accessibility_search_button': 'Search button',
      'accessibility_filter_button': 'Filter button',
      'error_generic': 'Something went wrong. Please try again.',
      'error_network': 'Network error. Please check your connection.',
      'error_auth': 'Authentication failed. Please try again.',
      'error_validation': 'Please check your input and try again.',
    },
    'ko': {
      'app_name': '워크샵 예약 시스템',
      'loading': '로딩 중...',
      'error': '오류',
      'success': '성공',
      'cancel': '취소',
      'confirm': '확인',
      'save': '저장',
      'delete': '삭제',
      'edit': '편집',
      'search': '검색',
      'filter': '필터',
      'retry': '다시 시도',
      'login': '로그인',
      'logout': '로그아웃',
      'signup': '회원가입',
      'email': '이메일',
      'password': '비밀번호',
      'confirm_password': '비밀번호 확인',
      'forgot_password': '비밀번호를 잊으셨나요?',
      'reset_password': '비밀번호 재설정',
      'name': '이름',
      'workshops': '워크샵',
      'workshop': '워크샵',
      'title': '제목',
      'description': '설명',
      'price': '가격',
      'capacity': '정원',
      'available': '예약 가능',
      'unavailable': '예약 불가',
      'book_now': '지금 예약',
      'bookings': '예약 내역',
      'booking': '예약',
      'booking_confirmed': '예약 확정',
      'booking_cancelled': '예약 취소됨',
      'cancel_booking': '예약 취소',
      'booking_history': '예약 이력',
      'date': '날짜',
      'time': '시간',
      'start_time': '시작 시간',
      'end_time': '종료 시간',
      'duration': '소요 시간',
      'payment': '결제',
      'pay_now': '지금 결제',
      'payment_successful': '결제 성공',
      'payment_failed': '결제 실패',
      'refund': '환불',
      'total': '총액',
      'home': '홈',
      'profile': '프로필',
      'settings': '설정',
      'admin': '관리자',
      'dashboard': '대시보드',
      'reviews': '후기',
      'review': '후기',
      'write_review': '후기 작성',
      'rating': '평점',
      'accessibility_workshop_image': '워크샵 이미지',
      'accessibility_user_avatar': '사용자 아바타',
      'accessibility_menu_button': '메뉴 버튼',
      'accessibility_back_button': '뒤로 가기 버튼',
      'accessibility_search_button': '검색 버튼',
      'accessibility_filter_button': '필터 버튼',
      'error_generic': '문제가 발생했습니다. 다시 시도해 주세요.',
      'error_network': '네트워크 오류입니다. 연결을 확인해 주세요.',
      'error_auth': '인증에 실패했습니다. 다시 시도해 주세요.',
      'error_validation': '입력 내용을 확인하고 다시 시도해 주세요.',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}