import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math'; 

class ReferralNetworkScreen extends StatefulWidget {
  const ReferralNetworkScreen({Key? key}) : super(key: key);

  @override
  State<ReferralNetworkScreen> createState() => _ReferralNetworkScreenState();
}

class _ReferralNetworkScreenState extends State<ReferralNetworkScreen> {
  Position? _currentPosition;
  bool _isLoading = true;
  String _statusMessage = "Locating nearby clinics...";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // 1. Get User's Current GPS Location
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Location permissions are permanently denied.";
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false; 
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Error getting location.";
      });
    }
  }

  // 2. Open Google Maps
  Future<void> _openMap(double lat, double long) async {
    final Uri googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$long");
    if (!await launchUrl(googleMapsUrl)) {
      throw Exception('Could not launch maps');
    }
  }

  // Helper to add Dummy Data (Kept for testing, styled to match)
  Future<void> _addDemoData() async {
    if (_currentPosition == null) return;
    
    final db = FirebaseFirestore.instance;
    final random = Random();
    
    List<String> names = ["City Health Center", "Green Cross Clinic", "Apollo Diagnostics", "Dr. Lal PathLabs", "Rapid Response Care"];
    
    for (var name in names) {
      double latOffset = (random.nextDouble() - 0.5) * 0.05; 
      double lngOffset = (random.nextDouble() - 0.5) * 0.05;

      await db.collection('clinics').add({
        'name': name,
        'address': "${random.nextInt(100)} Wellness Ave, City",
        'phone': "9876543210",
        'speciality': ["General", "Cardiology", "Diagnostics", "Gynecology"][random.nextInt(4)],
        'location': GeoPoint(
          _currentPosition!.latitude + latOffset, 
          _currentPosition!.longitude + lngOffset
        ),
      });
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Test clinics added nearby."),
        backgroundColor: const Color(0xFF00E5FF), // Cyan
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- THEME CONSTANTS (UPDATED) ---
    const backgroundColor = Color(0xFF001219); // Deep dark teal/blue
    const surfaceColor = Color(0xFF003545);    // Dark teal surface
    const accentColor = Color(0xFF00E5FF);     // Electric Cyan
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Nearby Clinics", style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600)),
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: textColor),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _determinePosition,
          )
        ],
      ),
      // Styled Floating Button for Test Data
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDemoData,
        label: Text("Add Test Data", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF001219))),
        icon: const Icon(Icons.add_location_alt, color: Color(0xFF001219)),
        backgroundColor: accentColor,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: accentColor),
                  const SizedBox(height: 16),
                  Text(_statusMessage, style: GoogleFonts.poppins(color: Colors.white60)),
                ],
              ),
            )
          : _currentPosition == null
              ? Center(child: Text(_statusMessage, style: GoogleFonts.poppins(color: Colors.white60)))
              : _buildNearestClinicsList(surfaceColor, accentColor),
    );
  }

  Widget _buildNearestClinicsList(Color surfaceColor, Color accentColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('clinics').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: accentColor));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off_outlined, size: 60, color: Colors.white24),
                const SizedBox(height: 16),
                Text("No clinics found nearby.", style: GoogleFonts.poppins(color: Colors.white60)),
              ],
            ),
          );
        }

        final userLat = _currentPosition!.latitude;
        final userLong = _currentPosition!.longitude;

        // Process & Sort
        List<Map<String, dynamic>> clinics = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          
          GeoPoint? geo;
          if (data['location'] is GeoPoint) {
            geo = data['location'];
          }
          
          double distance = double.infinity; 
          if (geo != null) {
            distance = Geolocator.distanceBetween(
                userLat, userLong, geo.latitude, geo.longitude);
          }

          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown Clinic',
            'address': data['address'] ?? 'No address',
            'speciality': data['speciality'] ?? 'General',
            'distance': distance, 
            'latitude': geo?.latitude,
            'longitude': geo?.longitude,
          };
        }).toList();

        clinics.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: clinics.length,
          itemBuilder: (context, index) {
            final clinic = clinics[index];
            final double distanceMeters = clinic['distance'] as double;
            String distanceString;
            
            if (distanceMeters > 1000000) {
              distanceString = "?";
            } else if (distanceMeters >= 1000) {
              distanceString = "${(distanceMeters / 1000).toStringAsFixed(1)} km";
            } else {
              distanceString = "${distanceMeters.toStringAsFixed(0)} m";
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showReferralDialog(context, clinic['name']),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Icon Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.local_hospital_rounded, color: accentColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        
                        // Text Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clinic['name'], 
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, 
                                  color: Colors.white,
                                  fontSize: 16
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    clinic['speciality'],
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 4, height: 4, 
                                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle)
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    distanceString,
                                    style: GoogleFonts.poppins(color: accentColor, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                clinic['address'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
                              ),
                            ],
                          ),
                        ),

                        // Direction Button
                        IconButton(
                          icon: const Icon(Icons.near_me_outlined, color: Colors.white54),
                          onPressed: () {
                            if (clinic['latitude'] != null && clinic['longitude'] != null) {
                              _openMap(clinic['latitude'], clinic['longitude']);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Location coordinates missing")));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showReferralDialog(BuildContext context, String clinicName) {
    const dialogBg = Color(0xFF003545); // Dark Teal Surface
    const accentColor = Color(0xFF00E5FF); // Electric Cyan
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: dialogBg,
        title: Text("Refer Patient?", style: GoogleFonts.poppins(color: Colors.white)),
        content: Text(
          "Send referral details to $clinicName.",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text("Cancel", style: TextStyle(color: Colors.white54))
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Referral sent to $clinicName!"),
                  backgroundColor: accentColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: accentColor),
            child: Text("Send", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF001219))),
          ),
        ],
      ),
    );
  }
}