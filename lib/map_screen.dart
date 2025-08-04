import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:salon_booking/salon_detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition = LatLng(12.899188, 77.667002);
  Set<Marker> _markers = {};
  bool _isLoading = true;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  bool _isSettingTextProgrammatically = false; // Add this flag

  // Dynamic salon count based on visible area
  int _visibleSalonCount = 0;

  // Replace with your Google Places API key
  static const String _placesApiKey = "AIzaSyD7iE3QAIxeHIZ18As8Q2oDPF7glJsk-vs";

  @override
  void initState() {
    super.initState();
    _fetchSalonsFromFirestore();

    // Add listener for search field
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _showSuggestions = false;
        });
      }
    });
  }

  // Fetch salons from Firestore and create markers
  Future<void> _fetchSalonsFromFirestore() async {
    try {
      setState(() {
        _isLoading = true;
      });

      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('salons').get();

      Set<Marker> markers = {};

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> salonData = doc.data() as Map<String, dynamic>;
        String salonId = doc.id;

        // Check if salon has required location data
        if (salonData['latitude'] != null && salonData['longitude'] != null) {
          double latitude = _parseDouble(salonData['latitude']);
          double longitude = _parseDouble(salonData['longitude']);
          String salonName = salonData['salon name'] ?? 'Unknown Salon';

          markers.add(
            Marker(
              markerId: MarkerId(salonId),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: salonName,
                snippet: salonData['address'] ?? 'Address not available',
              ),
              onTap: () {
                // Show bottom sheet when marker is tapped
                _showSalonBottomSheet(salonId, salonData);
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue, // You can customize marker color
              ),
            ),
          );
        }
      }

      setState(() {
        _markers = markers;
        _isLoading = false;
        _visibleSalonCount = markers.length; // Initialize with all salons
      });

      // Optionally adjust camera to show all markers
      if (markers.isNotEmpty && _mapController != null) {
        _fitMarkersInView();
      }
    } catch (e) {
      print('Error fetching salons: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load salon locations'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Search functionality methods - FIXED VERSION
  void _onSearchChanged() {
    // Don't trigger search if we're setting text programmatically
    if (_isSettingTextProgrammatically) return;

    if (_searchController.text.length > 2) {
      _searchPlaces(_searchController.text);
    } else {
      setState(() {
        _searchSuggestions.clear();
        _showSuggestions = false;
      });
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
          'input=$query&'
          'key=$_placesApiKey&'
          'location=${_initialPosition.latitude},${_initialPosition.longitude}&'
          'radius=50000&'
          'components=country:in'; // Restrict to India, change as needed

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          List<Map<String, dynamic>> suggestions = [];

          for (var prediction in data['predictions']) {
            suggestions.add({
              'place_id': prediction['place_id'],
              'description': prediction['description'],
              'main_text': prediction['structured_formatting']['main_text'],
              'secondary_text':
                  prediction['structured_formatting']['secondary_text'] ?? '',
            });
          }

          setState(() {
            _searchSuggestions = suggestions;
            _showSuggestions = true;
            _isSearching = false;
          });
        }
      }
    } catch (e) {
      print('Error searching places: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  // FIXED VERSION of _selectPlace method
  Future<void> _selectPlace(String placeId, String description) async {
    // Immediately hide suggestions and clear them
    setState(() {
      _showSuggestions = false;
      _searchSuggestions.clear();
    });

    // Unfocus the search field
    _searchFocusNode.unfocus();

    // Set the flag to prevent listener from triggering
    _isSettingTextProgrammatically = true;
    _searchController.text = description;
    _isSettingTextProgrammatically = false;

    // Get place details to get coordinates
    try {
      final String url =
          'https://maps.googleapis.com/maps/api/place/details/json?'
          'place_id=$placeId&'
          'fields=geometry&'
          'key=$_placesApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final LatLng targetPosition = LatLng(
            location['lat'].toDouble(),
            location['lng'].toDouble(),
          );

          // Animate camera to selected location
          if (_mapController != null) {
            await _mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(targetPosition, 14),
            );
          }
        }
      }
    } catch (e) {
      print('Error getting place details: $e');
    }
  }

  // Update visible salon count based on current camera bounds
  Future<void> _updateVisibleSalonCount() async {
    if (_mapController == null || _markers.isEmpty) return;

    try {
      LatLngBounds visibleRegion = await _mapController!.getVisibleRegion();

      int visibleCount = 0;
      for (Marker marker in _markers) {
        LatLng position = marker.position;

        // Check if marker is within visible bounds
        if (position.latitude >= visibleRegion.southwest.latitude &&
            position.latitude <= visibleRegion.northeast.latitude &&
            position.longitude >= visibleRegion.southwest.longitude &&
            position.longitude <= visibleRegion.northeast.longitude) {
          visibleCount++;
        }
      }

      if (mounted && visibleCount != _visibleSalonCount) {
        setState(() {
          _visibleSalonCount = visibleCount;
        });
      }
    } catch (e) {
      print('Error updating visible salon count: $e');
    }
  }

  // Helper method to parse double values safely
  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Show salon details in bottom sheet
  void _showSalonBottomSheet(String salonId, Map<String, dynamic> salonData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSalonBottomSheet(salonId, salonData),
    );
  }

  // Build salon details bottom sheet
  Widget _buildSalonBottomSheet(
    String salonId,
    Map<String, dynamic> salonData,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Salon image
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          'https://images.pexels.com/photos/1813272/pexels-photo-1813272.jpeg',
                        ),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
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
                        // Status badge
                        Positioned(
                          left: 15,
                          top: 15,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Open",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // Favorite button
                        Positioned(
                          right: 15,
                          top: 15,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.favorite_outline,
                              size: 20,
                              color: Color(0xff1E2676),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Salon name
                  Text(
                    salonData['salon name'] ?? 'Unknown Salon',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff1E2676),
                    ),
                  ),

                  SizedBox(height: 8),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          salonData['address'] ?? 'Address not available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Rating and reviews
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < 3
                                ? Icons.star
                                : starIndex == 3
                                ? Icons.star_half
                                : Icons.star_outline,
                            size: 18,
                            color: Colors.amber.shade600,
                          );
                        }),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "4.2",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff1E2676),
                        ),
                      ),
                      Text(
                        " (56 reviews)",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Contact info
                  if (salonData['phone number'] != null)
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 6),
                        Text(
                          salonData['phone number'].toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 12),

                  // Opening hours
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "9:00 AM - 8:00 PM",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Quick services preview
                  Text(
                    "Popular Services",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff1E2676),
                    ),
                  ),

                  SizedBox(height: 12),

                  Container(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildServiceChip("Haircut"),
                        _buildServiceChip("Beard Trim"),
                        _buildServiceChip("Styling"),
                        _buildServiceChip("Facial"),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Call button
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        // Handle call functionality
                        Navigator.pop(context);
                        // Add call functionality here
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xff1E2676)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, color: Color(0xff1E2676), size: 18),
                          SizedBox(width: 4),
                          Text(
                            "Call",
                            style: TextStyle(
                              color: Color(0xff1E2676),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12),

                // Book Now button
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToSalonDetail(salonId, salonData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff1E2676),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Book Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  // Build service chip widget
  Widget _buildServiceChip(String service) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xff1E2676).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        service,
        style: TextStyle(
          color: Color(0xff1E2676),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Navigate to salon detail screen
  void _navigateToSalonDetail(String salonId, Map<String, dynamic> salonData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                SalonDetailScreen(salonId: salonId, salonData: salonData),
      ),
    );
  }

  // Adjust camera to fit all markers in view
  void _fitMarkersInView() async {
    if (_markers.isEmpty || _mapController == null) return;

    // Calculate bounds for all markers
    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (Marker marker in _markers) {
      minLat =
          minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat =
          maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng =
          minLng < marker.position.longitude
              ? minLng
              : marker.position.longitude;
      maxLng =
          maxLng > marker.position.longitude
              ? maxLng
              : marker.position.longitude;
    }

    // Add some padding
    double padding = 0.01;
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat - padding, minLng - padding),
      northeast: LatLng(maxLat + padding, maxLng + padding),
    );

    // Animate camera to fit bounds
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100.0),
    );
  }

  // Refresh salons data
  Future<void> _refreshSalons() async {
    await _fetchSalonsFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Salon Locations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xff1E2676),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshSalons,
            icon: Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            onPressed: () {
              if (_markers.isNotEmpty) {
                _fitMarkersInView();
              }
            },
            icon: Icon(Icons.center_focus_strong, color: Colors.white),
            tooltip: 'Fit all salons in view',
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // Fit markers in view after map is created
              // if (_markers.isNotEmpty) {
              //   Future.delayed(Duration(milliseconds: 500), () {
              //     _fitMarkersInView();
              //   });
              // }
            },
            onTap: (LatLng position) {
              // Hide suggestions when map is tapped
              setState(() {
                _showSuggestions = false;
                _searchSuggestions.clear();
              });
              _searchFocusNode.unfocus();
            },
            onCameraMove: (CameraPosition position) {
              // Update visible salon count as camera moves
              _updateVisibleSalonCount();
            },
            onCameraIdle: () {
              // Final update when camera stops moving
              _updateVisibleSalonCount();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: false,
          ),

          // Search bar overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Search input field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search for a location...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xff1E2676),
                        size: 24,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                onPressed: () {
                                  _isSettingTextProgrammatically = true;
                                  _searchController.clear();
                                  _isSettingTextProgrammatically = false;
                                  setState(() {
                                    _showSuggestions = false;
                                    _searchSuggestions.clear();
                                  });
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey.shade600,
                                  size: 20,
                                ),
                              )
                              : _isSearching
                              ? Container(
                                width: 20,
                                height: 20,
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xff1E2676),
                                  ),
                                ),
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onTap: () {
                      if (_searchSuggestions.isNotEmpty) {
                        setState(() {
                          _showSuggestions = true;
                        });
                      }
                    },
                  ),
                ),

                // Search suggestions
                if (_showSuggestions && _searchSuggestions.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _searchSuggestions.take(5).length,
                      separatorBuilder:
                          (context, index) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                      itemBuilder: (context, index) {
                        final suggestion = _searchSuggestions[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: Color(0xff1E2676),
                            size: 20,
                          ),
                          title: Text(
                            suggestion['main_text'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle:
                              suggestion['secondary_text'].isNotEmpty
                                  ? Text(
                                    suggestion['secondary_text'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  )
                                  : null,
                          onTap: () {
                            _selectPlace(
                              suggestion['place_id'],
                              suggestion['description'],
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xff1E2676),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading salon locations...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Dynamic salon count indicator
          if (!_isLoading && !_showSuggestions)
            Positioned(
              bottom: 100,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.store, size: 16, color: Color(0xff1E2676)),
                    SizedBox(width: 4),
                    Text(
                      '$_visibleSalonCount Salon${_visibleSalonCount == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: Color(0xff1E2676),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
