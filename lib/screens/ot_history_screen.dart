import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ot_schedule_model.dart';
import '../services/storage_service.dart';
import '../models/staff_model.dart';

class OtHistoryScreen extends StatefulWidget {
  const OtHistoryScreen({super.key});

  @override
  State<OtHistoryScreen> createState() => _OtHistoryScreenState();
}

class _StaffSection extends StatelessWidget {
  final List<String> staffIds;
  const _StaffSection({required this.staffIds});

  @override
  Widget build(BuildContext context) {
    if (staffIds.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<List<Staff>>(
      future: StorageService.getAllStaff(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final names = snapshot.data!
            .where((s) => staffIds.contains(s.id))
            .map((s) => s.name)
            .join(", ");
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              const Icon(Icons.people_outline_rounded, size: 14, color: Colors.blueGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Team: $names', style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OtHistoryScreenState extends State<OtHistoryScreen> {
  List<OTSchedule> _history = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final all = await StorageService.getAllOTSchedules();
    setState(() {
      _history = all.where((s) => s.status == 'Completed').toList();
      _history.sort((a, b) {
        // Sort by completion date/time desc (placeholder sort)
        return b.id.compareTo(a.id);
      });
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _history.where((s) => 
      s.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      s.otRoom.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('SURGICAL HISTORY'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          _buildBrandedHeader(),
          _buildSearchBar(),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty 
                ? _buildEmptyState()
                : _buildHistoryList(filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandedHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Archives', style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Comprehensive record of all completed surgeries', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search patient or OT room...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.history_rounded, size: 80, color: Colors.grey.shade200),
      const SizedBox(height: 16),
      Text('No completed cases found', style: GoogleFonts.outfit(color: Colors.grey.shade400)),
    ]));
  }

  Widget _buildHistoryList(List<OTSchedule> cases) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: cases.length,
      itemBuilder: (context, index) {
        final s = cases[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey.shade200)),
          child: ExpansionTile(
            title: Text(s.patientName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('${s.otRoom} • ${s.completionDate ?? s.date}', style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.verified_rounded, color: Colors.green, size: 20),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    _buildInfoRow('Surgeon', s.scheduledBy),
                    _buildInfoRow('Duration', s.estimatedDuration),
                    _StaffSection(staffIds: s.assignedStaffIds),
                    const SizedBox(height: 16),
                    _buildNoteBlock('PRE-OP', s.preOpNotes),
                    _buildNoteBlock('INTRA-OP', s.intraOpNotes),
                    _buildNoteBlock('POST-OP', s.postOpNotes),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNoteBlock(String label, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.deepPurple, letterSpacing: 1)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
            child: Text(content, style: const TextStyle(fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
