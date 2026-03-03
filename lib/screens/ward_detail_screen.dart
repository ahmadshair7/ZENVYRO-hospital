import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ward_model.dart';
import '../services/storage_service.dart';
import '../models/doctor_model.dart';
import '../models/staff_model.dart';

class WardDetailScreen extends StatefulWidget {
  final Ward ward;

  const WardDetailScreen({super.key, required this.ward});

  @override
  State<WardDetailScreen> createState() => _WardDetailScreenState();
}

class _WardDetailScreenState extends State<WardDetailScreen> {
  List<Patient> _waitingPatients = [];

  @override
  void initState() {
    super.initState();
    _loadWaitingPatients();
  }

  Future<void> _loadWaitingPatients() async {
    final patients = await StorageService.getAllEmergencyPatients();
    setState(() {
      _waitingPatients = patients.where((p) => p.emergencyCategory == widget.ward.name && p.status == 'Assigned').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.ward.name.toUpperCase()),
        backgroundColor: widget.ward.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showWardInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBrandedHeader(),
          _buildStaffSection(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: widget.ward.beds.length,
              itemBuilder: (context, index) {
                final bed = widget.ward.beds[index];
                return _buildBedCard(bed);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandedHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: widget.ward.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bed Monitoring',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Occupancy: ${widget.ward.occupiedBedsCount} / ${widget.ward.beds.length}',
                style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: Icon(widget.ward.icon, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffSection() {
    return FutureBuilder<List<Staff>>(
      future: StorageService.getAllStaff(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final wardStaff = snapshot.data!.where((s) => 
          (s.department == 'Indoor' || s.department == 'Emergency') && 
          s.assignment == widget.ward.name && 
          s.isOnDuty
        ).toList();

        if (wardStaff.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_alt_rounded, size: 18, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    'ON-DUTY STAFF',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: wardStaff.length,
                  itemBuilder: (context, index) {
                    final s = wardStaff[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: widget.ward.color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${s.role}: ${s.name}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: widget.ward.color),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBedCard(Bed bed) {
    final isOccupied = bed.isOccupied;
    const accentRed = Color(0xFFE30613);
    const accentGreen = Color(0xFF00A859);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: isOccupied ? accentRed.withOpacity(0.1) : Colors.grey.shade200, width: 1.5),
      ),
      color: isOccupied ? accentRed.withOpacity(0.02) : Colors.white,
      child: InkWell(
        onTap: () => isOccupied ? _showPatientDetailsDialog(bed) : _showAdmissionDialog(bed),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOccupied ? Icons.bed_rounded : Icons.bed_outlined,
                color: isOccupied ? accentRed : accentGreen,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                'STATION ${bed.id}',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.blueGrey),
              ),
              if (isOccupied) ...[
                const SizedBox(height: 8),
                Text(
                  bed.patientName ?? 'Unknown',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${bed.patientAge}y | ${bed.patientSex}',
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'AVAILABLE',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, color: accentGreen),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showWardInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.ward.name} Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Total Beds', '${widget.ward.beds.length}'),
            _buildInfoRow('Occupied', '${widget.ward.occupiedBedsCount}'),
            _buildInfoRow('Available', '${widget.ward.availableBedsCount}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))],
      ),
    );
  }

  void _showPatientDetailsDialog(Bed bed) {
    final inpatientController = TextEditingController(text: bed.inpatientMedicines);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Case File: ${bed.patientName}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernDetailRow('Triage Level', bed.triagePriority ?? 'Standard', _getPriorityColor(bed.triagePriority ?? 'Green')),
              _buildModernDetailRow('Admission', '${bed.admissionDate} ${bed.admissionTime}', Colors.blueGrey),
              const Divider(height: 32),
              const Text('INPATIENT MEDICATION CHART', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.teal, letterSpacing: 1)),
              const SizedBox(height: 12),
              TextField(
                controller: inpatientController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Record medicines and dosages...',
                  fillColor: Colors.teal.withOpacity(0.05),
                  filled: true,
                ),
                onChanged: (v) {
                  bed.inpatientMedicines = v;
                  StorageService.saveWards(predefinedWards);
                  StorageService.saveEmergencyUnits(emergencyUnits);
                },
              ),
              const SizedBox(height: 24),
              const Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.blueGrey, letterSpacing: 1)),
              const SizedBox(height: 12),
              _buildActionTile(Icons.sync_alt_rounded, 'Transfer Bed', Colors.blue, () {
                Navigator.pop(context);
                _showTransferDialog(bed);
              }),
              const SizedBox(height: 8),
              _buildActionTile(Icons.logout_rounded, 'Discharge Patient', Colors.red, () {
                Navigator.pop(context);
                _showDischargeDialog(bed);
              }),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE'))],
      ),
    );
  }

  Widget _buildModernDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      dense: true,
      tileColor: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: color, size: 20),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 16),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Red': return Colors.red;
      case 'Orange': return Colors.orange;
      case 'Yellow': return Colors.yellow.shade800;
      case 'Green': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _showTransferDialog(Bed sourceBed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transfer Patient'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select a destination station:'),
              const SizedBox(height: 16),
              ...emergencyUnits.where((u) => u.availableBedsCount > 0).map((u) => ListTile(
                leading: Icon(u.icon, color: u.color),
                title: Text(u.name),
                subtitle: Text('${u.availableBedsCount} Beds Free'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final targetBed = u.beds.firstWhere((b) => !b.isOccupied);
                  _transferLogic(sourceBed, targetBed, u.name);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _transferLogic(Bed src, Bed dst, String newCat) async {
    setState(() {
      dst.isOccupied = true;
      dst.patientId = src.patientId;
      dst.patientName = src.patientName;
      dst.patientAge = src.patientAge;
      dst.patientSex = src.patientSex;
      dst.registrationDate = src.registrationDate;
      dst.registrationTime = src.registrationTime;
      dst.triagePriority = src.triagePriority;
      dst.administeredMedicines = src.administeredMedicines;
      dst.medicalHistory = src.medicalHistory;
      dst.admissionDate = src.admissionDate;
      dst.admissionTime = src.admissionTime;
      dst.otDate = src.otDate;
      dst.otTime = src.otTime;
      dst.inpatientMedicines = src.inpatientMedicines;

      src.isOccupied = false;
      src.patientId = src.patientName = src.patientAge = src.patientSex = null;
      src.inpatientMedicines = null;
    });

    final patients = await StorageService.getAllEmergencyPatients();
    final pIndex = patients.indexWhere((p) => p.name == dst.patientName && p.age == dst.patientAge);
    if (pIndex != -1) {
      final updatedPatient = patients[pIndex].copyWith(emergencyCategory: newCat);
      await StorageService.saveEmergencyPatient(updatedPatient);
    }
    await StorageService.saveEmergencyUnits(emergencyUnits);
  }

  void _showAdmissionDialog(Bed bed) {
    if (_waitingPatients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No patients waiting for this ward.')));
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admit Patient'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _waitingPatients.length,
            itemBuilder: (context, index) {
              final p = _waitingPatients[index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: _getPriorityColor(p.triagePriority ?? 'Green'), radius: 12),
                title: Text(p.name),
                subtitle: Text('${p.age}y | ${p.sex}'),
                onTap: () async {
                  final now = DateTime.now();
                  setState(() {
                    bed.isOccupied = true;
                    bed.patientId = p.id;
                    bed.patientName = p.name;
                    bed.patientAge = p.age;
                    bed.patientSex = p.sex;
                    bed.triagePriority = p.triagePriority;
                    bed.administeredMedicines = p.emergencyMedicines;
                    bed.medicalHistory = p.initialComplaint;
                    bed.admissionDate = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
                    bed.admissionTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
                  });
                  await StorageService.saveEmergencyPatient(p.copyWith(status: 'Admitted'));
                  await StorageService.saveEmergencyUnits(emergencyUnits);
                  if (mounted) Navigator.pop(context);
                  _loadWaitingPatients();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDischargeDialog(Bed bed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Discharge'),
        content: Text('Discharge ${bed.patientName} from the ward? Medication chart will be forwarded to Pharmacy.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              final meds = bed.inpatientMedicines;
              final pName = bed.patientName;
              final pAge = bed.patientAge;
              setState(() { bed.isOccupied = false; bed.patientName = null; bed.inpatientMedicines = null; });
              if (meds != null && meds.trim().isNotEmpty && pName != null) {
                final patients = await StorageService.getAllEmergencyPatients();
                final pIndex = patients.indexWhere((p) => p.name == pName && p.age == pAge);
                if (pIndex != -1) {
                  await StorageService.saveEmergencyPatient(patients[pIndex].copyWith(dischargeMedicines: meds, isDischargeMedicinesDispensed: false));
                }
              }
              await StorageService.saveEmergencyUnits(emergencyUnits);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('DISCHARGE'),
          ),
        ],
      ),
    );
  }
}
