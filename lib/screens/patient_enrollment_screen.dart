import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_model.dart';
import '../services/storage_service.dart';
import 'token_screen.dart';

class PatientEnrollmentScreen extends StatefulWidget {
  final DoctorCategory? initialCategory;

  const PatientEnrollmentScreen({super.key, this.initialCategory});

  @override
  State<PatientEnrollmentScreen> createState() => _PatientEnrollmentScreenState();
}

class _PatientEnrollmentScreenState extends State<PatientEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  DoctorCategory? _selectedCategory;
  String? _selectedSex;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      final token = TokenManager.getNextToken();
      final patient = Patient(
        id: id,
        name: _nameController.text,
        age: _ageController.text,
        mobile: _mobileController.text,
        categoryName: _selectedCategory!.name,
        tokenNumber: token,
        sex: _selectedSex,
      );

      try {
        await StorageService.savePatient(patient);
        await StorageService.saveTokens();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TokenScreen(
              category: _selectedCategory!,
              patient: patient,
              tokenOverride: token,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to enroll patient: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a doctor category'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('PATIENT ENROLLMENT'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Personal Information'),
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
                    const SizedBox(height: 16),
                    _buildModernField(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(20),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter mobile';
                        if (value.length < 10) return 'Include country code (min 10 digits)';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Medical Assignment'),
                    const SizedBox(height: 16),
                    _buildCategorySelector(),
                    const SizedBox(height: 48),
                    _buildSubmitButton(primaryBlue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Registration',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enroll a patient and generate a medical token',
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
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
          hint: Text('Select Sex', style: GoogleFonts.outfit(fontSize: 14)),
          items: ['Male', 'Female', 'Other'].map((sex) {
            return DropdownMenuItem(
              value: sex,
              child: Text(sex, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedSex = value),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DoctorCategory>(
          isExpanded: true,
          value: _selectedCategory,
          hint: Text('Assign to Doctor Category', style: GoogleFonts.outfit(fontSize: 14)),
          items: opdCategories.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Row(
                children: [
                  Icon(cat.icon, color: cat.color, size: 20),
                  const SizedBox(width: 12),
                  Text(cat.name, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value),
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
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          'GENERATE TOKEN',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
