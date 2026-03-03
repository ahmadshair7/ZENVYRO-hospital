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
    setState(() => _isLoading = true);
    final stats = await StorageService.getHospitalOccupancyStats();
    final today = await StorageService.getTodayTotalPatients();
    setState(() {
      _stats = stats;
      _todayPatients = today;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBrandedHeader(context, primaryBlue),
                    _buildTodayOverview(primaryBlue),
                    _buildSectionHeader('Departmental Occupancy'),
                    _buildOccupancyGrid(),
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
          Text(
            'Hospital Insights',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time metrics and departmental performance',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
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
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildTodayOverview(Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.analytics_rounded, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Patient Flow', style: TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                Text(
                  '$_todayPatients',
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: color),
                ),
                const Text('Total interactions in last 24h', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildOccupancyCard(
            'Indoor Units',
            'Ward Bed Management',
            Icons.bed_rounded,
            const Color(0xFF00A859),
            _stats['indoorOccupied'] ?? 0,
            _stats['indoorTotal'] ?? 100,
          ),
          const SizedBox(height: 16),
          _buildOccupancyCard(
            'Emergency Dept',
            'Critical Care Stations',
            Icons.emergency_rounded,
            const Color(0xFFE30613),
            _stats['emergencyOccupied'] ?? 0,
            _stats['emergencyTotal'] ?? 100,
          ),
          const SizedBox(height: 16),
          _buildOccupancyCard(
            'Surgical Units',
            'Operation Theaters',
            Icons.medical_services_rounded,
            const Color(0xFF673AB7),
            _stats['otOccupied'] ?? 0,
            _stats['otTotal'] ?? 100,
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyCard(String title, String subtitle, IconData icon, Color color, int occupied, int total) {
    double percentage = total > 0 ? (occupied / total) : 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              Text('$occupied / $total', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: color)),
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
