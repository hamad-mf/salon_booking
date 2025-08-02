import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';
import 'package:salon_booking/Controller/salon_add_controller.dart';

class AddSalonScreen extends StatefulWidget {
  const AddSalonScreen({super.key});

  @override
  State<AddSalonScreen> createState() => _AddSalonScreenState();
}

class _AddSalonScreenState extends State<AddSalonScreen> {
  final FocusNode _placesSearchFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final _salonNameController = TextEditingController();
  final _seatsController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeCOntroller = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _placesController = TextEditingController();

  // Location variables
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;
  String _locationMethod = 'manual'; // 'manual', 'current', 'places'

  // Google Places API Key - Add your API key here
  final String _googleApiKey = "AIzaSyD7iE3QAIxeHIZ18As8Q2oDPF7glJsk-vs";

  @override
  void dispose() {
      _placesSearchFocusNode.dispose(); 
    _salonNameController.dispose();
    _seatsController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _placesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final salonAddController = context.watch<SalonAddController>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffB5362D),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          "Add Your Salon",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 60.h,
                            width: 60.w,
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: Color(0xffB5362D).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: Icon(
                              Icons.add_business,
                              color: Color(0xffB5362D),
                              size: 30.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "Register Your Salon",
                            style: TextStyle(
                              color: Color(0xffB5362D),
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "Fill in the details below to add your salon to SalonHub",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // Form Fields
                    _buildInputField(
                      label: "Salon Name",
                      controller: _salonNameController,
                      icon: Icons.store,
                      hintText: "Enter your salon name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter salon name';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),

                    _buildInputField(
                      label: "Total Number of Seats",
                      controller: _seatsController,
                      icon: Icons.chair,
                      hintText: "e.g., 10",
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of seats';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),

                    _buildInputField(
                      label: "Phone Number",
                      controller: _phoneController,
                      icon: Icons.phone,
                      hintText: "Enter contact number",
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }String cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanNumber.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
                        return null;
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Location Selection Section
                    _buildLocationSection(),

                    SizedBox(height: 20.h),
                    _buildInputField(
                      label: "Address",
                      controller: _addressController,
                      icon: Icons.location_on,
                      hintText: "Enter your address",
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    _buildInputField(
                      label: "Description (Optional)",
                      controller: _descriptionController,
                      icon: Icons.description,
                      hintText: "Brief description about your salon",
                      maxLines: 4,
                    ),

                    SizedBox(height: 40.h),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed:
                            salonAddController.isloading
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    if (_latitude == null ||
                                        _longitude == null) {

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Please select a location for your salon",
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    final result = await context
                                        .read<SalonAddController>()
                                        .onAddSalon(
                                          address:
                                              _addressController.text.trim(),
                                          context: context,
                                          no_of_seats: int.parse(
                                            _seatsController.text,
                                          ),
                                          phone_no: int.parse(
                                            _phoneController.text,
                                          ),
                                          salonName:
                                              _salonNameController.text.trim(),
                                          latitude: _latitude!,
                                          longitude: _longitude!,
                                        );
                                    if (result && mounted) {
                                      _showSuccessDialog();
                                    }
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffB5362D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          "Add Salon",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Cancel Button
                    Container(
                      width: double.infinity,
                      height: 50.h,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Color(0xffB5362D), width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Color(0xffB5362D),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (salonAddController.isloading || _isLoadingLocation)
            Container(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xffB5362D)),
              ),
            ),
        ],
      ),
    );
  }
void _updateManualLocation() {
  setState(() {
    _latitude = double.tryParse(_latitudeController.text);
    _longitude = double.tryParse(_longitudeCOntroller.text);
  });
}
  Widget _buildLocationSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Location",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),

          // Location Method Selection
          Row(
            children: [
              Expanded(
                child: _buildLocationOption(
                  title: "Manual",
                  subtitle: "Enter address manually",
                  icon: Icons.edit_location,
                  value: 'manual',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildLocationOption(
                  title: "Current",
                  subtitle: "Use current location",
                  icon: Icons.my_location,
                  value: 'current',
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildLocationOption(
                  title: "Search",
                  subtitle: "Search places",
                  icon: Icons.search,
                  value: 'places',
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Location Input Based on Selection
          if (_locationMethod == 'manual') _buildManualLocationInput(),
          if (_locationMethod == 'current') _buildCurrentLocationButton(),
          if (_locationMethod == 'places') _buildPlacesSearch(),

          // Display Selected Coordinates
          if (_latitude != null && _longitude != null)
            Container(
              margin: EdgeInsets.only(top: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Color(0xffB5362D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Color(0xffB5362D),
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      "Location: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}",
                      style: TextStyle(
                        color: Color(0xffB5362D),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    bool isSelected = _locationMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _locationMethod = value;
          // Clear previous location data when switching methods
          if (value != _locationMethod) {
            _latitude = null;
            _longitude = null;
            _addressController.clear();
            _placesController.clear();
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color:
              // ignore: deprecated_member_use
              isSelected ? Color(0xffB5362D).withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? Color(0xffB5362D) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xffB5362D) : Colors.grey[600],
              size: 20.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Color(0xffB5362D) : Colors.grey[800],
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 8.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualLocationInput() {
    return Row(
      children: [
        Expanded(
          child: _buildCompactInputField(
            label: "Latitude",
            controller: _latitudeController,
            hintText: "Enter latitude",
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildCompactInputField(
            label: "Longitude",
            controller: _longitudeCOntroller,
            hintText: "Enter longitude",
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentLocationButton() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton.icon(
            onPressed: _getCurrentLocation,
            icon: Icon(Icons.my_location, color: Colors.white, size: 20.sp),
            label: Text(
              "Get Current Location",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xffB5362D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        if (_addressController.text.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 12.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              _addressController.text,
              style: TextStyle(color: Colors.grey[700], fontSize: 12.sp),
            ),
          ),
      ],
    );
  }

  Widget _buildPlacesSearch() {
    return GooglePlaceAutoCompleteTextField(
      textEditingController: _placesController,
      focusNode: _placesSearchFocusNode,
      googleAPIKey: _googleApiKey,
      inputDecoration: InputDecoration(
        hintText: "Search for your salon location",
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        prefixIcon: Icon(Icons.search, color: Color(0xffB5362D), size: 20.sp),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xffB5362D), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      debounceTime: 400,
      isLatLngRequired: true,
      getPlaceDetailWithLatLng: (Prediction prediction) {
        setState(() {
          _latitude = double.tryParse(prediction.lat ?? '');
          _longitude = double.tryParse(prediction.lng ?? '');
          _addressController.text = prediction.description ?? '';
        });
      },
      itemClick: (Prediction prediction) {
        _placesController.text = prediction.description ?? '';
        setState(() {
          _latitude = double.tryParse(prediction.lat ?? '');
          _longitude = double.tryParse(prediction.lng ?? '');
          _addressController.text = prediction.description ?? '';
        });
      },
      seperatedBuilder: Divider(color: Colors.grey[300]),
      containerHorizontalPadding: 0.w,
      itemBuilder: (context, index, Prediction prediction) {
        return Container(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Color(0xffB5362D), size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.structuredFormatting?.mainText ??
                          prediction.description ??
                          '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (prediction.structuredFormatting?.secondaryText != null)
                      Text(
                        prediction.structuredFormatting!.secondaryText!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = [
          place.name,
          place.street,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((element) => element != null && element.isNotEmpty).join(', ');

        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _addressController.text = address;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Location retrieved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error getting location: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

 Widget _buildCompactInputField({
  required String label,
  required TextEditingController controller,
  required String hintText,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: true), // Add this
    onChanged: (value) => _updateManualLocation(), // Add this
    validator: (value) { // Add validation
      if (value == null || value.isEmpty) {
        return 'Required';
      }
      if (double.tryParse(value) == null) {
        return 'Invalid';
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: label,
      hintText: hintText,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
    ),
  );
}

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_locationMethod != 'manual' || label != "Address")
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (_locationMethod != 'manual' || label != "Address")
          SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          enabled: _locationMethod == 'manual' || label != "Address",
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            prefixIcon: Icon(icon, color: Color(0xffB5362D), size: 20.sp),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Color(0xffB5362D), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 60.h,
                width: 60.w,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Success!",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Your salon has been added successfully!",
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to home
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffB5362D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
