import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:salon_booking/Controller/booking_controller.dart';

// Import your booking controller here
// import 'package:salon_booking/Controller/booking_controller.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String salonId;
  final String salonName;

  const BookAppointmentScreen({
    super.key,
    required this.salonId,
    required this.salonName,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingController>().loadServices(widget.salonId);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
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
          'Book Appointment',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.read<BookingController>().reset();
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<BookingController>(
        builder: (context, controller, child) {
          // Show loading indicator
          if (controller.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1E2676)),
              ),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salon Info Card
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
                    child: Row(
                      children: [
                        Container(
                          width: 50.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Color(0xff1E2676).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25.r),
                          ),
                          child: Icon(
                            Icons.store,
                            color: Color(0xff1E2676),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.salonName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xff1E2676),
                                ),
                              ),
                              Text(
                                'Book your appointment',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Error/Success Messages
                  if (controller.errorMessage.isNotEmpty) ...[
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
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              controller.errorMessage,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: controller.clearMessages,
                            icon: Icon(Icons.close, size: 18.sp),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  if (controller.successMessage.isNotEmpty) ...[
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
                            color: Colors.green,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              controller.successMessage,
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: controller.clearMessages,
                            icon: Icon(Icons.close, size: 18.sp),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                  ],

                  // Services Selection
                  _buildSectionTitle('Select Service'),
                  SizedBox(height: 12.h),
                  _buildServicesGrid(controller),
                  SizedBox(height: 24.h),

                  // Customer Details
                  _buildSectionTitle('Your Details'),
                  SizedBox(height: 12.h),
                  _buildCustomerForm(controller),
                  SizedBox(height: 24.h),

                  // Date & Time Selection
                  _buildSectionTitle('Select Date & Time'),
                  SizedBox(height: 12.h),
                  _buildDateTimeSelection(controller),
                  SizedBox(height: 24.h),

                  // Seat Selection
                  if (controller.selectedDate != null &&
                      controller.selectedTime != null) ...[
                    _buildSectionTitle('Select Seat'),
                    SizedBox(height: 12.h),
                    _buildSeatSelection(controller),
                    SizedBox(height: 24.h),
                  ],

                  // Booking Summary
                  if (controller.selectedService.isNotEmpty) ...[
                    _buildBookingSummary(controller),
                    SizedBox(height: 24.h),
                  ],

                  // Book Button
                  _buildBookButton(controller),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: Color(0xff1E2676),
      ),
    );
  }

  Widget _buildServicesGrid(BookingController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: controller.services.length,
      itemBuilder: (context, index) {
        final service = controller.services[index];
        final isSelected = controller.selectedService == service['name'];

        return GestureDetector(
          onTap: () {
            controller.setSelectedService(
              service['name'],
              service['price'].toDouble(),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xff1E2676) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected ? Color(0xff1E2676) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  service['name'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Color(0xff1E2676),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '₹${service['price'].toInt()}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isSelected ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerForm(BookingController controller) {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          onChanged: controller.setCustomerName,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Color(0xff1E2676), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _phoneController,
          onChanged: controller.setPhoneNumber,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Color(0xff1E2676), width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            if (value.trim().length < 10) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeSelection(BookingController controller) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(controller),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: Color(0xff1E2676)),
                  SizedBox(width: 8.w),
                  Text(
                    controller.selectedDate != null
                        ? '${controller.selectedDate!.day}/${controller.selectedDate!.month}/${controller.selectedDate!.year}'
                        : 'Select Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color:
                          controller.selectedDate != null
                              ? Colors.black
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectTime(controller),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_outlined, color: Color(0xff1E2676)),
                  SizedBox(width: 8.w),
                  Text(
                    controller.selectedTime != null
                        ? controller.selectedTime!.format(context)
                        : 'Select Time',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color:
                          controller.selectedTime != null
                              ? Colors.black
                              : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeatSelection(BookingController controller) {
    if (controller.isLoadingSeats) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1E2676)),
        ),
      );
    }

    return Container(
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
        children: [
          // Screen indicator
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

          // Seats grid
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
            ),
            itemCount: controller.allSeats.length, // DYNAMIC
            itemBuilder: (context, index) {
              String seatId = controller.allSeats[index]; // DYNAMIC
              // Use your status/selection color logic as before
              bool isBooked = controller.bookedSeats.contains(seatId);
              bool isDisabled = controller.disabledSeats.contains(seatId);
              bool isSelected = controller.selectedSeat == seatId;
              bool isAvailable = !isBooked && !isDisabled;

              Color seatColor;
              if (isSelected) {
                seatColor = Color(0xff1E2676);
              } else if (isBooked) {
                seatColor = Colors.red.shade400;
              } else if (isDisabled) {
                seatColor = Colors.grey.shade400;
              } else {
                seatColor = Colors.green.shade400;
              }

              return GestureDetector(
                onTap:
                    isAvailable
                        ? () => controller.setSelectedSeat(seatId)
                        : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: seatColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors.white.withOpacity(0.5)
                              : Colors.transparent,
                      width: 2,
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
                        if (isBooked) ...[
                          SizedBox(height: 2.h),
                          Icon(Icons.close, size: 10.sp, color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 16.h),

          // Legend - Fixed to show booked seats as red
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Colors.green.shade400, 'Available'),
              _buildLegendItem(Colors.grey.shade400, 'Disabled'),
              _buildLegendItem(Colors.red.shade400, 'Booked'),
              _buildLegendItem(Color(0xff1E2676), 'Selected'),
            ],
          ),

          // Seat count info
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSeatCount(
                  "Available",
                  controller.availableSeats.length,
                  Colors.green.shade600,
                ),
                _buildSeatCount(
                  "Booked",
                  controller.bookedSeats.length,
                  Colors.red.shade600,
                ),
                _buildSeatCount(
                  "Disabled",
                  controller.disabledSeats.length,
                  Colors.grey.shade600,
                ),
                _buildSeatCount(
                  "Total",
                  controller.allSeats.length,
                  Colors.grey.shade600,
                ),
              ],
            ),
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
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildBookingSummary(BookingController controller) {
    return Container(
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
            'Booking Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xff1E2676),
            ),
          ),
          SizedBox(height: 12.h),
          _buildSummaryRow('Service', controller.selectedService),
          _buildSummaryRow(
            'Date',
            controller.selectedDate != null
                ? '${controller.selectedDate!.day}/${controller.selectedDate!.month}/${controller.selectedDate!.year}'
                : '-',
          ),
          _buildSummaryRow(
            'Time',
            controller.selectedTime?.format(context) ?? '-',
          ),
          _buildSummaryRow(
            'Seat',
            controller.selectedSeat.isNotEmpty ? controller.selectedSeat : '-',
          ),
          Divider(),
          _buildSummaryRow(
            'Total Price',
            '₹${controller.totalPrice.toInt()}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? Color(0xff1E2676) : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? Color(0xff1E2676) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton(BookingController controller) {
    bool canBook =
        controller.selectedService.isNotEmpty &&
        controller.customerName.isNotEmpty &&
        controller.phoneNumber.isNotEmpty &&
        controller.selectedDate != null &&
        controller.selectedTime != null &&
        controller.selectedSeat.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed:
            canBook && !controller.isBooking
                ? () => _handleBooking(controller)
                : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff1E2676),
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
        ),
        child:
            controller.isBooking
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Booking...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                : Text(
                  'Book Appointment - ₹${controller.totalPrice.toInt()}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Widget _buildSeatCount(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Future<void> _selectDate(BookingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Color(0xff1E2676)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setSelectedDate(picked);
      // Load seats immediately after date selection
      await controller.loadAvailableSeats(widget.salonId);
    }
  }

  Future<void> _selectTime(BookingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Color(0xff1E2676)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setSelectedTime(picked);
      // Don't reload seats here since time doesn't matter for seat availability
    }
  }

  Future<void> _handleBooking(BookingController controller) async {
    if (_formKey.currentState!.validate()) {
      bool success = await controller.bookAppointment(widget.salonId);

      if (success) {
        await controller.loadAvailableSeats(widget.salonId);
        // Show success dialog

        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Booking Confirmed!',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1E2676),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Your appointment has been successfully booked.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(
                          context,
                        ).pop(); // Go back to previous screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff1E2676),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        );
        controller.clearMessages();
      }
    }
  }
}
