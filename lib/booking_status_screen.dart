import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserBookingsScreen extends StatefulWidget {


  const UserBookingsScreen({super.key,});

  @override
  State<UserBookingsScreen> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 void _debugBookings() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      QuerySnapshot snapshot = await _firestore
          .collectionGroup('bookings')
          .where('userId', isEqualTo: userId)
          .get();
      
      log('Debug: Found ${snapshot.docs.length} bookings for user: $userId');
      for (var doc in snapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        log('Booking: ${doc.id} - ${data?['service']} - ${data?['status']}');
      }
    } catch (e) {
      log('Debug error: $e');
    }
  }

 @override
  void initState() {
    super.initState();
    _debugBookings(); // Add this line
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff1E2676),
        foregroundColor: Colors.white,
        title: Text(
          'My Bookings',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            _firestore
                .collectionGroup('bookings')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1E2676)),
              ),
            );
          }

          if (snapshot.hasError) {
            log(snapshot.error.toString());
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  ),
                ],
              ),
            );
          }

          List<DocumentSnapshot> bookings = snapshot.data?.docs ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No bookings found',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your appointment history will appear here',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(bookings[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(DocumentSnapshot booking) {
    Map<String, dynamic>? data = booking.data() as Map<String, dynamic>?;

    if (data == null) return SizedBox.shrink();

    String status = data['status'] ?? 'pending';
    String service = data['service'] ?? '';
    String salonId = data['salonId'] ?? '';
    String time = data['time'] ?? '';
    String seat = data['seat'] ?? '';
    double price = (data['price'] ?? 0).toDouble();

    // Parse date
    Timestamp? timestamp = data['date'] as Timestamp?;
    DateTime? bookingDate = timestamp?.toDate();

    Timestamp? createdTimestamp = data['createdAt'] as Timestamp?;
    DateTime? createdDate = createdTimestamp?.toDate();

    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);
    String statusText = _getStatusText(status);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, size: 16.sp, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                      if (status == 'pending') ...[
                        Text(
                          'Awaiting salon verification',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: statusColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (bookingDate != null) ...[
                  Text(
                    DateFormat('MMM dd').format(bookingDate),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Booking details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1E2676),
                      ),
                    ),
                    Text(
                      '₹${price.toInt()}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff1E2676),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Details grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(Icons.access_time, 'Time', time),
                    ),
                    Expanded(
                      child: _buildDetailItem(Icons.event_seat, 'Seat', seat),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                // Salon info
                FutureBuilder<DocumentSnapshot>(
                  future: _firestore.collection('salons').doc(salonId).get(),
                  builder: (context, salonSnapshot) {
                    String salonName = 'Loading...';
                    String salonAddress = '';

                    if (salonSnapshot.hasData && salonSnapshot.data!.exists) {
                      Map<String, dynamic>? salonData =
                          salonSnapshot.data!.data() as Map<String, dynamic>?;
                      salonName = salonData?['salon name'] ?? 'Unknown Salon';
                      salonAddress = salonData?['address'] ?? '';
                    }

                    return Column(
                      children: [
                        _buildDetailItem(Icons.store, 'Salon', salonName),
                        if (salonAddress.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14.sp,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  salonAddress,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),

                // Booking date
                if (createdDate != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Booked on ${DateFormat('MMM dd, yyyy - hh:mm a').format(createdDate)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],

                // Status-specific messages
                if (status == 'pending') ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16.sp,
                          color: Colors.orange.shade600,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Your booking is pending verification by the salon. You will be notified once confirmed.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (status == 'confirmed') ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16.sp,
                          color: Colors.green.shade600,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Your appointment is confirmed! Please arrive on time.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (status == 'cancelled') ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel_outlined,
                          size: 16.sp,
                          color: Colors.red.shade600,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'This appointment has been cancelled. Please book a new appointment if needed.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (status == 'completed') ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 16.sp,
                          color: Colors.blue.shade600,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Service completed successfully. Thank you for choosing us!',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.task_alt;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending Verification';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }
}
