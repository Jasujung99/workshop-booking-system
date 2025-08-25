import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/result.dart';
import '../../core/utils/logger.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/user.dart' as domain;
import '../models/user_dto.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<domain.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      try {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();
            
        if (!userDoc.exists) return null;
        
        final userDto = UserDto.fromFirestore(userDoc);
        return userDto.toDomain(firebaseUser.uid);
      } catch (e) {
        AppLogger.error('Error getting user data', exception: e);
        return null;
      }
    });
  }

  Future<domain.User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();
          
      if (!userDoc.exists) return null;
      
      final userDto = UserDto.fromFirestore(userDoc);
      return userDto.toDomain(firebaseUser.uid);
    } catch (e) {
      AppLogger.error('Error getting current user data', exception: e);
      return null;
    }
  }

  Future<Result<domain.User>> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Failure(AuthException('Sign in failed'));
      }

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return const Failure(AuthException('User data not found'));
      }

      final userDto = UserDto.fromFirestore(userDoc);
      final user = userDto.toDomain(credential.user!.uid);
      
      AppLogger.info('User signed in successfully: ${user.email}');
      return Success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error during sign in', exception: e);
      return Failure(AuthException(_mapFirebaseAuthError(e), code: e.code));
    } catch (e) {
      AppLogger.error('Unexpected error during sign in', exception: e);
      return Failure(UnknownException('Sign in failed: ${e.toString()}'));
    }
  }

  Future<Result<domain.User>> signUp(String email, String password, String name) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const Failure(AuthException('Sign up failed'));
      }

      final user = domain.User(
        id: credential.user!.uid,
        email: email,
        name: name,
        role: domain.UserRole.user,
        createdAt: DateTime.now(),
      );

      final userDto = UserDto.fromDomain(user);
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .set(userDto.toFirestore());

      AppLogger.info('User signed up successfully: $email');
      return Success(user);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error during sign up', exception: e);
      return Failure(AuthException(_mapFirebaseAuthError(e), code: e.code));
    } catch (e) {
      AppLogger.error('Unexpected error during sign up', exception: e);
      return Failure(UnknownException('Sign up failed: ${e.toString()}'));
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      AppLogger.info('User signed out successfully');
      return const Success(null);
    } catch (e) {
      AppLogger.error('Error during sign out', exception: e);
      return Failure(AuthException('Sign out failed: ${e.toString()}'));
    }
  }

  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent to: $email');
      return const Success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error during password reset', exception: e);
      return Failure(AuthException(_mapFirebaseAuthError(e), code: e.code));
    } catch (e) {
      AppLogger.error('Unexpected error during password reset', exception: e);
      return Failure(UnknownException('Password reset failed: ${e.toString()}'));
    }
  }

  Future<Result<domain.User>> updateProfile(domain.User user) async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const Failure(AuthException('No authenticated user'));
      }

      // Update Firebase Auth profile
      await firebaseUser.updateDisplayName(user.name);

      // Update Firestore document
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      final userDto = UserDto.fromDomain(updatedUser);
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .update(userDto.toFirestore());

      AppLogger.info('User profile updated successfully: ${user.email}');
      return Success(updatedUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error during profile update', exception: e);
      return Failure(AuthException(_mapFirebaseAuthError(e), code: e.code));
    } catch (e) {
      AppLogger.error('Unexpected error during profile update', exception: e);
      return Failure(UnknownException('Profile update failed: ${e.toString()}'));
    }
  }

  Future<Result<void>> deleteAccount() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return const Failure(AuthException('No authenticated user'));
      }

      final userId = firebaseUser.uid;

      // Delete user document from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();

      // Delete Firebase Auth account
      await firebaseUser.delete();

      AppLogger.info('User account deleted successfully: $userId');
      return const Success(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      AppLogger.error('Firebase auth error during account deletion', exception: e);
      return Failure(AuthException(_mapFirebaseAuthError(e), code: e.code));
    } catch (e) {
      AppLogger.error('Unexpected error during account deletion', exception: e);
      return Failure(UnknownException('Account deletion failed: ${e.toString()}'));
    }
  }

  Future<Result<List<domain.User>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      final users = querySnapshot.docs.map((doc) {
        final userDto = UserDto.fromFirestore(doc);
        return userDto.toDomain(doc.id);
      }).toList();

      AppLogger.info('Retrieved ${users.length} users');
      return Success(users);
    } catch (e) {
      AppLogger.error('Error getting all users', exception: e);
      return Failure(UnknownException('Failed to get users: ${e.toString()}'));
    }
  }

  Future<Result<domain.User>> updateUserRole(String userId, domain.UserRole role) async {
    try {
      // Update user role in Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'role': role.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get updated user data
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return const Failure(AuthException('User not found'));
      }

      final userDto = UserDto.fromFirestore(userDoc);
      final updatedUser = userDto.toDomain(userId);

      AppLogger.info('User role updated successfully: $userId -> ${role.name}');
      return Success(updatedUser);
    } catch (e) {
      AppLogger.error('Error updating user role', exception: e);
      return Failure(UnknownException('Failed to update user role: ${e.toString()}'));
    }
  }



  String _mapFirebaseAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}