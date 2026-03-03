import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';
import 'services/storage_service.dart';
import 'models/doctor_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  String? initError;
  try {
    // Initialize Local Storage
    await StorageService.init();
    print('Local Storage Initialized');
    
    await StorageService.loadTokens();
    print('Tokens Loaded');
    
    await StorageService.loadWards();
    print('Wards Loaded');
    
    final erTokens = await StorageService.loadEmergencyTokens();
    EmergencyTokenManager.setTokens(erTokens);
    print('Emergency Tokens Loaded');
  } catch (e) {
    print('Error during initialization: $e');
    initError = e.toString();
  }
  
  runApp(MyApp(error: initError));
}

class MyApp extends StatelessWidget {
  final String? error;
  const MyApp({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const primaryBlue = Color(0xFF004B87);
    const secondaryTeal = Color(0xFF00A859);
    const medicalRed = Color(0xFFE30613);

    return MaterialApp(
      title: 'ZENVYRO HOSPITAL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: secondaryTeal,
          error: medicalRed,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
        ),
      ),
      home: error != null 
        ? _ErrorView(error: error!)
        : const WelcomeScreen(),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(
                'Initialization Error',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'The app couldn\'t initialize local storage.\n\nDetails: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => main(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
