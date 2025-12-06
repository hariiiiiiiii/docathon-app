import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import Screens
import 'home_screen.dart'; 
import 'referral_screen.dart'; 
import 'rag_chatbot.dart'; 
import 'mental_health.dart'; 
import 'period_tracker.dart'; 

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  final List<Widget> _screens = [
    const HomeScreen(),            
    const PeriodTrackerScreen(),   
    const ReferralNetworkScreen(), 
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _showChatSelection(BuildContext context) {
    // Animate the button
    _fabController.forward().then((_) => _fabController.reverse());
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF003545), // Dark Teal Surface
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40, 
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.white24, 
                              borderRadius: BorderRadius.circular(2)
                            ),
                          ),
                        ),
                        Text(
                          "AI Assistance", 
                          style: GoogleFonts.poppins(
                            color: Colors.white, 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                        const SizedBox(height: 20),
                        
                        _buildBotTile(
                          context,
                          "Juno AI",
                          "Medical Assistant",
                          Icons.smart_toy_outlined,
                          Colors.cyanAccent, // Changed to Cyan
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatScreen())),
                          0,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildBotTile(
                          context,
                          "Serena AI",
                          "Mental Health Companion",
                          Icons.favorite_border,
                          const Color(0xFF64FFDA), // Teal Accent
                          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MentalHealthChatScreen())),
                          1,
                        ),
                        const SizedBox(height: 20),
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

  Widget _buildBotTile(
    BuildContext context, 
    String title, 
    String subtitle, 
    IconData icon, 
    Color color, 
    VoidCallback onTap,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        fontSize: 15,
                      )
                    ),
                    Text(
                      subtitle, 
                      style: GoogleFonts.poppins(
                        color: Colors.white60, 
                        fontSize: 12
                      )
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001219), // Deep dark teal/blue background
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const navBarColor = Color(0xFF003545); // Dark teal surface
    const accentColor = Color(0xFF00E5FF); // Cyan accent

    return Container(
      decoration: BoxDecoration(
        color: navBarColor,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05), 
            width: 1
          )
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_filled, "Home", 0, accentColor),
              _buildNavItem(Icons.calendar_month, "Tracker", 1, accentColor),
              _buildAIChatButton(accentColor),
              _buildNavItem(Icons.location_on_outlined, "Clinics", 2, accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color accentColor) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon, 
                  color: isSelected ? accentColor : Colors.white38,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: isSelected ? accentColor : Colors.white38,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(label),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIChatButton(Color accentColor) {
    return Expanded(
      child: InkWell(
        onTap: () => _showChatSelection(context),
        borderRadius: BorderRadius.circular(12),
        splashColor: accentColor.withOpacity(0.1),
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.1).animate(
                  CurvedAnimation(
                    parent: _fabController,
                    curve: Curves.elasticIn,
                  ),
                ),
                child: ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.2).animate(
                    CurvedAnimation(
                      parent: _fabController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: const Icon(
                    Icons.chat,
                    color: Colors.white38,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "AI Chat",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}