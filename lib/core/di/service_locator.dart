import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../data/services/firebase_auth_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/firebase_storage_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/workshop_repository_impl.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/workshop_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/usecases/auth/sign_in_use_case.dart';
import '../../domain/usecases/auth/sign_up_use_case.dart';
import '../../domain/usecases/auth/sign_out_use_case.dart';
import '../../domain/usecases/workshop/get_workshops_use_case.dart';
import '../../domain/usecases/workshop/create_workshop_use_case.dart';
import '../../domain/usecases/workshop/update_workshop_use_case.dart';
import '../../domain/usecases/booking/get_bookings_use_case.dart';
import '../../domain/usecases/booking/create_booking_use_case.dart';
import '../../domain/usecases/booking/cancel_booking_use_case.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/workshop_provider.dart';
import '../../presentation/providers/booking_provider.dart';

/// Service locator for dependency injection
/// 
/// Manages the creation and lifecycle of all services, repositories,
/// use cases, and providers in the application
class ServiceLocator {
  static late FirebaseAuthService _firebaseAuthService;
  static late FirestoreService _firestoreService;
  static late FirebaseStorageService _firebaseStorageService;
  
  static late AuthRepository _authRepository;
  static late WorkshopRepository _workshopRepository;
  static late BookingRepository _bookingRepository;
  
  static late SignInUseCase _signInUseCase;
  static late SignUpUseCase _signUpUseCase;
  static late SignOutUseCase _signOutUseCase;
  static late GetWorkshopsUseCase _getWorkshopsUseCase;
  static late CreateWorkshopUseCase _createWorkshopUseCase;
  static late UpdateWorkshopUseCase _updateWorkshopUseCase;
  static late GetBookingsUseCase _getBookingsUseCase;
  static late CreateBookingUseCase _createBookingUseCase;
  static late CancelBookingUseCase _cancelBookingUseCase;

  /// Initialize all dependencies
  static Future<void> initialize() async {
    // Initialize services
    _firebaseAuthService = FirebaseAuthService();
    _firestoreService = FirestoreService();
    _firebaseStorageService = FirebaseStorageService();
    
    // Initialize repositories
    _authRepository = AuthRepositoryImpl(
      authService: _firebaseAuthService,
      firestoreService: _firestoreService,
    );
    
    _workshopRepository = WorkshopRepositoryImpl(
      firestoreService: _firestoreService,
      storageService: _firebaseStorageService,
    );
    
    _bookingRepository = BookingRepositoryImpl(
      firestoreService: _firestoreService,
    );
    
    // Initialize use cases
    _signInUseCase = SignInUseCase(_authRepository);
    _signUpUseCase = SignUpUseCase(_authRepository);
    _signOutUseCase = SignOutUseCase(_authRepository);
    _getWorkshopsUseCase = GetWorkshopsUseCase(_workshopRepository);
    _createWorkshopUseCase = CreateWorkshopUseCase(_workshopRepository);
    _updateWorkshopUseCase = UpdateWorkshopUseCase(_workshopRepository);
    _getBookingsUseCase = GetBookingsUseCase(_bookingRepository);
    _createBookingUseCase = CreateBookingUseCase(_bookingRepository);
    _cancelBookingUseCase = CancelBookingUseCase(_bookingRepository);
  }

  /// Get list of providers for the app
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(
          authRepository: _authRepository,
          signInUseCase: _signInUseCase,
          signUpUseCase: _signUpUseCase,
          signOutUseCase: _signOutUseCase,
        ),
      ),
      ChangeNotifierProvider<WorkshopProvider>(
        create: (_) => WorkshopProvider(
          getWorkshopsUseCase: _getWorkshopsUseCase,
          createWorkshopUseCase: _createWorkshopUseCase,
          updateWorkshopUseCase: _updateWorkshopUseCase,
          workshopRepository: _workshopRepository,
        ),
      ),
      ChangeNotifierProvider<BookingProvider>(
        create: (_) => BookingProvider(
          getBookingsUseCase: _getBookingsUseCase,
          createBookingUseCase: _createBookingUseCase,
          cancelBookingUseCase: _cancelBookingUseCase,
          bookingRepository: _bookingRepository,
        ),
      ),
    ];
  }

  // Getters for accessing dependencies (if needed for testing or other purposes)
  static AuthRepository get authRepository => _authRepository;
  static WorkshopRepository get workshopRepository => _workshopRepository;
  static BookingRepository get bookingRepository => _bookingRepository;
}