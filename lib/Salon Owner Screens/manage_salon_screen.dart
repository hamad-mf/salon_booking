import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSalonsScreen extends StatefulWidget {
  const ManageSalonsScreen({super.key});

  @override
  State<ManageSalonsScreen> createState() => _ManageSalonsScreenState();
}

class _ManageSalonsScreenState extends State<ManageSalonsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  bool isDeletingsalon = false;
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

  Future<void> _deleteSalon(String salonId, String salonName) async {
    try {
      setState(() {
        isDeletingsalon = true;
      });

      // Delete all bookings for this salon first
      QuerySnapshot bookingsSnapshot = await _firestore
          .collection('salons')
          .doc(salonId)
          .collection('bookings')
          .get();

      // Delete all booking documents
      WriteBatch batch = _firestore.batch();
      for (var bookingDoc in bookingsSnapshot.docs) {
        batch.delete(bookingDoc.reference);
      }

      // Delete the salon document
      batch.delete(_firestore.collection('salons').doc(salonId));

      // Commit the batch
      await batch.commit();

      setState(() {
        isDeletingsalon = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$salonName deleted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Refresh the salon list
      _fetchSalons();
    } catch (e) {
      setState(() {
        isDeletingsalon = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete salon: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showDeleteConfirmation(String salonId, String salonName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Delete Salon',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "$salonName"?',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This action will permanently:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '• Delete all salon information',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.red[600],
                      ),
                    ),
                    Text(
                      '• Cancel all pending bookings',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.red[600],
                      ),
                    ),
                    Text(
                      '• Remove booking history',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSalon(salonId, salonName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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
          'Manage Salons',
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
      child: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: salons.length,
            itemBuilder: (context, index) {
              return _buildSalonCard(salons[index]);
            },
          ),
          if (isDeletingsalon)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xffB5362D)),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Deleting salon...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: IconButton(
                    onPressed: () => _showDeleteConfirmation(salonId, salonName),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20.sp,
                    ),
                    tooltip: 'Delete Salon',
                  ),
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

            // Warning Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange[700],
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Deleting this salon will permanently remove all data and bookings',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Delete Button
            Container(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmation(salonId, salonName),
                icon: Icon(Icons.delete_outline, size: 16.sp),
                label: Text(
                  'Delete Salon',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ],
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
}