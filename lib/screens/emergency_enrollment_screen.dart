import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_model.dart';
import '../services/storage_service.dart';

class EmergencyEnrollmentScreen extends StatefulWidget {
  const EmergencyEnrollmentScreen({super.key});

  @override
  State<EmergencyEnrollmentScreen> createState() => _EmergencyEnrollmentScreenState();
}

class _EmergencyEnrollmentScreenState extends State<EmergencyEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _complaintController = TextEditingController();
  String _selectedSex = 'Male';

  @override
  Widget build(BuildContext context) {
    const medicalRed = Color(0xFFE30613);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('EMERGENCY ENROLLMENT'),
        backgroundColor: medicalRed,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, medicalRed),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Critical Details'),
                    const SizedBox(height: 16),
                    _buildModernField(
                      controller: _nameController,
                      label: 'Patient Full Name',
                      icon: Icons.person_rounded,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter name' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernField(
                            controller: _ageController,
                            label: 'Age',
                            icon: Icons.calendar_today_rounded,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            validator: (value) => value == null || value.isEmpty ? 'Enter age' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: _buildSexSelector()),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Primary Complaint'),
                    const SizedBox(height: 16),
                    _buildModernField(
                      controller: _complaintController,
                      label: 'Initial Complaint & History',
                      icon: Icons.history_edu_rounded,
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty ? 'Please enter details' : null,
                    ),
                    const SizedBox(height: 48),
                    _buildSubmitButton(medicalRed),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
            'Emergency Registration',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Immediate enrollment for rapid clinical triage',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
    );
  }

  Widget _buildSexSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedSex,
          hint: Text('Sex', style: GoogleFonts.outfit(fontSize: 14)),
          items: ['Male', 'Female', 'Other'].map((sex) {
            return DropdownMenuItem(
              value: sex,
              child: Text(sex, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedSex = value!),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color color) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _enrollPatient,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          'ENROLL & GENERATE TOKEN',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  void _enrollPatient() async {
    if (_formKey.currentState!.validate()) {
      final token = EmergencyTokenManager.getNextToken();
      final now = DateTime.now();
      final registrationDateStr = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";
      final registrationTimeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final patient = Patient(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        age: _ageController.text,
        mobile: 'N/A',
        categoryName: 'Emergency',
        tokenNumber: token,
        status: 'Awaiting Triage',
        sex: _selectedSex,
        registrationDate: registrationDateStr,
        registrationTime: registrationTimeStr,
        initialComplaint: _complaintController.text,
      );

      try {
        await StorageService.saveEmergencyPatient(patient);
        await StorageService.saveEmergencyTokens(EmergencyTokenManager.getTokens());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient enrolled with Token: E-$token'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to enroll patient: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
