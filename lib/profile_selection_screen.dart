import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booking/Salon%20Owner%20Screens/salon_owner_onboarding_screen.dart';
import 'package:salon_booking/onboarding_screen.dart';

class ProfileSelectionScreen extends StatelessWidget {
  const ProfileSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 300.h),
            Text(
              "Who are you?",
              style: TextStyle(
                color: Color(0xff1E2676),
                fontSize: 30.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SalonOwnerOnboardingScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    height: 150.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      border: Border.all(width: 3.w, color: Color(0xff1E2676)),
                      borderRadius: BorderRadius.circular(23.r),
                      color: Color(0xffDADBDA),
                    ),

                    child: Center(
                      child: Text(
                        'I am a salon owner',
                        maxLines: 3,
                        overflow:
                            TextOverflow.ellipsis, // Adds ... if text overflows
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: Color(0xff1E2676),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 30.w),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OnboardingScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 150.h,
                    width: 150.w,
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      border: Border.all(width: 3.w, color: Color(0xff1E2676)),
                      borderRadius: BorderRadius.circular(23.r),
                      color: Color(0xffDADBDA),
                    ),

                    child: Center(
                      child: Text(
                        'I’m looking for a salon',
                        maxLines: 3,
                        overflow:
                            TextOverflow.ellipsis, // Adds ... if text overflows
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: Color(0xff1E2676),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
