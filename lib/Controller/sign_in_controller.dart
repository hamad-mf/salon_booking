import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:salon_booking/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInController with ChangeNotifier {
  bool isLoading = false;
  bool isLoadingG = false;
  onLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (credentials.user?.uid != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      log(e.code.toString());
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    isLoadingG = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser =
          await GoogleSignIn(
            signInOption: SignInOption.standard,
            scopes: ['email'],
          ).signIn();

      if (googleUser == null) {
        isLoadingG = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      }
    } catch (e) {
      print('Google sign-in error: $e');
    }

    isLoadingG = false;
    notifyListeners();
  }
}
