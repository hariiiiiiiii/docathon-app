import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; 

// Import navigation targets
import 'consultation_screen.dart'; 
import 'referral_screen.dart'; 
import 'articles_screen.dart';
import 'article_detail.dart';
import 'rag_chatbot.dart'; 
import 'legal.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001219), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("TeenHealth", 
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF003545), // Dark teal surface
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white54),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Big Banner Card 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF005F73), Color(0xFF001219)], // Teal to dark teal gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.topRight,
                      child: Icon(Icons.spa, color: Colors.white24, size: 60),
                    ),
                    const SizedBox(height: 10),
                    Text("Your health journey,", 
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text("Private, Secure & Empowered.", 
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // The Grid (4 Buttons) 
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildGridCard(
                    context, 
                    "Info Hub", "Read Articles", Icons.menu_book_rounded, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesListScreen()))
                  ),
                  _buildGridCard(
                    context, 
                    "Teleconsult", "Talk to a Doctor", Icons.video_camera_front_rounded, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsultationScreen()))
                  ),
                  _buildGridCard(
                    context, 
                    "Find Clinics", "Map View", Icons.location_on_rounded, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralNetworkScreen()))
                  ),
                  _buildGridCard(
                    context, 
                    "Legal Help", "Talk to Advisor", Icons.gavel_rounded, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalAdvisorProfileScreen())), 
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // For You
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("For You", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  
                  // Wrap "See All" in GestureDetector
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ArticlesListScreen()));
                    },
                    child: Padding( // Add padding for easier tapping
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                      child: Text("See All", style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF00E5FF), fontWeight: FontWeight.bold)), // Cyan accent
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 160,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('articles').limit(5).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No articles yet", style: TextStyle(color: Colors.white54)));
                    }

                    final docs = snapshot.data!.docs;
                    
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        // Updated to cool colors
                        final cardColor = [
                          Colors.teal.shade800,
                          Colors.cyan.shade800,
                          Colors.blue.shade800,
                          Colors.indigo.shade800
                        ][index % 4];

                        return _buildForYouCard(
                          context,
                          cardColor,
                          data['title'] ?? 'Untitled',
                          data['category'] ?? 'Article',
                          data, 
                        );
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 40), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Material(
      color: const Color(0xFF003545), // Dark teal surface
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF00E5FF), size: 24), // Cyan accent
              ),
              const Spacer(),
              Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForYouCard(BuildContext context, Color color, String title, String subtitle, Map<String, dynamic> data) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => ArticleDetailScreen(articleData: data))
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title, 
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}