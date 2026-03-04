import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, int> _stats = {};
  int _todayPatients = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final stats = await StorageService.getAdminDetailedStats();
    if (!mounted) return;
    setState(() {
      _stats = stats.map((k, v) => MapEntry(k, v as int));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF004B87);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('ADMINISTRATIVE PANEL'),
        backgroundColor: primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandedHeader(context, primaryBlue),
                    _buildQuickStatsGrid(primaryBlue),
                    _buildSectionHeader('Bed & Facility Management'),
                    _buildDetailedOccupancyView(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBrandedHeader(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Overview', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.bold)),
                  Text(
                    '${_stats['todayTotal'] ?? 0}',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, height: 1),
                  ),
                  Text('Patients registered today', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
        children: [
          _buildMiniStatCard('OPD Patients', '${_stats['opdActive'] ?? 0}', Icons.people_outline_rounded, Colors.blue),
          _buildMiniStatCard('ER Active', '${_stats['emergencyOccupied'] ?? 0}', Icons.emergency_rounded, Colors.red),
          _buildMiniStatCard('Indoor/Ward', '${_stats['indoorOccupied'] ?? 0}', Icons.hotel_rounded, Colors.teal),
          _buildMiniStatCard('On-Duty Staff', '${_stats['staffOnDuty'] ?? 0}', Icons.badge_rounded, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              Icon(icon, size: 14, color: color),
            ],
          ),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: Colors.blueGrey.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildDetailedOccupancyView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildDetailedOccupancyCard(
            'Emergency Units',
            'Critical Care Availability',
            Icons.emergency_rounded,
            Colors.red,
            _stats['emergencyOccupied'] ?? 0,
            _stats['emergencyTotal'] ?? 1,
            _stats['emergencyFree'] ?? 0,
          ),
          const SizedBox(height: 16),
          _buildDetailedOccupancyCard(
            'Indoor Wards',
            'Sub-Specialty Admissions',
            Icons.hotel_rounded,
            Colors.teal,
            _stats['indoorOccupied'] ?? 0,
            _stats['indoorTotal'] ?? 1,
            _stats['indoorFree'] ?? 0,
          ),
          const SizedBox(height: 16),
          _buildDetailedOccupancyCard(
            'Operation Theaters',
            'Active Procedure Rooms',
            Icons.medical_services_rounded,
            Colors.deepPurple,
            _stats['otOccupied'] ?? 0,
            _stats['otTotal'] ?? 1,
            null, // Don't show "Free" for OT in the same way
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedOccupancyCard(String title, String subtitle, IconData icon, Color color, int occupied, int total, int? free) {
    double percentage = total > 0 ? (occupied / total).clamp(0.0, 1.0) : 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$occupied / $total', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: color, fontSize: 16)),
                  if (free != null) Text('$free BEDS FREE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withOpacity(0.08),
              color: color,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(percentage * 100).toStringAsFixed(1)}% Usage',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}
