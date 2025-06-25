import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Firebase auth state changes stream
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Current user model provider
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) {
      if (user != null) {
        return ref.watch(authServiceProvider).streamUserData(user.uid);
      }
      return Stream.value(null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Auth loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error state
final authErrorProvider = StateProvider<String?>((ref) => null);

// Sign in controller
class SignInController {
  final Ref ref;
  
  SignInController(this.ref);
  
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      ref.read(authErrorProvider.notifier).state = null;
      
      final user = await ref.read(authServiceProvider).signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return user != null;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }
  
  Future<bool> signInAnonymously() async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      ref.read(authErrorProvider.notifier).state = null;
      
      final user = await ref.read(authServiceProvider).signInAnonymously();
      
      return user != null;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }
}

// Sign up controller
class SignUpController {
  final Ref ref;
  
  SignUpController(this.ref);
  
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      ref.read(authErrorProvider.notifier).state = null;
      
      final user = await ref.read(authServiceProvider).signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      return user != null;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }
}

// Sign out controller
final signOutControllerProvider = Provider((ref) {
  return SignOutController(ref);
});

class SignOutController {
  final Ref ref;
  
  SignOutController(this.ref);
  
  Future<void> signOut() async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      ref.read(authErrorProvider.notifier).state = null;
      
      await ref.read(authServiceProvider).signOut();
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }
}

// Password reset controller
class PasswordResetController {
  final Ref ref;
  
  PasswordResetController(this.ref);
  
  Future<bool> resetPassword(String email) async {
    try {
      ref.read(authLoadingProvider.notifier).state = true;
      ref.read(authErrorProvider.notifier).state = null;
      
      await ref.read(authServiceProvider).resetPassword(email);
      
      return true;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
      return false;
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }
}

// Controller providers
final signInControllerProvider = Provider((ref) => SignInController(ref));
final signUpControllerProvider = Provider((ref) => SignUpController(ref));
final passwordResetControllerProvider = Provider((ref) => PasswordResetController(ref));

// Helper providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull != null;
});

final isGuestUserProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  return currentUser.valueOrNull?.isGuest ?? false;
});