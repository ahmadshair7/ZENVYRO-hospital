import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ward_model.dart';
import '../models/doctor_model.dart';
import 'ward_detail_screen.dart';
import 'emergency_enrollment_screen.dart';
import '../services/storage_service.dart';
import '../models/staff_model.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<Patient> _emergencyPatients = [];

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    final patients = await StorageService.getAllEmergencyPatients();
    setState(() {
      _emergencyPatients = patients;
    });
  }

  @override
  Widget build(BuildContext context) {
    const medicalRed = Color(0xFFE30613);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('EMERGENCY DEPT'),
        backgroundColor: medicalRed,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _loadPatients(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBrandedHeader(context, medicalRed),
            _buildGPExaminationSection(medicalRed),
            _buildSectionHeader('Operational Units'),
            _buildUnitsGrid(context),
            const SizedBox(height: 40),
          ],
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
            'Critical Care Units',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Direct monitoring of ER stations and triage workflows',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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

  Widget _buildUnitsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: emergencyUnits.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _buildEnrollmentCard(context);
          final unit = emergencyUnits[index - 1];
          return _buildUnitCard(context, unit);
        },
      ),
    );
  }

  Widget _buildEnrollmentCard(BuildContext context) {
    const medicalRed = Color(0xFFE30613);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: medicalRed.withOpacity(0.2), width: 1),
      ),
      color: medicalRed.withOpacity(0.05),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmergencyEnrollmentScreen()),
          );
          _loadPatients();
        },
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: medicalRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add_rounded, size: 30, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Patient\nRegistration',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: medicalRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitCard(BuildContext context, Ward unit) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WardDetailScreen(ward: unit)),
          );
          _loadPatients();
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: unit.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(unit.icon, size: 28, color: unit.color),
              ),
              const SizedBox(height: 12),
              Text(
                unit.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bed_rounded, size: 12, color: unit.color),
                  const SizedBox(width: 4),
                  Text(
                    '${unit.occupiedBedsCount} Occupied',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: unit.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGPExaminationSection(Color color) {
    final awaitingTriage = _emergencyPatients.where((p) => p.status == 'Awaiting Triage').toList();
    if (awaitingTriage.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_edu_rounded, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GP Examination',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '${awaitingTriage.length} Patients in Queue',
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: awaitingTriage.length,
              itemBuilder: (context, index) {
                final patient = awaitingTriage[index];
                return Container(
                  width: 260,
                  margin: const EdgeInsets.only(right: 16),
                  child: Card(
                    elevation: 0,
                    color: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'E-${patient.tokenNumber}',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.orange),
                              ),
                              Text(patient.registrationTime!, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            patient.name,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showAssignUnitDialog(patient),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 0),
                                minimumSize: const Size(double.infinity, 32),
                              ),
                              child: const Text('TRIAGE EXAM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignUnitDialog(Patient patient) {
    String? selectedPriority;
    final medicinesController = TextEditingController();
    final priorities = [
      {'label': 'RED (Immediate)', 'color': const Color(0xFFE30613), 'id': 'Red'},
      {'label': 'ORANGE (Urgent)', 'color': Colors.orange, 'id': 'Orange'},
      {'label': 'YELLOW (Standard)', 'color': Colors.yellow.shade800, 'id': 'Yellow'},
      {'label': 'GREEN (Low Risk)', 'color': Colors.green, 'id': 'Green'},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Triage Selection: ${patient.name}',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernField(
                  controller: medicinesController,
                  label: 'Initial Medications',
                  icon: Icons.medication_rounded,
                ),
                const SizedBox(height: 24),
                const Text('PRIORITY LEVEL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: Colors.blueGrey)),
                const SizedBox(height: 12),
                ...priorities.map((p) => _buildPriorityOption(p, selectedPriority, (val) => setDialogState(() => selectedPriority = val))),
                const SizedBox(height: 24),
                const Text('ASSIGN TO UNIT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1, color: Colors.blueGrey)),
                const SizedBox(height: 12),
                ...emergencyUnits.map((unit) => _buildUnitSelectionTile(unit, selectedPriority, medicinesController, patient)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernField({required TextEditingController controller, required String label, required IconData icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        isDense: true,
      ),
      maxLines: 2,
    );
  }

  Widget _buildPriorityOption(Map<String, dynamic> p, String? groupValue, Function(String?) onChanged) {
    bool isSelected = groupValue == p['id'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(p['id']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? (p['color'] as Color).withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? p['color'] : Colors.grey.shade200, width: 2),
          ),
          child: Row(
            children: [
              Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, size: 20, color: p['color']),
              const SizedBox(width: 12),
              Text(p['label'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: p['color'])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitSelectionTile(Ward unit, String? priority, TextEditingController meds, Patient patient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: priority == null ? null : () => _assignPatient(unit, priority, meds.text, patient),
        tileColor: Colors.grey.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(unit.icon, color: unit.color),
        title: Text(unit.name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right_rounded, size: 16),
        enabled: priority != null,
      ),
    );
  }

  void _assignPatient(Ward unit, String priority, String medicines, Patient patient) async {
    final availableBed = unit.beds.firstWhere((b) => !b.isOccupied, orElse: () => unit.beds.first);
    if (unit.availableBedsCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No free stations in this unit.')));
      return;
    }

    final now = DateTime.now();
    final medicinesStr = medicines.isNotEmpty ? medicines : "None administered yet";
    
    availableBed.isOccupied = true;
    availableBed.patientId = patient.id;
    availableBed.patientName = patient.name;
    availableBed.patientAge = patient.age;
    availableBed.patientSex = patient.sex;
    availableBed.registrationDate = patient.registrationDate;
    availableBed.registrationTime = patient.registrationTime;
    availableBed.triagePriority = priority;
    availableBed.administeredMedicines = medicinesStr;
    availableBed.admissionDate = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
    availableBed.admissionTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final updatedPatient = patient.copyWith(
      status: 'Admitted',
      emergencyCategory: unit.name,
      triagePriority: priority,
      emergencyMedicines: medicinesStr,
    );

    try {
      await StorageService.saveEmergencyPatient(updatedPatient);
      await StorageService.saveEmergencyUnits(emergencyUnits);
      if (!mounted) return;
      Navigator.pop(context);
      _loadPatients();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${patient.name} admitted to ${unit.name}'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assignment failed: $e'), backgroundColor: Colors.red));
    }
  }
}
