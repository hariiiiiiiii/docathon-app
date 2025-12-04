import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_layout.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TeenHealth',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        
      
        
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF5A5F), // Coral for Buttons/FAB
          secondary: Color(0xFFFF5A5F),
          //surface: Color(0xFF2B0C0C), // Dark Red/Brown for Cards
          background: Color(0xFF120505),
          onSurface: Colors.white,
        ),

        // Typography
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          headlineMedium: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: const TextStyle(color: Color(0xFFFFEAEA)), 
        ),

        
        
      ),
      home: const MainLayout(),
    );
  }
}