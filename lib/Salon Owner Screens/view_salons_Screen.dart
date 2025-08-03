import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salon_booking/Salon%20Owner%20Screens/appointments_management_screen.dart';

class ViewSalonsScreen extends StatefulWidget {
  const ViewSalonsScreen({super.key});

  @override
  State<ViewSalonsScreen> createState() => _ViewSalonsScreenState();
}

class _ViewSalonsScreenState extends State<ViewSalonsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> salons = [];

  @override
  void initState() {
    super.initState();
    _fetchSalons();
  }

  Future<void> _fetchSalons() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
if (currentUserId == null) return;

QuerySnapshot querySnapshot = await _firestore
    .collection('salons')
    .where('userId', isEqualTo: currentUserId)
    .get();
      log(querySnapshot.docs.toString());
      List<Map<String, dynamic>> fetchedSalons = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        fetchedSalons.add(data);
      }

      setState(() {
        salons = fetchedSalons;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to fetch salons: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffB5362D),
        foregroundColor: Colors.white,
        title: Text(
          'View Salons',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _fetchSalons,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffB5362D)),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (salons.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _fetchSalons,
      color: Color(0xffB5362D),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: salons.length,
        itemBuilder: (context, index) {
          return _buildSalonCard(salons[index]);
        },
      ),
    );
  }

  Widget _buildSalonCard(Map<String, dynamic> salon) {
    String salonId = salon['id'] ?? '';
    String salonName = salon['salon name'] ?? 'Unknown Salon';
    String salonAddress = salon['address'] ?? 'No address provided';
    String salonPhone = salon['phone'] ?? 'No phone provided';
    String salonEmail = salon['email'] ?? 'No email provided';

    // Get creation timestamp
    Timestamp? createdAt = salon['createdAt'] as Timestamp?;
    String createdDate = 'Unknown';
    if (createdAt != null) {
      DateTime date = createdAt.toDate();
      createdDate = '${date.day}/${date.month}/${date.year}';
    }

    // Get services count
    List<dynamic> services = salon['services'] ?? [];
    int servicesCount = services.length;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToAppointmentManagement(salonId, salonName),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: Color(0xffB5362D).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Icon(
                        Icons.store,
                        color: Color(0xffB5362D),
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            salonName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xffB5362D),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Created on $createdDate',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: Colors.grey[400],
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Salon Details
                _buildDetailRow(Icons.location_on_outlined, salonAddress),
                SizedBox(height: 8.h),
                _buildDetailRow(Icons.phone_outlined, salonPhone),
                SizedBox(height: 8.h),
                _buildDetailRow(Icons.email_outlined, salonEmail),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  Icons.miscellaneous_services_outlined,
                  '$servicesCount Services Available',
                ),

                SizedBox(height: 16.h),

                // Action Button
                Container(
                  width: double.infinity,
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed:
                        () => _navigateToAppointmentManagement(
                          salonId,
                          salonName,
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffB5362D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Manage Appointments',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey[600]),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(
            'No Salons Found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Create your first salon to get started',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _fetchSalons,
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text('Refresh', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffB5362D),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80.sp, color: Colors.red[400]),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Salons',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              errorMessage,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _fetchSalons,
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text('Try Again', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffB5362D),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAppointmentManagement(String salonId, String salonName) {
    if (salonId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid salon ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AppointmentsManagementScreen(
              salonId: salonId,
              salonName: salonName,
            ),
      ),
    );
  }
}
