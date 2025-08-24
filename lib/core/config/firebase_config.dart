import 'package:firebase_core/firebase_core.dart';
import '../utils/logger.dart';
import '../../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('Firebase initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize Firebase', exception: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}