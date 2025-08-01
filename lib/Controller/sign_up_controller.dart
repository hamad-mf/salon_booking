import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:salon_booking/home_screen.dart';
import 'package:salon_booking/onboarding_screen.dart';
import 'package:salon_booking/profile_selection_screen.dart';
import 'package:salon_booking/utils/app_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpController with ChangeNotifier {
  bool isLoading = false;

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

    

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ProfileSelectionScreen()),
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
    log("called on register");
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

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),(route) => false,
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

  Future<void> onAddProfile({
    required String name,
    required String phn,
    required String role,
    required BuildContext context,
  }) async {
    try {
      log("called on add profile");
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        AppUtils.showOnetimeSnackbar(
          context: context,
          message: "please wait",
          bg: Colors.red,
        );
        return;
      }

      final String uid = user.uid;
      log("User's uid is : $uid");

      await FirebaseFirestore.instance
          .collection('profile_details')
          .doc(uid)
          .set({'name': name, 'phone number': phn,'role':role});
    } catch (e) {
      log("error addng profile $e");
    }
  }
}
