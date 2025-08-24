import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/main/main_screen_fixed.dart';
import 'presentation/screens/auth/login_screen.dart';

// Mock providers for testing UI
class MockAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isAdmin = false;
  String? _userName = '테스트 사용자';

  bool get isAuthenticated => _isAuthenticated;
  bool get isAdmin => _isAdmin;
  String? get userName => _userName;
  bool get isLoading => false;
  String? get errorMessage => null;

  void signIn() {
    _isAuthenticated = true;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void toggleAdmin() {
    _isAdmin = !_isAdmin;
    notifyListeners();
  }
}

class MockWorkshopProvider extends ChangeNotifier {
  List<MockWorkshop> _workshops = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MockWorkshop> get workshops => _workshops;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _workshops.isEmpty && !_isLoading;
  bool get hasMoreData => false;

  MockWorkshopProvider() {
    _loadMockWorkshops();
  }

  void _loadMockWorkshops() {
    _workshops = List.generate(10, (index) => MockWorkshop(
      id: 'workshop_$index',
      title: '워크샵 ${index + 1}',
      description: '이것은 워크샵 ${index + 1}의 설명입니다.',
      price: (index + 1) * 50000.0,
      capacity: 10 + index,
      tags: ['태그${index + 1}', '기술'],
      imageUrl: null,
    ));
  }

  Future<void> loadWorkshops({bool refresh = false}) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1));
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshWorkshops() async {
    await loadWorkshops(refresh: true);
  }

  Future<void> loadMoreWorkshops() async {
    // Mock implementation
  }

  Future<void> searchWorkshops(String query) async {
    // Mock implementation
  }

  List<String> getAvailableTags() {
    return ['Flutter', 'Dart', 'Mobile', 'Web', 'Backend'];
  }

  ({double min, double max})? getPriceRange() {
    if (_workshops.isEmpty) return null;
    return (min: 50000.0, max: 500000.0);
  }
}

class MockBookingProvider extends ChangeNotifier {
  List<MockBooking> _bookings = [];
  bool _isLoading = false;

  List<MockBooking> get allBookings => _bookings;
  bool get isLoading => _isLoading;

  MockBookingProvider() {
    _loadMockBookings();
  }

  void _loadMockBookings() {
    _bookings = List.generate(5, (index) => MockBooking(
      id: 'booking_$index',
      workshopTitle: '워크샵 ${index + 1}',
      status: MockBookingStatus.values[index % MockBookingStatus.values.length],
      createdAt: DateTime.now().subtract(Duration(days: index)),
    ));
  }

  Future<void> loadBookings(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _isLoading = false;
    notifyListeners();
  }
}

class MockWorkshop {
  final String id;
  final String title;
  final String description;
  final double price;
  final int capacity;
  final List<String> tags;
  final String? imageUrl;

  MockWorkshop({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.capacity,
    required this.tags,
    this.imageUrl,
  });

  String get formattedPrice {
    return '${price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}원';
  }
}

class MockBooking {
  final String id;
  final String workshopTitle;
  final MockBookingStatus status;
  final DateTime createdAt;

  MockBooking({
    required this.id,
    required this.workshopTitle,
    required this.status,
    required this.createdAt,
  });
}

enum MockBookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
}

void main() {
  runApp(const WorkshopBookingApp());
}

class WorkshopBookingApp extends StatelessWidget {
  const WorkshopBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockAuthProvider()),
        ChangeNotifierProvider(create: (_) => MockWorkshopProvider()),
        ChangeNotifierProvider(create: (_) => MockBookingProvider()),
      ],
      child: MaterialApp(
        title: 'Workshop Booking System',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AppRouter(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MockAuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const MainScreenFixed();
        }
        return const MockLoginScreen();
      },
    );
  }
}

class MockLoginScreen extends StatelessWidget {
  const MockLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.business_center,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Workshop Booking System',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<MockAuthProvider>().signIn();
                  },
                  child: const Text('일반 사용자로 로그인'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    final provider = context.read<MockAuthProvider>();
                    provider.toggleAdmin();
                    provider.signIn();
                  },
                  child: const Text('관리자로 로그인'),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                '데모 버전입니다. 실제 인증은 구현되지 않았습니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}