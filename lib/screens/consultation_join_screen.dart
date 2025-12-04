import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'video_call_screen.dart';

class ConsultationJoinScreen extends StatefulWidget {
  const ConsultationJoinScreen({super.key});

  @override
  State<ConsultationJoinScreen> createState() => _ConsultationJoinScreenState();
}

class _ConsultationJoinScreenState extends State<ConsultationJoinScreen> {
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _roomController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _onJoin() {
    if (_roomController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both Room ID and Your Name")),
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
    // Dark Cherry Theme Palette
    const backgroundColor = Color(0xFF120505);
    const surfaceColor = Color(0xFF2B0C0C);
    const accentColor = Color(0xFFFF5A5F);
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Join Consultation", style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.w600)),
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.video_camera_front, size: 60, color: accentColor),
                ),
                const SizedBox(height: 30),
                
                Text(
                  "Video Consultation",
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your details to join the secure video call with our expert.",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Name Input
                _buildDarkTextField(
                  controller: _nameController,
                  label: "Your Name",
                  icon: Icons.person_outline,
                  surfaceColor: surfaceColor,
                  accentColor: accentColor,
                ),
                const SizedBox(height: 16),
                
                // Room ID Input
                _buildDarkTextField(
                  controller: _roomController,
                  label: "Room ID",
                  icon: Icons.meeting_room_outlined,
                  surfaceColor: surfaceColor,
                  accentColor: accentColor,
                ),
                const SizedBox(height: 40),
                
                // Join Button
                ElevatedButton(
                  onPressed: _onJoin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Join Call",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
                // Removed the Terms & Privacy Policy text as requested
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color surfaceColor,
    required Color accentColor,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white60),
        filled: true,
        fillColor: surfaceColor,
        prefixIcon: Icon(icon, color: accentColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
      ),
    );
  }
}