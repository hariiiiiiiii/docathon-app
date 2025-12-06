import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_layout.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  
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
        
        scaffoldBackgroundColor: Colors.white,

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF5A5F), // Coral for Buttons/FAB
          secondary: Color(0xFFFF5A5F),
          // surface: Colors.white,
          background: Colors.white,
          onSurface: Color(0xFF1D1D1D), // Dark text on surface
          onBackground: Color(0xFF1D1D1D),
        ),

        // Typography - Switched to light theme base so text defaults to black
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
          displayLarge: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1D1D1D)),
          headlineMedium: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1D1D1D)),
          bodyLarge: const TextStyle(color: Color(0xFF333333)), 
          bodyMedium: const TextStyle(color: Color(0xFF333333)), 
        ),
      ),
      home: const MainLayout(),
    );
  }
}