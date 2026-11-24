
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/domain/usecases/logout_user.dart';
import '../../features/auth/domain/usecases/register_user.dart';

class AuthProvider extends ChangeNotifier {
  final RegisterUser registerUser;
  final LoginUser loginUser;
  final LogoutUser logoutUser;
  final AuthRepository repository;

  AuthProvider({
    required this.registerUser,
    required this.loginUser,
    required this.logoutUser,
    required this.repository,
  });

  UserEntity? _user;
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<UserEntity?>? _authSubscription;

  UserEntity? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // FIREBASE HOLATINI KUZATISH
  void initialize() {
    _authSubscription?.cancel();

    _authSubscription = repository.authStateChanges.listen(
      (user) {
        _user = user;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = _mapError(error);
        notifyListeners();
      },
    );
  }

  // RO'YXATDAN O'TISH
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _user = await registerUser(
        name: name,
        email: email,
        password: password,
      );

      return true;
    } catch (error) {
      _errorMessage = _mapError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // TIZIMGA KIRISH
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final loggedInUser = await loginUser(
        email: email,
        password: password,
      );

      _user = loggedInUser;

      return true;
    } catch (error) {
      _errorMessage = _mapError(error);
      return false;
    } finally {
      // Har qanday holatda yuklanish to'xtaydi
      _setLoading(false);
    }
  }

  // TIZIMDAN CHIQISH
  Future<void> logout() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await logoutUser();
      _user = null;
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _setLoading(false);
    }
  }

  // XATOLIKNI TOZALASH
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // XATOLIKLARNI ANIQLASH
  String _mapError(Object error) {
    if (error is TimeoutException) {
      switch (error.message) {
        case 'AUTH_TIMEOUT':
          return 'Firebase Authentication 20 soniyada javob bermadi. '
              'Internet va Firebase sozlamalarini tekshiring.';

        case 'FIRESTORE_TIMEOUT':
          return 'Cloud Firestore 15 soniyada javob bermadi. '
              'Firestore ulanishini tekshiring.';

        default:
          return 'Server belgilangan vaqtda javob bermadi.';
      }
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Bu email bilan hisob allaqachon mavjud';

        case 'invalid-email':
          return 'Email manzili noto‘g‘ri';

        case 'weak-password':
          return 'Parol juda oddiy';

        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          return 'Email yoki parol noto‘g‘ri';

        case 'network-request-failed':
          return 'Firebase Authentication internetga ulana olmadi';

        case 'too-many-requests':
          return 'Juda ko‘p urinish. Birozdan so‘ng qayta urinib ko‘ring';

        default:
          return 'Authentication xatoligi: ${error.code}. '
              '${error.message ?? ""}';
      }
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firestore ruxsat bermadi. Database Rules sozlamalarini tekshiring.';

        case 'unavailable':
          return 'Firestore serveri hozir mavjud emas.';

        case 'deadline-exceeded':
          return 'Firestore so‘rovi vaqtida javob bermadi.';

        default:
          return 'Firestore xatoligi: ${error.code}. '
              '${error.message ?? ""}';
      }
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
