import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:salon_booking/Controller/sign_up_controller.dart';
import 'package:salon_booking/booking_status_screen.dart'; // Add this import
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              // Profile header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Color(0xff1E2676),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        size: 40.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              
              // Menu items
              _buildMenuItem(
                icon: Icons.calendar_today,
                title: 'My Bookings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserBookingsScreen(), // Remove phoneNumber parameter
                    ),
                  );
                },
              ),
              
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () {
                  // Add edit profile functionality
                },
              ),
              
              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  // Add settings functionality
                },
              ),
              
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  // Add help functionality
                },
              ),
              
              Spacer(),
              
              // Logout button
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 20.h),
                child: ElevatedButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false);
                    final authController = Provider.of<SignUpController>(
                      context,
                      listen: false,
                    );
                    authController.signOut(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Color(0xff1E2676).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: Color(0xff1E2676),
            size: 20.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.grey,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        tileColor: Colors.white,
      ),
    );
  }
}