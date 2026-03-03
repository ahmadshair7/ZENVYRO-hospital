import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/doctor_model.dart';
import 'doctor_checkup_screen.dart';

class TokenScreen extends StatelessWidget {
  final DoctorCategory category;
  final Patient? patient;
  final int? tokenOverride;

  const TokenScreen({
    super.key,
    required this.category,
    this.patient,
    this.tokenOverride,
  });

  @override
  Widget build(BuildContext context) {
    final int tokenNumber = tokenOverride ?? TokenManager.getNextToken();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('ENROLLMENT TICKET'),
        backgroundColor: category.color,
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildBrandedHeader(),
              const SizedBox(height: 40),
              _buildTicketContainer(context, tokenNumber),
              const SizedBox(height: 60),
              _buildInstructions(),
              const SizedBox(height: 40),
              _buildProceedButton(context, tokenNumber),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandedHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            category.name.toUpperCase(),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Text(
            'Clinical Consultation Unit',
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketContainer(BuildContext context, int tokenNumber) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                if (patient != null) ...[
                  Text(
                    'PATIENT IDENTITY',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.blueGrey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    patient!.name,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${patient!.age}Y • ${patient!.mobile}',
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                  const Divider(height: 40),
                ],
                Text(
                  'QUEUE POSITION',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: category.color,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '#$tokenNumber',
                  style: GoogleFonts.outfit(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: category.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Valid for today only',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          _buildDashedDivider(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_2_rounded, size: 24, color: Colors.blueGrey),
                const SizedBox(width: 12),
                Text(
                  'ZENVYRO E-TOKEN',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade200,
            height: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.blueGrey, size: 20),
          const SizedBox(height: 12),
          Text(
            'Please proceed to the waiting lounge. Our staff will coordinate your entry based on the sequence above.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.blueGrey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context, int tokenNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorCheckupScreen(
                  category: category,
                  token: tokenNumber,
                  patient: patient,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: category.color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: category.color.withOpacity(0.4),
          ),
          child: Text(
            'ENTER CLINIC',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
