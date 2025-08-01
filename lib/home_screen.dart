import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:salon_booking/Controller/sign_up_controller.dart';
import 'package:salon_booking/Widgets/search_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // title: Text("Home Screen"),
      //   // actions: [
      //   //   IconButton(
      //   //     onPressed: () async {
      //   //       SharedPreferences prefs = await SharedPreferences.getInstance();
      //   //       await prefs.setBool('isLoggedIn', false);
      //   //       final authController = Provider.of<SignUpController>(
      //   //         context,
      //   //         listen: false,
      //   //       );

      //   //       authController.signOut(context);
      //   //     },
      //   //     icon: Icon(Icons.exit_to_app),
      //   //   ),
      //   // ],
      //   backgroundColor: Color(0xff262D2E),
      // ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            height: 350.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                fit: BoxFit.cover,
                opacity: 0.3,
                image: AssetImage('assets/user_home_bg.jpg'),
              ),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 130.h),
                Row(
                  children: [
                    Text(
                      "Welcome to ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "SalonHub",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Text(
                  "Step into a world of grooming",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "convenience and style",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 20.h),
                SearchField(height: 55.h, hintText: "Search Salon's"),
              ],
            ),
          ),


          Text("Nearby salons")
        ],
      ),
    );
  }
}
