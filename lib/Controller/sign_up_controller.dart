import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salon_booking/home_screen.dart';
import 'package:salon_booking/onboarding_screen.dart';
import 'package:salon_booking/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController with ChangeNotifier {
  bool isLoading = false;

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Optionally show a success message
      AppUtils.showOnetimeSnackbar(
        context: context,
        message: "Signed out successfully",
        bg: Colors.green,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
        (route) => false,
      );
    } catch (e) {
      // Handle errors if any
      AppUtils.showOnetimeSnackbar(
        context: context,
        message: 'Error signing out: $e',
        bg: Colors.red,
      );
    }
  }

  Future<void> onRegistration({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (credential.user?.uid != null) {
               SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        
        AppUtils.showOnetimeSnackbar(
          context: context,
          message: "Registration success",
          bg: Colors.green,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        AppUtils.showOnetimeSnackbar(
          context: context,
          message: "The password provided is too weak",
          bg: Colors.red,
        );
      } else if (e.code == 'email-already-in-use') {
        AppUtils.showOnetimeSnackbar(
          context: context,
          message: "The account already exists for that email.",
          bg: Colors.red,
        );
      } else if (e.code == 'network-request-failed') {
        AppUtils.showOnetimeSnackbar(
          bg: Colors.red,
          context: context,
          message: "please check your network",
        );
      }
    } catch (e) {
      log(e.toString());
      AppUtils.showOnetimeSnackbar(context: context, message: e.toString());
    }
    isLoading = false;
    notifyListeners();
  }
}
