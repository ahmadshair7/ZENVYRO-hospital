import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'opd_screen.dart';
import 'indoor_screen.dart';
import 'emergency_screen.dart';
import 'ot_screen.dart';
import 'pharmacy_screen.dart';
import 'admin_dashboard_screen.dart';
import 'staff_management_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF004B87);
    const secondaryTeal = Color(0xFF00A859);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, primaryBlue, secondaryTeal),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hospital Management',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a department to manage workflows',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildGrid(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Color primary, Color secondary) {
    return SliverAppBar(
      expandedHeight: 220,
      floating: false,
      pinned: true,
      backgroundColor: primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primary, primary.withOpacity(0.8)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: CircleAvatar(
                  radius: 100,
                  backgroundColor: Colors.white.withOpacity(0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/logo.png',
                        height: 40,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.local_hospital, color: Color(0xFF004B87), size: 30),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ZENVYRO HOSPITAL',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'Quality Care, Every Step of the Way',
                      style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildMenuCard(
          context,
          'OPD',
          'Out-Patient Dept.',
          Icons.person_search_rounded,
          const Color(0xFF2196F3),
          const OpdScreen(),
        ),
        _buildMenuCard(
          context,
          'Indoor',
          'Ward Management',
          Icons.bed_rounded,
          const Color(0xFF009688),
          const IndoorScreen(),
        ),
        _buildMenuCard(
          context,
          'Emergency',
          '24/7 Rapid Care',
          Icons.emergency_rounded,
          const Color(0xFFE91E63),
          const EmergencyScreen(),
        ),
        _buildMenuCard(
          context,
          'OT',
          'Surgical Units',
          Icons.medical_services_rounded,
          const Color(0xFF673AB7),
          const OtScreen(),
        ),
        _buildMenuCard(
          context,
          'Pharmacy',
          'Medicine Dispensing',
          Icons.local_pharmacy_rounded,
          const Color(0xFF4CAF50),
          const PharmacyScreen(),
        ),
        _buildMenuCard(
          context,
          'Management',
          'Hospital Admin',
          Icons.admin_panel_settings_rounded,
          const Color(0xFF607D8B),
          const AdminDashboardScreen(),
        ),
        _buildMenuCard(
          context,
          'Staff',
          'Team Manager',
          Icons.people_alt_rounded,
          const Color(0xFF795548),
          const StaffManagementScreen(),
        ),
      ],
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3436),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
