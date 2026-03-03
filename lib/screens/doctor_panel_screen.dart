import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_model.dart';
import '../services/storage_service.dart';
import 'doctor_checkup_screen.dart';

class DoctorPanelScreen extends StatefulWidget {
  final DoctorCategory category;

  const DoctorPanelScreen({super.key, required this.category});

  @override
  State<DoctorPanelScreen> createState() => _DoctorPanelScreenState();
}

class _DoctorPanelScreenState extends State<DoctorPanelScreen> {
  List<Patient> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    final patients = await StorageService.getPatientsForCategory(widget.category.name);
    setState(() {
      _patients = patients;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('${widget.category.name.toUpperCase()} CLINIC'),
        backgroundColor: widget.category.color,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildBrandedHeader(),
                Expanded(
                  child: _patients.isEmpty
                      ? _buildEmptyState()
                      : _buildPatientList(),
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
        color: widget.category.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consultation Queue',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Managing clinical appointments and patient care',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'No patients in queue',
            style: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _patients.length,
      itemBuilder: (context, index) {
        final p = _patients[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorCheckupScreen(
                    category: widget.category,
                    token: p.tokenNumber,
                    patient: p,
                  ),
                ),
              );
              _loadPatients();
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: widget.category.color.withOpacity(0.1),
                    child: Text(
                      '#${p.tokenNumber}',
                      style: GoogleFonts.outfit(color: widget.category.color, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(p.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            _buildStatusBadge(p.status),
                          ],
                        ),
                        Text(
                          'Age: ${p.age} • ${p.mobile}',
                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isChecked = status == 'Checked';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isChecked ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: isChecked ? Colors.green : Colors.orange,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
