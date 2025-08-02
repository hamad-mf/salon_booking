import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:salon_booking/utils/app_utils.dart';

class SalonAddController with ChangeNotifier {
  bool isloading = false;

  Future<bool> onAddSalon({
    required String salonName,
    required int no_of_seats,
    required int phone_no,
    required String address,
    required BuildContext context,
    required double latitude,
    required double longitude,
    String description = "not available",
  }) async {
    try {
       isloading = true;
      notifyListeners();
      log("called on salon add");

      final User? SalonOwner = FirebaseAuth.instance.currentUser;

      if (SalonOwner == null) {
        AppUtils.showOnetimeSnackbar(
          context: context,
          message: "Please try again",
          bg: Colors.red,
        );
          isloading = true;
      notifyListeners();
        return false;
      }

      final String uid = SalonOwner.uid;
      log("Salon owner's ui is ${uid}");

      await FirebaseFirestore.instance.collection('salons').add({
        'salon name': salonName,
        'no of seats': no_of_seats,
        'phone number': phone_no,
        'address': address,
        'latitude':latitude,
        'longitude':longitude
      });
       isloading = false;
      notifyListeners();
      return true; // Success
    } catch (e) {
      log("error adding Salon $e");
        isloading = false;
      notifyListeners();
       AppUtils.showOnetimeSnackbar(
        context: context,
        message: "Failed to add salon, try again.",
        bg: Colors.red,
      );
      return false;
    }
  }
}
