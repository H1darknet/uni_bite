
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSource({
    required this.firebaseAuth,
    required this.firestore,
  });

  // RO'YXATDAN O'TISH
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Firebase Authentication
    final credential =
        await firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        throw TimeoutException('AUTH_TIMEOUT');
      },
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception('Foydalanuvchi yaratilmadi');
    }

    await firebaseUser.updateDisplayName(name.trim());

    final user = UserModel(
      uid: firebaseUser.uid,
      name: name.trim(),
      email: email.trim(),
      role: 'student',
    );

    // Firestore'ga profilni yozish
    try {
      await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set({
        ...user.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('FIRESTORE_TIMEOUT');
        },
      );
    } catch (error) {
      try {
        await firebaseAuth.signOut();
      } catch (_) {
        // Asosiy xatolikni saqlab qolamiz.
      }
      rethrow;
    }

    return user;
  }

  // TIZIMGA KIRISH

Future<UserModel> login({
  required String email,
  required String password,
}) async {
  final credential =
      await firebaseAuth.signInWithEmailAndPassword(
    email: email.trim(),
    password: password,
  );

  final firebaseUser = credential.user;

  if (firebaseUser == null) {
    throw Exception('Tizimga kirish amalga oshmadi');
  }

  final userDocument = firestore
      .collection('users')
      .doc(firebaseUser.uid);

  try {
    final document = await userDocument.get();

    if (document.exists && document.data() != null) {
      return UserModel.fromMap(document.data()!);
    }

    // Profil mavjud bo'lmasa, avtomatik yaratamiz.
    final name = firebaseUser.displayName?.trim().isNotEmpty == true
        ? firebaseUser.displayName!.trim()
        : (firebaseUser.email?.split('@').first ?? 'Talaba');

    final user = UserModel(
      uid: firebaseUser.uid,
      name: name,
      email: firebaseUser.email ?? email.trim(),
      role: 'student',
    );

    await userDocument.set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return user;
  } catch (error) {
    try {
      await firebaseAuth.signOut();
    } catch (_) {}

    rethrow;
  }
}


  // TIZIMDAN CHIQISH
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  // FOYDALANUVCHI HOLATINI KUZATISH
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap(
      (firebaseUser) async {
        if (firebaseUser == null) return null;

        final document = await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get()
            .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('FIRESTORE_TIMEOUT');
          },
        );

        if (!document.exists || document.data() == null) {
          return null;
        }

        return UserModel.fromMap(document.data()!);
      },
    );
  }
}
