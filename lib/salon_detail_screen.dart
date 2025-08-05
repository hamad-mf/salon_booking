// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salon_booking/book_appointment_screen.dart';

class SalonDetailScreen extends StatefulWidget {
  final Map<String, dynamic> salonData;
  final String salonId;

  const SalonDetailScreen({
    super.key,
    required this.salonId,
    required this.salonData,
  });

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> {
  bool isFavorite = false;
  int currentImageIndex = 0;

  // Sample salon images - in real app, these would come from the salon data
  final List<String> salonImages = [
    'https://images.pexels.com/photos/1813272/pexels-photo-1813272.jpeg',
    'https://images.pexels.com/photos/3993449/pexels-photo-3993449.jpeg',
    'https://images.pexels.com/photos/7697344/pexels-photo-7697344.jpeg',
    'https://images.pexels.com/photos/3993467/pexels-photo-3993467.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Images
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: Color(0xff1E2676),
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                   
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Color(0xff1E2676)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
              
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_outline,
                    color: isFavorite ? Colors.red : Color(0xff1E2676),
                  ),
                  onPressed: () {
                    setState(() {
                      isFavorite = !isFavorite;
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.share_outlined, color: Color(0xff1E2676)),
                  onPressed: () {
                    // Handle share functionality
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Image carousel
                  PageView.builder(
                    itemCount: salonImages.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(salonImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                  // Image indicators
                  Positioned(
                    bottom: 20.h,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          salonImages.asMap().entries.map((entry) {
                            return Container(
                              width:
                                  currentImageIndex == entry.key ? 20.w : 8.w,
                              height: 8.h,
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color:
                                    currentImageIndex == entry.key
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salon Name
                  Text(
                    widget.salonData['salon name'] ??
                        'The World Famous Venice Barber Shop',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Rating and Reviews
                  Row(
                    children: [
                      Text(
                        "4.2",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star : Icons.star_outline,
                            size: 16.sp,
                            color: Colors.amber.shade600,
                          );
                        }),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "(156)",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Category
                  Text(
                    "Barber Shop",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Address Section
                  _buildInfoSection(
                    icon: Icons.location_on_outlined,
                    title:
                        widget.salonData['address'] ??
                        '1527 Pacific Ave, Venice, CA 90291, United States',
                    subtitle: null,
                  ),
                  SizedBox(height: 16.h),

                  // Hours Section
                  _buildInfoSection(
                    icon: Icons.access_time_outlined,
                    title: "Open",
                    subtitle: "9am - 8pm",
                    titleColor: Colors.green.shade600,
                  ),
                  SizedBox(height: 16.h),

                  // Website Section
                  _buildInfoSection(
                    icon: Icons.language_outlined,
                    title: "www.worldfamousvenicebarabershop.com/schedule/",
                    subtitle: null,
                    titleColor: Color(0xff1E2676),
                  ),
                  SizedBox(height: 16.h),

                  // Directions Section
                  _buildInfoSection(
                    icon: Icons.directions_outlined,
                    title: "XGQG+4X Venice, Los Angeles, CA, USA",
                    subtitle: null,
                  ),
                  SizedBox(height: 30.h),

                  // Services Section

                  // Reviews Section
                  Text(
                    "Recent Reviews",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Sample Reviews
                  _buildReviewCard(
                    "John Doe",
                    5,
                    "Great service and friendly staff. Highly recommended!",
                  ),
                  SizedBox(height: 10.h),
                  _buildReviewCard(
                    "Sarah Wilson",
                    4,
                    "Good haircut, will come back again.",
                  ),
                  SizedBox(height: 100.h), // Extra space for bottom buttons
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Buttons
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.chat_outlined,
                text: "Chat",
                color: Colors.white,
                textColor: Color(0xff1E2676),
                borderColor: Color(0xff1E2676),
                onPressed: () {
                  // Handle chat functionality
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionButton(
                icon: Icons.call_outlined,
                text: "Call",
                color: Colors.white,
                textColor: Color(0xff1E2676),
                borderColor: Color(0xff1E2676),
                onPressed: () {
                  // Handle call functionality
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildActionButton(
                icon: Icons.calendar_today_outlined,
                text: "Services",
                color: Color(0xff1E2676),
                textColor: Colors.white,
                onPressed: () {
                  // Handle booking functionality
                  Navigator.push(context, MaterialPageRoute(builder: (context) => BookAppointmentScreen(salonId: widget.salonId, salonName: widget.salonData['salon name'] ?? 'no name'),));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 20.sp, color: Colors.grey.shade600),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? Colors.black,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildServiceChip(String service, String price) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  //     decoration: BoxDecoration(
  //       color: Color(0xff1E2676).withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(20.r),
  //       border: Border.all(
  //         color: Color(0xff1E2676).withOpacity(0.3),
  //         width: 1,
  //       ),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           service,
  //           style: TextStyle(
  //             fontSize: 13.sp,
  //             fontWeight: FontWeight.w500,
  //             color: Color(0xff1E2676),
  //           ),
  //         ),
  //         Text(
  //           price,
  //           style: TextStyle(
  //             fontSize: 13.sp,
  //             fontWeight: FontWeight.w600,
  //             color: Color(0xff1E2676),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildReviewCard(String name, int rating, String review) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: Color(0xff1E2676),
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_outline,
                        size: 12.sp,
                        color: Colors.amber.shade600,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            review,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25.r),
          border:
              borderColor != null
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.sp, color: textColor),
            SizedBox(width: 6.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
