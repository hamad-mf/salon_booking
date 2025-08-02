import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Loading states
  bool _isLoading = false;
  bool _isBooking = false;
  bool _isLoadingSeats = false;

  // Form data
  String _selectedService = '';
  String _customerName = '';
  String _phoneNumber = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedSeat = '';
  double _totalPrice = 0.0;

  // Available data
  List<Map<String, dynamic>> _services = [];
  List<String> _availableSeats = [];
  List<String> _bookedSeats = [];
  List<String> _disabledSeats = [];
  String _errorMessage = '';
  String _successMessage = '';

  List<String> allSeats = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isBooking => _isBooking;
  bool get isLoadingSeats => _isLoadingSeats;
  String get selectedService => _selectedService;
  String get customerName => _customerName;
  String get phoneNumber => _phoneNumber;
  DateTime? get selectedDate => _selectedDate;
  TimeOfDay? get selectedTime => _selectedTime;
  String get selectedSeat => _selectedSeat;
  double get totalPrice => _totalPrice;
  List<Map<String, dynamic>> get services => _services;
  List<String> get availableSeats => _availableSeats;
  List<String> get bookedSeats => _bookedSeats;
  List<String> get disabledSeats => _disabledSeats;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  // Clear messages
  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }

  // Set form data
  void setSelectedService(String service, double price) {
    _selectedService = service;
    _totalPrice = price;
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _selectedSeat = ''; // reset seat on date change
    notifyListeners();
  }

  void setSelectedTime(TimeOfDay time) {
    _selectedTime = time;
    _selectedSeat = ''; // reset seat on time change
    notifyListeners();
  }

  void setSelectedSeat(String seat) {
    _selectedSeat = seat;
    notifyListeners();
  }

  // Load services for the salon
  Future<void> loadServices(String salonId) async {
    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      DocumentSnapshot salonDoc = await _firestore.collection('salons').doc(salonId).get();

      if (salonDoc.exists) {
        Map<String, dynamic>? data = salonDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('services')) {
          List<dynamic> servicesData = data['services'] ?? [];
          _services = servicesData.cast<Map<String, dynamic>>();
        } else {
          _setDefaultServices();
        }
      } else {
        _setDefaultServices();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load services: $e';
      notifyListeners();
    }
  }

  void _setDefaultServices() {
    _services = [
      {'name': 'Haircut', 'price': 500.0, 'duration': 30},
      {'name': 'Beard Trim', 'price': 200.0, 'duration': 15},
      {'name': 'Hair Wash', 'price': 150.0, 'duration': 20},
      {'name': 'Styling', 'price': 300.0, 'duration': 25},
      {'name': 'Coloring', 'price': 800.0, 'duration': 60},
      {'name': 'Facial', 'price': 600.0, 'duration': 45},
    ];
  }

  // Load disabled seats from salon config
  Future<void> _loadDisabledSeats(String salonId) async {
    try {
      DocumentSnapshot salonDoc = await _firestore.collection('salons').doc(salonId).get();

      if (salonDoc.exists) {
        Map<String, dynamic>? data = salonDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('disabledSeats')) {
          List<dynamic> disabled = data['disabledSeats'] ?? [];
          _disabledSeats = disabled.cast<String>();
        } else {
          _disabledSeats = [];
        }
      } else {
        _disabledSeats = [];
      }
    } catch (e) {
      _disabledSeats = [];
    }
  }

  // Generate dynamic seat labels
  List<String> generateSeatLabels(int totalSeats, {int seatsPerRow = 5}) {
    List<String> seatLabels = [];
    List<String> rowLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');
    int seatCount = 0;
    int rowIndex = 0;

    while (seatCount < totalSeats) {
      if (rowIndex >= rowLetters.length) break; // safeguard
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

  // Load available seats for selected date/time
  Future<void> loadAvailableSeats(String salonId) async {
    if (_selectedDate == null) return;

    try {
      _isLoadingSeats = true;
      _errorMessage = '';
      notifyListeners();

      // Load disabled seats first
      await _loadDisabledSeats(salonId);

      // Fetch salon data to get total seats
      DocumentSnapshot salonDoc = await _firestore.collection('salons').doc(salonId).get();
      Map<String, dynamic>? salonData = salonDoc.data() as Map<String, dynamic>?;

    int totalSeats = 20; // fallback default
if (salonData != null && salonData.containsKey('no of seats')) {
  final seatsVal = salonData['no of seats'];
  if (seatsVal is int && seatsVal > 0) totalSeats = seatsVal;
}
allSeats = generateSeatLabels(totalSeats);

      // Generate all seats dynamically based on salon configuration
      allSeats = generateSeatLabels(totalSeats);

      // Create string of the selected date (without time)
      String dateString =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      // Query bookings for this date, only confirmed or pending
      QuerySnapshot bookingsSnapshot = await _firestore
          .collection('salons')
          .doc(salonId)
          .collection('bookings')
          .where('dateString', isEqualTo: dateString)
          .where('status', whereIn: ['confirmed', 'pending'])
          .get();

      // Extract booked seats for this date
      _bookedSeats.clear();
      for (var doc in bookingsSnapshot.docs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('seat')) {
          String seat = data['seat']?.toString() ?? '';
          if (seat.isNotEmpty) {
            _bookedSeats.add(seat);
          }
        }
      }

      // Compute available seats by excluding booked and disabled
      _availableSeats = allSeats.where((seat) => !_bookedSeats.contains(seat) && !_disabledSeats.contains(seat)).toList();

      // Clear selected seat if now invalid
      if (_selectedSeat.isNotEmpty &&
          (_bookedSeats.contains(_selectedSeat) || _disabledSeats.contains(_selectedSeat))) {
        _selectedSeat = '';
      }

      _isLoadingSeats = false;
      notifyListeners();
    } catch (e) {
      _isLoadingSeats = false;
      _errorMessage = 'Failed to load seats: $e';
      notifyListeners();
    }
  }

  // Toggle seat selection on tap
  void toggleSeat(String seatId) {
    if (_selectedSeat == seatId) {
      _selectedSeat = '';
    } else if (isSeatAvailable(seatId)) {
      _selectedSeat = seatId;
    }
    notifyListeners();
  }

  // Stub: Show details for booked seat (implement UI trigger yourself)
  void showBookingDetails(BuildContext context, String seatId, Map<String, dynamic>? bookingDetails) {
    // Implement your custom dialog or navigation here
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Seat $seatId Booking'),
        content: bookingDetails != null
            ? Text('Booking info:\nService: ${bookingDetails['service']}\nStatus: ${bookingDetails['status']}')
            : Text('No details available'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Validate form fields before booking
  bool _validateForm() {
    if (_selectedService.isEmpty) {
      _errorMessage = 'Please select a service';
      return false;
    }
    if (_customerName.trim().isEmpty) {
      _errorMessage = 'Please enter your name';
      return false;
    }
    if (_phoneNumber.trim().isEmpty) {
      _errorMessage = 'Please enter your phone number';
      return false;
    }
    if (_phoneNumber.trim().length < 10) {
      _errorMessage = 'Please enter a valid phone number';
      return false;
    }
    if (_selectedDate == null) {
      _errorMessage = 'Please select a date';
      return false;
    }
    if (_selectedTime == null) {
      _errorMessage = 'Please select a time';
      return false;
    }
    if (_selectedSeat.isEmpty) {
      _errorMessage = 'Please select a seat';
      return false;
    }
    if (_bookedSeats.contains(_selectedSeat)) {
      _errorMessage = 'Selected seat is already booked. Please choose another seat.';
      return false;
    }
    if (_disabledSeats.contains(_selectedSeat)) {
      _errorMessage = 'Selected seat is disabled. Please choose another seat.';
      return false;
    }
    _errorMessage = '';
    return true;
  }

  // Generate unique booking ID
  String _generateUniqueBookingId() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int random = (DateTime.now().microsecond * 1000) % 10000;
    return '${timestamp}_$random';
  }

  // Book appointment with pending status (needs verification)
  Future<bool> bookAppointment(String salonId) async {
    try {
      if (!_validateForm()) {
        notifyListeners();
        return false;
      }

      _isBooking = true;
      _errorMessage = '';
      _successMessage = '';
      notifyListeners();

      // Create date/time strings
      String dateString =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      String timeString =
          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      // Generate booking ID
      String bookingId = _generateUniqueBookingId();

      // Prepare booking data
      Map<String, dynamic> bookingData = {
        'bookingId': bookingId,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'customerName': _customerName.trim(),
        'phoneNumber': _phoneNumber.trim(),
        'service': _selectedService,
        'price': _totalPrice,
        'date': Timestamp.fromDate(_selectedDate!),
        'dateString': dateString,
        'time': timeString,
        'seat': _selectedSeat,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'salonId': salonId,
      };

      // Save booking
      await _firestore.collection('salons').doc(salonId).collection('bookings').doc(bookingId).set(bookingData);

      _successMessage = 'Appointment booked successfully! Waiting for salon verification.';
      _isBooking = false;

      _clearForm();

      notifyListeners();
      return true;
    } catch (e) {
      _isBooking = false;
      _errorMessage = 'Failed to book appointment: $e';
      notifyListeners();
      return false;
    }
  }

  // Get user bookings stream
  Stream<QuerySnapshot> getUserBookings(String phoneNumber) {
    return _firestore
        .collectionGroup('bookings')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Seat availability check
  bool isSeatAvailable(String seatId) {
    return !_bookedSeats.contains(seatId) && !_disabledSeats.contains(seatId);
  }

  // Get seat status
  String getSeatStatus(String seatId) {
    if (_bookedSeats.contains(seatId)) {
      return 'booked';
    } else if (_disabledSeats.contains(seatId)) {
      return 'disabled';
    } else {
      return 'available';
    }
  }

  // Clear form data
  void _clearForm() {
    _selectedService = '';
    _customerName = '';
    _phoneNumber = '';
    _selectedDate = null;
    _selectedTime = null;
    _selectedSeat = '';
    _totalPrice = 0.0;

    _availableSeats.clear();
    _bookedSeats.clear();
    _disabledSeats.clear();
  }

  // Reset entire controller
  void reset() {
    _clearForm();
    _errorMessage = '';
    _successMessage = '';
    _isLoading = false;
    _isBooking = false;
    _isLoadingSeats = false;
    notifyListeners();
  }
}
