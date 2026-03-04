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
    final active = _schedules.where((s) => s.status == 'Active').toList();
    final pending = _schedules.where((s) => s.status == 'Pending').toList();
    final completed = _schedules.where((s) => s.status == 'Completed').toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (active.isNotEmpty) ...[
          _buildSubHeader('IN PROGRESS'),
          ...active.map((s) => _buildScheduleCard(s, isHighPriority: true)),
          const SizedBox(height: 24),
        ],
        if (pending.isNotEmpty) ...[
          _buildSubHeader('PENDING QUEUE'),
          ...pending.map((s) => _buildScheduleCard(s)),
          const SizedBox(height: 24),
        ],
        if (completed.isNotEmpty) ...[
          _buildSubHeader('TODAY\'S COMPLETED'),
          ...completed.map((s) => _buildScheduleCard(s)),
        ],
      ],
    );
  }

  Widget _buildSubHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blueGrey, letterSpacing: 1.5)),
    );
  }

  Widget _buildScheduleCard(OTSchedule s, {bool isHighPriority = false}) {
    return Card(
      elevation: isHighPriority ? 8 : 0,
       shadowColor: widget.ot.color.withOpacity(0.2),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: isHighPriority ? widget.ot.color : Colors.grey.shade200, width: isHighPriority ? 2 : 1),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: widget.ot.color.withOpacity(0.1),
          child: Icon(isHighPriority ? Icons.play_circle_fill_rounded : Icons.pending_actions_rounded, color: widget.ot.color),
        ),
        title: Text(s.patientName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text('${s.date} • ${s.time}', style: const TextStyle(fontSize: 12)),
        trailing: _buildStatusChip(s.status),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow('Age/Sex', '${s.patientAge} | ${s.patientSex ?? "N/A"}'),
                _buildDetailRow('Plan', s.estimatedDuration),
                _buildDetailRow('Surgeon', s.scheduledBy),
                if (s.assignedStaffIds.isNotEmpty)
                  FutureBuilder<List<Staff>>(
                    future: StorageService.getAllStaff(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final names = snapshot.data!
                        .where((staff) => s.assignedStaffIds.contains(staff.id))
                        .map((staff) => staff.name)
                        .join(", ");
                      return _buildDetailRow('Surgical Team', names);
                    },
                  ),
                const SizedBox(height: 16),
                _buildNoteSection('INDICATIONS', s.medicalHistory),
                if (s.preOpNotes.isNotEmpty) _buildNoteSection('PRE-OP NOTES', s.preOpNotes),
                if (s.intraOpNotes.isNotEmpty) _buildNoteSection('INTRA-OP NOTES', s.intraOpNotes),
                if (s.postOpNotes.isNotEmpty) _buildNoteSection('POST-OP NOTES', s.postOpNotes),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (s.status == 'Pending')
                      _buildActionButton('START PROCEDURE', Colors.blue, () => _showStartProcedureDialog(s)),
                    if (s.status == 'Active')
                      _buildActionButton('MARK RECOVERY', Colors.green, () => _showCompleteProcedureDialog(s)),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      onSelected: (v) => _updateStatus(s, v),
                      itemBuilder: (c) => [
                        const PopupMenuItem(value: 'Pending', child: Text('Reset to Pending')),
                        const PopupMenuItem(value: 'Completed', child: Text('Manual Completion')),
                        const PopupMenuItem(value: 'Cancelled', child: Text('Cancel Surgery', style: TextStyle(color: Colors.red))),
                      ],
                      child: const Icon(Icons.more_vert_rounded, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.blueGrey, letterSpacing: 1)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
            child: Text(content, style: const TextStyle(fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }

  void _showStartProcedureDialog(OTSchedule s) async {
    final preOpController = TextEditingController();
    final allStaff = await StorageService.getAllStaff();
    final otStaff = allStaff.where((st) => st.department == 'OT' && st.assignment == widget.ot.name && st.isOnDuty).toList();
    List<String> selectedStaffIds = [];

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Start: ${s.patientName}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SELECT SURGICAL TEAM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blueGrey)),
                const SizedBox(height: 8),
                if (otStaff.isEmpty) 
                  const Text('No staff on duty in this OT', style: TextStyle(color: Colors.red, fontSize: 12)),
                ...otStaff.map((st) => CheckboxListTile(
                  title: Text(st.name, style: const TextStyle(fontSize: 14)),
                  subtitle: Text(st.role, style: const TextStyle(fontSize: 11)),
                  value: selectedStaffIds.contains(st.id),
                  dense: true,
                  onChanged: (val) => setDialogState(() => val! ? selectedStaffIds.add(st.id) : selectedStaffIds.remove(st.id)),
                )),
                const SizedBox(height: 16),
                TextField(
                  controller: preOpController,
                  decoration: const InputDecoration(labelText: 'Pre-operative Notes', hintText: 'Physical prep, anesthesia, etc.'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                final updated = OTSchedule(
                  id: s.id, patientId: s.patientId, patientName: s.patientName, patientAge: s.patientAge, patientSex: s.patientSex,
                  otRoom: s.otRoom, date: s.date, time: s.time, medicalHistory: s.medicalHistory, estimatedDuration: s.estimatedDuration,
                  scheduledBy: s.scheduledBy, status: 'Active', preOpNotes: preOpController.text, assignedStaffIds: selectedStaffIds,
                );
                await StorageService.saveOTSchedule(updated);
                if (mounted) { Navigator.pop(context); _loadSchedules(); }
              },
              child: const Text('ENGAGE OT'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompleteProcedureDialog(OTSchedule s) async {
    final intraOpController = TextEditingController();
    final postOpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Review: ${s.patientName}'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: intraOpController, decoration: const InputDecoration(labelText: 'Intra-operative Findings'), maxLines: 3),
              const SizedBox(height: 12),
              TextField(controller: postOpController, decoration: const InputDecoration(labelText: 'Post-operative Orders'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('STAY ACTIVE')),
          ElevatedButton(
            onPressed: () async {
              final now = DateTime.now();
              final updated = OTSchedule(
                id: s.id, patientId: s.patientId, patientName: s.patientName, patientAge: s.patientAge, patientSex: s.patientSex,
                otRoom: s.otRoom, date: s.date, time: s.time, medicalHistory: s.medicalHistory, estimatedDuration: s.estimatedDuration,
                scheduledBy: s.scheduledBy, status: 'Completed', preOpNotes: s.preOpNotes, assignedStaffIds: s.assignedStaffIds,
                intraOpNotes: intraOpController.text, postOpNotes: postOpController.text,
                completionDate: "${now.day}-${now.month}-${now.year}",
                completionTime: "${now.hour}:${now.minute}",
              );
              await StorageService.saveOTSchedule(updated);
              if (mounted) { Navigator.pop(context); _loadSchedules(); }
            },
            child: const Text('FINALIZE CASE'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          Expanded(child: Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'Active' ? Colors.blue : (status == 'Completed' ? Colors.green : Colors.orange);
    if (status == 'Cancelled') color = Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
    );
  }

  void _updateStatus(OTSchedule s, String status) async {
    final updated = OTSchedule(
      id: s.id, patientId: s.patientId, patientName: s.patientName, patientAge: s.patientAge, patientSex: s.patientSex,
      otRoom: s.otRoom, date: s.date, time: s.time, medicalHistory: s.medicalHistory, estimatedDuration: s.estimatedDuration,
      scheduledBy: s.scheduledBy, status: status, preOpNotes: s.preOpNotes, intraOpNotes: s.intraOpNotes,
      postOpNotes: s.postOpNotes, assignedStaffIds: s.assignedStaffIds,
    );
    await StorageService.saveOTSchedule(updated);
    _loadSchedules();
  }
}
