import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppointmentsManagementScreen extends StatefulWidget {
  final String salonId;
  final String salonName;

  const AppointmentsManagementScreen({
    Key? key,
    required this.salonId,
    required this.salonName,
  }) : super(key: key);

  @override
  State<AppointmentsManagementScreen> createState() =>
      _AppointmentsManagementScreenState();
}

class _AppointmentsManagementScreenState
    extends State<AppointmentsManagementScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late TabController _tabController;

  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  String errorMessage = '';

  // Dynamic seat management
  List<String> allSeats = [];
  List<String> disabledSeats = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSeatConfig(); // This loads seat count and disables dynamically
  }

  Future<void> _loadSeatConfig() async {
    setState(() => isLoading = true);
    try {
      DocumentSnapshot doc =
          await _firestore.collection('salons').doc(widget.salonId).get();
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      int seatCount = 20; // Fallback default
      if (data != null && data.containsKey('no of seats')) {
        final val = data['no of seats'];
        if (val is int && val > 0) seatCount = val;
      }
      allSeats = _generateSeatLabels(seatCount);

      // Disabled seats
      if (data != null && data.containsKey('disabledSeats')) {
        disabledSeats = List<String>.from(data['disabledSeats'] ?? []);
      } else {
        disabledSeats = [];
      }
      setState(() => isLoading = false);
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load seat configuration: $e';
        isLoading = false;
      });
    }
  }

  List<String> _generateSeatLabels(int totalSeats, {int seatsPerRow = 5}) {
    List<String> seatLabels = [];
    List<String> rowLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    int seatCount = 0;
    int rowIndex = 0;
    while (seatCount < totalSeats && rowIndex < rowLetters.length) {
      String row = rowLetters[rowIndex];
      for (int i = 1; i <= seatsPerRow; i++) {
        if (seatCount >= totalSeats) break;
        seatLabels.add('$row$i');
        seatCount++;
      }
      rowIndex++;
    }
    return seatLabels;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffB5362D),
        foregroundColor: Colors.white,
        title: Text(
          'Manage Appointments',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'All Bookings'),
            Tab(text: 'Seat Management'),
          ],
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Color(0xffB5362D)),
              )
              : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayAppointments(),
                  _buildAllAppointments(),
                  _buildSeatManagement(),
                ],
              ),
    );
  }

  // -----------------------------------
  // TODAY'S APPOINTMENTS
  // -----------------------------------
  Widget _buildTodayAppointments() {
    DateTime today = DateTime.now();
    String todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('salons')
              .doc(widget.salonId)
              .collection('bookings')
              .where('dateString', isEqualTo: todayString)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xffB5362D)),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<DocumentSnapshot> appointments = snapshot.data?.docs ?? [];
        if (appointments.isEmpty)
          return _buildEmptyState('No appointments for today');
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: appointments.length,
          itemBuilder:
              (context, index) => _buildAppointmentCard(appointments[index]),
        );
      },
    );
  }

  // -----------------------------------
  // ALL APPOINTMENTS (DATE PICKER)
  // -----------------------------------
  Widget _buildAllAppointments() {
    return Column(
      children: [
        // Container(
        //   padding: EdgeInsets.all(16.w),
        //   color: Colors.white,
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: GestureDetector(
        //           onTap: _selectDate,
        //           child: Container(
        //             padding: EdgeInsets.all(12.w),
        //             decoration: BoxDecoration(
        //               border: Border.all(color: Color(0xffB5362D)),
        //               borderRadius: BorderRadius.circular(8.r),
        //             ),
        //             child: Row(
        //               children: [
        //                 Icon(Icons.calendar_today, color: Color(0xffB5362D)),
        //                 SizedBox(width: 8.w),
        //                 Text(
        //                   DateFormat('MMM dd, yyyy').format(selectedDate),
        //                   style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getAllSalonBookings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xffB5362D),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                log(snapshot.error.toString());
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              List<DocumentSnapshot> appointments = snapshot.data?.docs ?? [];
              if (appointments.isEmpty)
                return _buildEmptyState('No appointments for selected date');
              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: appointments.length,
                itemBuilder:
                    (context, index) =>
                        _buildAppointmentCard(appointments[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  // -----------------------------------
  // SEAT MANAGEMENT TAB
  // -----------------------------------
  Widget _buildSeatManagement() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
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
                Text(
                  'Seat Configuration',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffB5362D),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Toggle seats to enable/disable them for booking',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Date selector for viewing bookings
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
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
                Text(
                  'View Bookings for Date',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffB5362D),
                  ),
                ),
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => _selectDateForSeatView(),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffB5362D)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xffB5362D)),
                        SizedBox(width: 8.w),
                        Text(
                          DateFormat('MMM dd, yyyy').format(selectedDate),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Stats & Seat Grid
          StreamBuilder<QuerySnapshot>(
            stream: _getBookingsForSeatManagement(selectedDate),
            builder: (context, snapshot) {
              List<String> bookedSeats = [];
              Map<String, Map<String, dynamic>> seatBookingDetails = {};
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  Map<String, dynamic>? data =
                      doc.data() as Map<String, dynamic>?;
                  if (data != null && data.containsKey('seat')) {
                    String status = data['status'] ?? '';
                    if (status == 'confirmed' || status == 'pending') {
                      String seat = data['seat']?.toString() ?? '';
                      if (seat.isNotEmpty && !bookedSeats.contains(seat)) {
                        bookedSeats.add(seat);
                        seatBookingDetails[seat] = {
                          'customerName': data['customerName'] ?? 'Unknown',
                          'service': data['service'] ?? 'Unknown',
                          'time': data['time'] ?? 'Unknown',
                          'status': status,
                        };
                      }
                    }
                  }
                }
              }
              int availableSeats =
                  allSeats.length - disabledSeats.length - bookedSeats.length;
              return Column(
                children: [
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildSeatStatCard(
                          'Available',
                          availableSeats,
                          Colors.green,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildSeatStatCard(
                          'Booked',
                          bookedSeats.length,
                          Colors.red,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildSeatStatCard(
                          'Disabled',
                          disabledSeats.length,
                          Colors.grey,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildSeatStatCard(
                          'Total',
                          allSeats.length,
                          Color(0xffB5362D),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Front indicator
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'FRONT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Seat grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5, // or make dynamic if you want!
                      childAspectRatio: 1,
                      crossAxisSpacing: 8.w,
                      mainAxisSpacing: 8.h,
                    ),
                    itemCount: allSeats.length,
                    itemBuilder: (context, index) {
                      String seatId = allSeats[index];
                      bool isDisabled = disabledSeats.contains(seatId);
                      bool isBooked = bookedSeats.contains(seatId);

                      Color seatColor;
                      IconData? statusIcon;

                      if (isBooked) {
                        seatColor = Colors.red.shade400;
                        statusIcon = Icons.person;
                      } else if (isDisabled) {
                        seatColor = Colors.grey.shade400;
                        statusIcon = Icons.close;
                      } else {
                        seatColor = Colors.green.shade400;
                        statusIcon = null;
                      }

                      return GestureDetector(
                        onTap:
                            isBooked
                                ? () => _showBookingDetails(
                                  context,
                                  seatId,
                                  seatBookingDetails[seatId],
                                )
                                : () => _toggleSeat(seatId),
                        child: Container(
                          decoration: BoxDecoration(
                            color: seatColor,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  seatId,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                if (statusIcon != null) ...[
                                  SizedBox(height: 2.h),
                                  Icon(
                                    statusIcon,
                                    size: 10.sp,
                                    color: Colors.white,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(Colors.green.shade400, 'Available'),
                      _buildLegendItem(Colors.red.shade400, 'Booked'),
                      _buildLegendItem(Colors.grey.shade400, 'Disabled'),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Info text
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Tap on booked seats to view booking details. Tap on available/disabled seats to toggle their status.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Quick actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _enableAllSeats,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'Enable All',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _disableAllSeats,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: Text(
                            'Disable All',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --------- SUPPORT WIDGETS AND FUNCTIONS ---------

  Widget _buildAppointmentCard(DocumentSnapshot appointment) {
    Map<String, dynamic>? data = appointment.data() as Map<String, dynamic>?;

    if (data == null) return SizedBox.shrink();

    String status = data['status'] ?? 'pending';
    String customerName = data['customerName'] ?? 'Unknown';
    String phoneNumber = data['phoneNumber'] ?? '';
    String service = data['service'] ?? '';
    String time = data['time'] ?? '';
    String seat = data['seat'] ?? '';
    double price = (data['price'] ?? 0).toDouble();

    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  customerName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffB5362D),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12.sp, color: statusColor),
                    SizedBox(width: 4.w),
                    Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.phone, phoneNumber),
                    _buildDetailRow(Icons.cut, service),
                    _buildDetailRow(Icons.access_time, time),
                    _buildDetailRow(Icons.event_seat, 'Seat $seat'),
                    _buildDetailRow(Icons.currency_rupee, '₹${price.toInt()}'),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Action buttons
          Row(
            children: [
              if (status == 'pending') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _updateAppointmentStatus(
                          appointment.id,
                          'confirmed',
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    child: Text(
                      'Verify',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _updateAppointmentStatus(
                          appointment.id,
                          'cancelled',
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              if (status == 'confirmed') ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _updateAppointmentStatus(
                          appointment.id,
                          'completed',
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffB5362D),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    child: Text(
                      'Mark Complete',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
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
            message,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatStatCard(String title, int count, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 4.w),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
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

  Stream<QuerySnapshot> _getAllSalonBookings() {
    return _firestore
        .collection('salons')
        .doc(widget.salonId)
        .collection('bookings')
        .orderBy('date', descending: false) // earliest first
        .orderBy('time') // then by time in the day
        .snapshots();
  }

  Stream<QuerySnapshot> _getBookingsForSeatManagement(DateTime date) {
    String dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _firestore
        .collection('salons')
        .doc(widget.salonId)
        .collection('bookings')
        .where('dateString', isEqualTo: dateString)
        .where('status', whereIn: ['confirmed', 'pending'])
        .snapshots();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Color(0xffB5362D)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectDateForSeatView() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Color(0xffB5362D)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _showBookingDetails(
    BuildContext context,
    String seatId,
    Map<String, dynamic>? bookingDetails,
  ) {
    if (bookingDetails == null) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Color(0xffB5362D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.event_seat,
                    color: Color(0xffB5362D),
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Seat $seatId',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xffB5362D),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookingDetailRow(
                  'Customer',
                  bookingDetails['customerName'] ?? 'Unknown',
                ),
                _buildBookingDetailRow(
                  'Service',
                  bookingDetails['service'] ?? 'Unknown',
                ),
                _buildBookingDetailRow(
                  'Time',
                  bookingDetails['time'] ?? 'Unknown',
                ),
                _buildBookingDetailRow(
                  'Status',
                  bookingDetails['status'] ?? 'Unknown',
                ),
                _buildBookingDetailRow(
                  'Date',
                  DateFormat('MMM dd, yyyy').format(selectedDate),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: TextStyle(color: Color(0xffB5362D)),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildBookingDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    try {
      await _firestore
          .collection('salons')
          .doc(widget.salonId)
          .collection('bookings')
          .doc(appointmentId)
          .update({
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment ${newStatus.toLowerCase()} successfully'),
          backgroundColor: Color(0xffB5362D),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleSeat(String seatId) async {
    try {
      setState(() {
        if (disabledSeats.contains(seatId)) {
          disabledSeats.remove(seatId);
        } else {
          disabledSeats.add(seatId);
        }
      });
      await _firestore.collection('salons').doc(widget.salonId).update({
        'disabledSeats': disabledSeats,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating seat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _enableAllSeats() async {
    try {
      setState(() => disabledSeats.clear());
      await _firestore.collection('salons').doc(widget.salonId).update({
        'disabledSeats': [],
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All seats enabled'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error enabling seats: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disableAllSeats() async {
    try {
      setState(() => disabledSeats = List.from(allSeats));
      await _firestore.collection('salons').doc(widget.salonId).update({
        'disabledSeats': disabledSeats,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('All seats disabled'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error disabling seats: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
