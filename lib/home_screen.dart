// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'package:salon_booking/Widgets/search_field.dart';

import 'package:salon_booking/salon_detail_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Stream<QuerySnapshot> getAllSalons() {
    return FirebaseFirestore.instance.collection('salons').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔝 Enhanced Top Banner with Gradient
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              height: 380.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff1E2676),
                    Color(0xff1E2676).withOpacity(0.8),
                  ],
                ),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  opacity: 0.15,
                  image: AssetImage('assets/user_home_bg.jpg'),
                ),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.h),
                    // Profile and notification icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            log("message");
                          },
                          child: CircleAvatar(
                            radius: 22.r,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 22.r,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    // Welcome text with better typography
                    Text(
                      "Hello there! 👋",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          "Welcome to ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        Text(
                          "SalonHub",
                          style: TextStyle(
                            color: Colors.amber.shade300,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Step into a world of grooming\nconvenience and style",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 16.sp,
                        height: 1.4,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    // Enhanced search field with shadow
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: SearchField(
                        height: 55.h,
                        hintText: "Search Salon's",
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 👇 Enhanced Body with better spacing
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header with enhanced styling
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nearby salons",
                        style: TextStyle(
                          color: Color(0xff1E2676),
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          log("tapped");
                        },
                        child: Text(
                          "View all",
                          style: TextStyle(
                            color: Color(0xff1E2676),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  // 🔄 Enhanced StreamBuilder with better cards
                  StreamBuilder<QuerySnapshot>(
                    stream: getAllSalons(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Container(
                          padding: EdgeInsets.all(20.w),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48.sp,
                                  color: Colors.red.shade300,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  'Something went wrong',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 200.h,
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xff1E2676),
                              ),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          height: 200.h,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.store_outlined,
                                  size: 48.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "No salons found",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final salons = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: salons.length,
                        itemBuilder: (context, index) {
                          final salon =
                              salons[index].data() as Map<String, dynamic>;
                          final salonId = salons[index].id;
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => SalonDetailScreen(
                                        salonId: salonId,
                                        salonData: salon,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 20.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Enhanced image section with gradient overlay
                                    Stack(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: 160.h,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                'https://images.pexels.com/photos/1813272/pexels-photo-1813272.jpeg',
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Gradient overlay for better text readability
                                        Container(
                                          width: double.infinity,
                                          height: 160.h,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.1),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Enhanced favorite button
                                        Positioned(
                                          right: 15.w,
                                          top: 15.h,
                                          child: Container(
                                            padding: EdgeInsets.all(8.w),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
                                                  blurRadius: 8,
                                                  offset: Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.favorite_outline,
                                              size: 20.sp,
                                              color: Color(0xff1E2676),
                                            ),
                                          ),
                                        ),
                                        // Status badge
                                        Positioned(
                                          left: 15.w,
                                          top: 15.h,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 6.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(20.r),
                                            ),
                                            child: Text(
                                              "Open",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Enhanced content section
                                    Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            salon['salon name'] ?? "Salon Name",
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xff1E2676),
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_outlined,
                                                size: 16.sp,
                                                color: Colors.grey.shade600,
                                              ),
                                              SizedBox(width: 4.w),
                                              Expanded(
                                                child: Text(
                                                  salon['address'] ??
                                                      "Address not available",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Enhanced rating section
                                              Row(
                                                children: [
                                                  Row(
                                                    children: List.generate(5, (
                                                      starIndex,
                                                    ) {
                                                      return Icon(
                                                        starIndex < 3
                                                            ? Icons.star
                                                            : starIndex == 3
                                                            ? Icons.star_half
                                                            : Icons
                                                                .star_outline,
                                                        size: 16.sp,
                                                        color:
                                                            Colors
                                                                .amber
                                                                .shade600,
                                                      );
                                                    }),
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Text(
                                                    "4.2",
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xff1E2676),
                                                    ),
                                                  ),
                                                  Text(
                                                    " (56)",
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Book now button
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 8.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(0xff1E2676),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20.r,
                                                      ),
                                                ),
                                                child: Text(
                                                  "View",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
