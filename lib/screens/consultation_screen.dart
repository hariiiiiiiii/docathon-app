import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'video_call_screen.dart';

// ---------------------------------------------------------------------------
// 1. DOCTOR SELECTION SCREEN (List View)
// ---------------------------------------------------------------------------
class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({Key? key}) : super(key: key);

  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // --- THEME CONSTANTS (Teal/Blue) ---
  static const backgroundColor = Color(0xFF001219); // Deep dark teal/blue
  static const surfaceColor = Color(0xFF003545);    // Dark teal surface
  static const accentColor = Color(0xFF00E5FF);     // Electric Cyan
  static const textColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Select a Doctor",
          style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: accentColor));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Unable to load doctors.", style: GoogleFonts.poppins(color: Colors.white54)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No doctors available.", style: GoogleFonts.poppins(color: Colors.white54)),
            );
          }

          final doctors = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: doctors.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final doc = doctors[index].data() as Map<String, dynamic>;
              final String name = doc['name'] ?? 'Unknown Doctor';
              final String specialty = doc['specialty'] ?? 'General Practitioner';

              return Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      final newRoomId = _generateRoomId();
                      
                      // Navigate to Join Screen instead of direct Video Call
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConsultationJoinScreen(
                            roomId: newRoomId,
                            doctorName: name,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.medical_services, color: accentColor, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  specialty,
                                  style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. CONSULTATION JOIN SCREEN (The screen with Random ID)
// ---------------------------------------------------------------------------
class ConsultationJoinScreen extends StatefulWidget {
  final String roomId;
  final String doctorName;

  const ConsultationJoinScreen({
    Key? key,
    required this.roomId,
    required this.doctorName,
  }) : super(key: key);

  @override
  State<ConsultationJoinScreen> createState() => _ConsultationJoinScreenState();
}

class _ConsultationJoinScreenState extends State<ConsultationJoinScreen> {
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // --- THEME CONSTANTS (Teal/Blue) ---
  static const backgroundColor = Color(0xFF001219); // Deep dark teal/blue
  static const surfaceColor = Color(0xFF003545);    // Dark teal surface
  static const accentColor = Color(0xFF00E5FF);     // Electric Cyan
  static const textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _roomController.text = widget.roomId;
  }

  @override
  void dispose() {
    _roomController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onJoin() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter your Name"),
          backgroundColor: surfaceColor,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          roomName: _roomController.text.trim(),
          displayName: _nameController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Join Consultation", style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600)),
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: textColor),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.videocam, size: 60, color: accentColor),
                ),
                const SizedBox(height: 30),
                Text(
                  "Virtual Waiting Room",
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Connecting with: ${widget.doctorName}",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                TextField(
                  controller: _nameController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Your Name",
                    labelStyle: GoogleFonts.poppins(color: Colors.white60),
                    filled: true,
                    fillColor: surfaceColor,
                    prefixIcon: const Icon(Icons.person_outline, color: accentColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: _roomController,
                  readOnly: true,
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: "Room ID",
                    labelStyle: GoogleFonts.poppins(color: Colors.white60),
                    filled: true,
                    fillColor: surfaceColor,
                    prefixIcon: const Icon(Icons.vpn_key_outlined, color: accentColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: _onJoin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: accentColor,
                    foregroundColor: backgroundColor, // Dark text on bright button
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Join Call", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}