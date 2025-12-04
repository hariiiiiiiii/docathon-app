import 'dart:math'; 
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'consultation_screen.dart'; 

class LegalAdvisorProfileScreen extends StatelessWidget {
  const LegalAdvisorProfileScreen({Key? key}) : super(key: key);

  String _generateRoomId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  @override
  Widget build(BuildContext context) {
    // THEME CONSTANTS (Teal/Blue) 
    const backgroundColor = Color(0xFF001219); // Deep dark teal/blue
    const surfaceColor = Color(0xFF003545);    // Dark teal surface
    const accentColor = Color(0xFF00E5FF);     // Electric Cyan
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Legal Support", style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600)),
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: textColor),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Profile Image
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=5'), 
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Name & Title
            Text(
              "Adv. VJ",
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
              textAlign: TextAlign.center,
            ),
            Text(
              "Senior Legal Advisor • Child Rights & Healthcare",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Info Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.verified, "Verified Expert", accentColor),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.lock_outline, "100% Confidential Conversations", Colors.tealAccent),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.language, "Speaks English, Hindi, Marathi", Colors.blueAccent),
                  const Divider(height: 32, color: Colors.white10),
                  Text(
                    "About",
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "I specialize in the MTP Act, POCSO, and patient privacy rights. I am here to help you understand your legal options safely and without judgment.",
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70, height: 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to the video call setup with generated ID and Name
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConsultationJoinScreen(
                        roomId: _generateRoomId(),
                        doctorName: "Adv. VJ",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.video_call_rounded),
                label: Text("Start Secure Consultation", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: backgroundColor, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Available Mon-Fri, 10 AM - 6 PM",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}