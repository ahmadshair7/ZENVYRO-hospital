import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ot_schedule_model.dart';
import '../models/ward_model.dart';
import '../services/storage_service.dart';
import '../models/staff_model.dart';

class OtScheduleScreen extends StatefulWidget {
  final Ward ot;

  const OtScheduleScreen({super.key, required this.ot});

  @override
  State<OtScheduleScreen> createState() => _OtScheduleScreenState();
}

class _OtScheduleScreenState extends State<OtScheduleScreen> {
  List<OTSchedule> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);
    final all = await StorageService.getAllOTSchedules();
    setState(() {
      _schedules = all.where((s) => s.otRoom.trim().toLowerCase() == widget.ot.name.trim().toLowerCase()).toList();
      _schedules.sort((a, b) {
        try {
          final aDate = a.date.split('-');
          final bDate = b.date.split('-');
          final aDt = DateTime(int.parse(aDate[2]), int.parse(aDate[1]), int.parse(aDate[0]));
          final bDt = DateTime(int.parse(bDate[2]), int.parse(bDate[1]), int.parse(bDate[0]));
          int comp = aDt.compareTo(bDt);
          return comp != 0 ? comp : a.time.compareTo(b.time);
        } catch (_) { return 0; }
      });
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('${widget.ot.name.toUpperCase()} SCHEDULE'),
        backgroundColor: widget.ot.color,
        actions: [IconButton(icon: const Icon(Icons.sync_rounded), onPressed: _loadSchedules)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildBrandedHeader(),
                _buildStaffSection(),
                Expanded(
                  child: _schedules.isEmpty
                      ? _buildEmptyState()
                      : _buildScheduleList(),
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
        color: widget.ot.color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational Plan',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Managing surgical queues and procedural status',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 14),
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
        final staff = snapshot.data!.where((s) => s.department == 'OT' && s.assignment == widget.ot.name && s.isOnDuty).toList();
        if (staff.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.ot.color.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.medical_information_rounded, color: widget.ot.color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'On-duty Personnel: ${staff.map((s) => s.name).join(", ")}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: widget.ot.color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note_rounded, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text('No operations scheduled', style: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final s = _schedules[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: widget.ot.color.withOpacity(0.1),
              child: Text('${index + 1}', style: TextStyle(color: widget.ot.color, fontWeight: FontWeight.bold)),
            ),
            title: Text(s.patientName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text('${s.date} • ${s.time}', style: const TextStyle(fontSize: 12)),
            trailing: _buildStatusChip(s.status),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildDetailRow('Age/Sex', '${s.patientAge} | ${s.patientSex ?? "N/A"}'),
                    _buildDetailRow('Duration', s.estimatedDuration),
                    _buildDetailRow('Surgeon', s.scheduledBy),
                    const SizedBox(height: 12),
                    const Text('SURGICAL INDICATIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.blueGrey, letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Text(s.medicalHistory.isEmpty ? 'N/A' : s.medicalHistory, style: const TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (s.status == 'Pending')
                          _buildActionButton('START PROCEDURE', Colors.blue, () => _updateStatus(s, 'Active')),
                        if (s.status == 'Active')
                          _buildActionButton('MARK RECOVERY', Colors.green, () => _updateStatus(s, 'Completed')),
                        if (s.status != 'Completed') ...[
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (v) => _updateStatus(s, v),
                            itemBuilder: (c) => [
                              const PopupMenuItem(value: 'Pending', child: Text('Reset to Pending')),
                              const PopupMenuItem(value: 'Completed', child: Text('Complete Manually')),
                            ],
                            child: const Icon(Icons.more_vert_rounded, color: Colors.blueGrey),
                          ),
                        ],
                      ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'Active' ? Colors.blue : (status == 'Completed' ? Colors.green : Colors.orange);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
    );
  }

  void _updateStatus(OTSchedule s, String status) async {
    final updated = OTSchedule(id: s.id, patientId: s.patientId, patientName: s.patientName, patientAge: s.patientAge, patientSex: s.patientSex, otRoom: s.otRoom, date: s.date, time: s.time, medicalHistory: s.medicalHistory, estimatedDuration: s.estimatedDuration, scheduledBy: s.scheduledBy, status: status);
    await StorageService.saveOTSchedule(updated);
    _loadSchedules();
  }
}
