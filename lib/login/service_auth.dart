import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<String?> registration({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Daftar Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'Password Terlalu Pendek';
      } else if (e.code == 'email-already-in-use') {
        return 'Account Telah Digunakan';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Login Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        return 'Maaf Pasword yang anda gunakan salah';
      } else {
        return e.message;
      }
    } catch (e) {
      return e.toString();
    }
  }
}