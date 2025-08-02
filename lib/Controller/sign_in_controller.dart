import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:salon_booking/Salon%20Owner%20Screens/salon_owner_home.dart';
import 'package:salon_booking/Widgets/custom_bottom_navbar_screen.dart';
import 'package:salon_booking/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInController with ChangeNotifier {
  bool isLoading = false;
  bool isLoadingG = false;
  onLogin({
    required String email,
    required String password,
    required bool isOwner,
    required BuildContext context,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final credentials = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (credentials.user?.uid != null) {
        String uid = credentials.user!.uid;

        // Fetch user role
        DocumentSnapshot roldoc =
            await FirebaseFirestore.instance
                .collection('profile_details')
                .doc(uid)
                .get();

        if (roldoc.exists) {
          String role = roldoc['role'];
          log("Logged in role: $role");

          if (isOwner && role != 'owner') {
            // If SalonLogin but role is user
            isLoading = false;
            notifyListeners();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Invalid credentials")));
            return;
          }

          if (!isOwner && role != 'user') {
            // If UserLogin but role is owner
            isLoading = false;
            notifyListeners();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Invalid credentials")));
            return;
          }

          // Store login status
          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (role == 'owner') {
            await prefs.setBool('isOwnerLoggedIn', true);
          } else {
            await prefs.setBool('isLoggedIn', true);
          }

          // Navigate accordingly
          if (role == 'owner') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => SalonOwnerHome()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => CustomBottomNavbarScreen()),
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("User profile not found.")));
        }
      }
    } on FirebaseAuthException catch (e) {
      log(e.code.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(" ${e.message}")));
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
