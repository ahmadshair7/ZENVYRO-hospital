import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_model.dart';
import '../services/storage_service.dart';
import '../models/staff_model.dart';
import '../models/ward_model.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  List<Patient> _opdPatients = [];
  List<Patient> _emergencyPatients = [];
  List<Patient> _dischargePatients = [];
  List<Map<String, dynamic>> _indoorPrescriptions = [];
  List<Map<String, dynamic>> _dispensedRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPharmacyQueue();
  }

  Future<void> _loadPharmacyQueue() async {
    setState(() => _isLoading = true);
    final opd = await StorageService.getPendingPharmacyPatients();
    final emergency = await StorageService.getPendingEmergencyPharmacyPatients();
    final discharge = await StorageService.getPendingDischargePharmacyPatients();
    final indoor = await StorageService.getPendingIndoorPharmacyPrescriptions();
    final dispensed = await StorageService.getAllDispensedPharmacyRecords();

    setState(() {
      _opdPatients = opd;
      _emergencyPatients = emergency;
      _dischargePatients = discharge;
      _indoorPrescriptions = indoor;
      _dispensedRecords = dispensed;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF00A859);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('PHARMACY CORE'),
        backgroundColor: primaryGreen,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPharmacyQueue,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildBrandedHeader(context, primaryGreen),
                _buildStaffSection(primaryGreen),
                Expanded(
                  child: DefaultTabController(
                    length: 4,
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: true,
                          labelColor: primaryGreen,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: primaryGreen,
                          indicatorWeight: 3,
                          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                          tabs: const [
                            Tab(text: 'OPD', icon: Icon(Icons.receipt_long_rounded, size: 18)),
                            Tab(text: 'EMERGENCY', icon: Icon(Icons.emergency_rounded, size: 18)),
                            Tab(text: 'INDOOR', icon: Icon(Icons.bed_rounded, size: 18)),
                            Tab(text: 'DISPENSED', icon: Icon(Icons.history_rounded, size: 18)),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildQueueList(_opdPatients, 'OPD', primaryGreen),
                              _buildQueueList([..._emergencyPatients, ..._dischargePatients], 'Emergency', const Color(0xFFE30613)),
                              _buildIndoorList(primaryGreen),
                              _buildDispensedList(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
            'Pharmacy Center',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Dispense prescriptions and manage medicine delivery',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSection(Color color) {
    return FutureBuilder<List<Staff>>(
      future: StorageService.getAllStaff(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final staff = snapshot.data!.where((s) => s.department == 'Pharmacy' && s.isOnDuty).toList();
        if (staff.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.badge_rounded, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Dispatcher on duty: ${staff.first.name}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQueueList(List<Patient> patients, String mode, Color themeColor) {
    if (patients.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: patients.length,
      itemBuilder: (context, index) {
        final p = patients[index];
        List<String> meds = [];
        String subType = mode;
        
        if (mode == 'OPD') {
          meds = p.history.firstWhere((c) => !c.isDispensed).medicines;
        } else {
          // Check if it's Emergency or Discharge
          if (p.emergencyMedicines != null && !p.isEmergencyMedicinesDispensed) {
            meds = p.emergencyMedicines!.split(',').map((e) => e.trim()).toList();
            subType = 'ER';
          } else if (p.dischargeMedicines != null && !p.isDischargeMedicinesDispensed) {
            meds = p.dischargeMedicines!.split(',').map((e) => e.trim()).toList();
            subType = 'Discharge';
          }
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: themeColor.withOpacity(0.1),
              child: Text(p.name[0], style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
            ),
            title: Text(p.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('Age: ${p.age} • $subType • ${p.categoryName}', style: const TextStyle(fontSize: 12)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('PRESCRIBED REGIMEN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.blueGrey, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    ...meds.map((m) => _buildMedRow(m, themeColor)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _dispense(p, subType),
                        style: ElevatedButton.styleFrom(backgroundColor: themeColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('MARK DISPENSED', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndoorList(Color themeColor) {
    if (_indoorPrescriptions.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _indoorPrescriptions.length,
      itemBuilder: (context, index) {
        final item = _indoorPrescriptions[index];
        final Bed bed = item['bed'];
        final meds = (item['medicines'] as String).split(',').map((e) => e.trim()).toList();

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
          child: ExpansionTile(
            leading: CircleAvatar(backgroundColor: Colors.teal.withOpacity(0.1), child: const Icon(Icons.bed_rounded, color: Colors.teal, size: 20)),
            title: Text(item['patientName'] ?? 'Unknown', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('${item['wardName']} • ${bed.id}', style: const TextStyle(fontSize: 12)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const Text('INPATIENT MEDICATIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.blueGrey, letterSpacing: 1)),
                    const SizedBox(height: 12),
                    ...meds.map((m) => _buildMedRow(m, Colors.teal)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          bed.isInpatientMedicinesDispensed = true;
                          await StorageService.saveWards(predefinedWards);
                          await StorageService.saveEmergencyUnits(emergencyUnits);
                          _loadPharmacyQueue();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('MARK DISPENSED', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDispensedList() {
    if (_dispensedRecords.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _dispensedRecords.length,
      itemBuilder: (context, index) {
        final r = _dispensedRecords[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.check_rounded, color: Colors.white, size: 16)),
            title: Text(r['patientName'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Age: ${r['patientAge']} • Source: ${r['source']}', style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 4),
                Text('Meds: ${r['medicines']}', style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w500)),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildMedRow(String m, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.medication_rounded, size: 16, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(m, style: GoogleFonts.outfit(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('No records found', style: GoogleFonts.outfit(color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  void _dispense(Patient p, String type) async {
    try {
      if (type == 'OPD') {
        final history = p.history.map((c) => !c.isDispensed ? Consultation(date: c.date, complaint: c.complaint, diagnosis: c.diagnosis, vitals: c.vitals, medicines: c.medicines, isDispensed: true) : c).toList();
        await StorageService.savePatient(p.copyWith(history: history));
      } else if (type == 'ER') {
        await StorageService.saveEmergencyPatient(p.copyWith(isEmergencyMedicinesDispensed: true));
      } else if (type == 'Discharge') {
        await StorageService.saveEmergencyPatient(p.copyWith(isDischargeMedicinesDispensed: true));
      }
      _loadPharmacyQueue();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }
}
