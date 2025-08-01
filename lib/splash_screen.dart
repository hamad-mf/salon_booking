import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:salon_booking/Salon%20Owner%20Screens/salon_owner_home.dart';
import 'package:salon_booking/home_screen.dart';
import 'package:salon_booking/onboarding_screen.dart';
import 'package:salon_booking/profile_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    log("checking login status");
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check both user and admin login statuses
    bool isUserLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    bool isOwnerLoggedIn = prefs.getBool('isOwnerLoggedIn') ?? false;
    // Wait for 4 seconds, then navigate based on login status
    Timer(Duration(seconds: 4), () {
      if (isUserLoggedIn) {
        // Navigate to
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      } else if (isOwnerLoggedIn) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => SalonOwnerHome()));
      } else {
        // Navigate to onBoarding screen
        log("false");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ProfileSelectionScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xff81ADD8),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset('assets/splash_logo.png')),

          Text(
            "SalonHub",
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
