import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booking/login_screen.dart';
import 'package:salon_booking/sign_up_screen.dart';

class SalonOwnerOnboardingScreen extends StatelessWidget {
  const SalonOwnerOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image - fills the whole screen
          Positioned.fill(
            child: Image.asset(
              'assets/salon_owner_png.png', // Your image path
              fit: BoxFit.cover,
            ),
          ),

          // Other elements over the image
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 415.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    height: 120.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),

                      color: Colors.white,
                    ),

                    child: Column(
                      children: [
                        SizedBox(height: 20.h),
                        Text(
                          "Grow your salon with us",
                          style: TextStyle(
                            color: Color(0xffB5362D),
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          width: 300.w, // Adjust width as needed
                          padding: EdgeInsets.all(0.w),
                          child: Text(
                            'List your salon on SalonHub to reach more customers, simplify bookings, and grow your business.',
                            maxLines: 3,
                            overflow:
                                TextOverflow
                                    .ellipsis, // Adds ... if text overflows
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Container(
                      height: 45.h,
                      width: 250.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),

                        color: Color(0xffB5362D),
                      ),

                      child: Center(
                        child: Text(
                          "Log in",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      );
                    },
                    child: Container(
                      height: 45.h,
                      width: 250.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),

                        color: Color(0xffffffff),
                      ),

                      child: Center(
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xffB5362D),
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
