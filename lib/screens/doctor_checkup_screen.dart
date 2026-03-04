import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_model.dart';
import '../models/ward_model.dart';
import '../models/ot_schedule_model.dart';
import '../services/storage_service.dart';

class DoctorCheckupScreen extends StatefulWidget {
  final DoctorCategory category;
  final int token;
  final Patient? patient;

  const DoctorCheckupScreen({
    super.key,
    required this.category,
    required this.token,
    this.patient,
  });

  @override
  State<DoctorCheckupScreen> createState() => _DoctorCheckupScreenState();
}

class _DoctorCheckupScreenState extends State<DoctorCheckupScreen> {
  final List<String> _prescriptions = [];
  final _medicineController = TextEditingController();
  final _complaintController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _vitalsController = TextEditingController();
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    if (widget.patient != null && widget.patient!.history.isNotEmpty) {
      final latest = widget.patient!.history.first;
      _complaintController.text = latest.complaint;
      _diagnosisController.text = latest.diagnosis;
      _vitalsController.text = latest.vitals;
      _prescriptions.addAll(latest.medicines);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('${widget.category.name.toUpperCase()} EXAMINATION'),
        backgroundColor: widget.category.color,
        actions: [
          if (widget.patient != null)
            IconButton(icon: const Icon(Icons.history_rounded), onPressed: () => setState(() => _showHistory = !_showHistory)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBrandedHeader(),
            _showHistory ? _buildHistoryView() : _buildExaminationForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandedHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: widget.category.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: Icon(widget.category.icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patient?.name ?? 'Case Early Entry',
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Token #${widget.token} • ${widget.patient?.age ?? "N/A"} • ${widget.patient?.mobile ?? "N/A"}',
                  style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExaminationForm() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Clinical Findings'),
          const SizedBox(height: 16),
          _buildModernField('Presenting Complaint', _complaintController, Icons.subject_rounded),
          const SizedBox(height: 16),
          _buildModernField('Provisional Diagnosis', _diagnosisController, Icons.assignment_rounded),
          const SizedBox(height: 16),
          _buildModernField('Clinical Vitals (BP, HR, SpO2)', _vitalsController, Icons.monitor_heart_rounded),
          const SizedBox(height: 32),
          _buildSectionTitle('Prescription Chart'),
          const SizedBox(height: 16),
          _buildMedicineInput(),
          const SizedBox(height: 12),
          _buildMedicineList(),
          const SizedBox(height: 32),
          _buildSectionTitle('Clinical Pathways'),
          const SizedBox(height: 16),
          _buildReferralSection(),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _saveConsultation,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text('FINALIZE CONSULTATION', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1),
    );
  }

  Widget _buildModernField(String label, TextEditingController c, IconData icon) {
    return TextField(
      controller: c,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildMedicineInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _medicineController,
            decoration: const InputDecoration(hintText: 'Add medication regimen...', filled: true, fillColor: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filled(
          onPressed: () {
            if (_medicineController.text.isNotEmpty) {
              setState(() => _prescriptions.add(_medicineController.text.trim()));
              _medicineController.clear();
            }
          },
          icon: const Icon(Icons.add_rounded),
          style: IconButton.styleFrom(backgroundColor: widget.category.color, padding: const EdgeInsets.all(12)),
        ),
      ],
    );
  }

  Widget _buildMedicineList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _prescriptions.map((m) => Chip(
        label: Text(m, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        onDeleted: () => setState(() => _prescriptions.remove(m)),
        backgroundColor: Colors.white,
        side: BorderSide(color: widget.category.color.withOpacity(0.3)),
      )).toList(),
    );
  }

  Widget _buildReferralSection() {
    return Row(
      children: [
        Expanded(child: _buildActionTile('ER', Icons.emergency_rounded, Colors.red, _referToEmergency)),
        const SizedBox(width: 8),
        Expanded(child: _buildActionTile('WARD', Icons.bed_rounded, Colors.teal, _showIndoorReferralDialog)),
        const SizedBox(width: 8),
        Expanded(child: _buildActionTile('OT', Icons.medical_services_rounded, Colors.deepPurple, _showOTScheduleDialog)),
      ],
    );
  }

  Widget _buildActionTile(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryView() {
    if (widget.patient == null || widget.patient!.history.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: widget.patient!.history.map((c) => Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
          child: ExpansionTile(
            title: Text('${c.date.day}/${c.date.month}/${c.date.year}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text(c.diagnosis, style: const TextStyle(fontSize: 12)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHistoryItem('Vitals', c.vitals),
                    _buildHistoryItem('Meds', c.medicines.join(", ")),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildHistoryItem(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
      Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
    ]));
  }

  // Logic remains the same as per user instruction
  Future<void> _saveConsultation() async {
    if (widget.patient == null) return;
    if (_medicineController.text.isNotEmpty) { _prescriptions.add(_medicineController.text.trim()); _medicineController.clear(); }
    final c = Consultation(date: DateTime.now(), complaint: _complaintController.text, diagnosis: _diagnosisController.text, vitals: _vitalsController.text, medicines: List.from(_prescriptions));
    final now = DateTime.now();
    final updated = widget.patient!.copyWith(status: 'Checked', history: [c, ...widget.patient!.history.skip((widget.patient!.history.isNotEmpty && widget.patient!.history.first.date.day == now.day) ? 1 : 0)]);
    await StorageService.savePatient(updated);
    if (mounted) Navigator.pop(context);
  }

  void _referToEmergency() async {
    if (widget.patient == null) return;
    
    final findings = "Complaint: ${_complaintController.text}\nDiagnosis: ${_diagnosisController.text}\nVitals: ${_vitalsController.text}";
    final updated = widget.patient!.copyWith(
      status: 'Awaiting Triage',
      isReferredToEmergency: true,
      registrationDate: "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}",
      registrationTime: "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      initialComplaint: findings,
    );

    await StorageService.saveEmergencyPatient(updated);
    // Also update OPD status
    await StorageService.savePatient(widget.patient!.copyWith(status: 'Referred to ER'));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient referred to Emergency'), backgroundColor: Colors.red),
      );
      Navigator.pop(context);
    }
  }

  void _showIndoorReferralDialog() {
    if (widget.patient == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Ward for ${widget.patient!.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: predefinedWards.length,
            itemBuilder: (context, index) {
              final ward = predefinedWards[index];
              return ListTile(
                leading: Icon(ward.icon, color: ward.color),
                title: Text(ward.name),
                subtitle: Text('Free Beds: ${ward.availableBedsCount}'),
                onTap: () async {
                  final findings = "Complaint: ${_complaintController.text}\nDiagnosis: ${_diagnosisController.text}\nVitals: ${_vitalsController.text}";
                  final updated = widget.patient!.copyWith(
                    status: 'Assigned',
                    emergencyCategory: ward.name,
                    isReferredToIndoor: true,
                    initialComplaint: findings,
                  );
                  await StorageService.saveEmergencyPatient(updated);
                  // Also update OPD status
                  await StorageService.savePatient(widget.patient!.copyWith(status: 'Referred to Ward'));

                  if (mounted) {
                    Navigator.pop(context); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Referred to ${ward.name}'), backgroundColor: Colors.teal),
                    );
                    Navigator.pop(context); // Exit checkup screen
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
  void _showOTScheduleDialog() {
    if (widget.patient == null) return;

    String? selectedOT;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    final durationController = TextEditingController();
    final indicationsController = TextEditingController(text: _diagnosisController.text);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Schedule Surgery', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select OT Room'),
                  items: operationTheaters.map((ot) => DropdownMenuItem(value: ot.name, child: Text(ot.name))).toList(),
                  onChanged: (v) => setDialogState(() => selectedOT = v),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today_rounded),
                  title: Text(selectedDate == null ? 'Select Date' : '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
                    if (d != null) setDialogState(() => selectedDate = d);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time_rounded),
                  title: Text(selectedTime == null ? 'Select Time' : selectedTime!.format(context)),
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (t != null) setDialogState(() => selectedTime = t);
                  },
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Estimated Duration', hintText: 'e.g., 2 hours'),
                ),
                TextField(
                  controller: indicationsController,
                  decoration: const InputDecoration(labelText: 'Surgical Indications'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                if (selectedOT == null || selectedDate == null || selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                  return;
                }

                final dateStr = "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}";
                final timeStr = "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

                final schedule = OTSchedule(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  patientId: widget.patient!.id,
                  patientName: widget.patient!.name,
                  patientAge: widget.patient!.age,
                  patientSex: widget.patient!.sex,
                  otRoom: selectedOT!,
                  date: dateStr,
                  time: timeStr,
                  medicalHistory: indicationsController.text,
                  estimatedDuration: durationController.text,
                  scheduledBy: widget.category.name,
                );

                await StorageService.saveOTSchedule(schedule);
                
                final updatedPatient = widget.patient!.copyWith(
                  otDate: dateStr,
                  otTime: timeStr,
                  otName: selectedOT,
                  status: 'Scheduled for OT',
                );
                await StorageService.savePatient(updatedPatient);

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Surgery Scheduled Successfully'), backgroundColor: Colors.deepPurple),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
              child: const Text('SCHEDULE'),
            ),
          ],
        ),
      ),
    );
  }
}
