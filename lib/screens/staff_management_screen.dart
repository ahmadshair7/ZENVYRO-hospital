import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/staff_model.dart';
import '../models/ward_model.dart';
import '../models/doctor_model.dart';
import '../services/storage_service.dart';
import 'package:uuid/uuid.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  List<Staff> _staffList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedShiftFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    try {
      final staff = await StorageService.getAllStaff();
      setState(() {
        _staffList = staff;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGrey = Color(0xFF607D8B);
    final filteredStaff = _staffList.where((s) =>
        (s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        s.department.toLowerCase().contains(_searchQuery.toLowerCase())) &&
        (_selectedShiftFilter == 'All' || s.shift == _selectedShiftFilter)
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('STAFF DIRECTORY'),
        backgroundColor: primaryGrey,
      ),
      body: Column(
        children: [
          _buildBrandedHeader(context, primaryGrey),
          _buildFilterBar(),
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredStaff.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filteredStaff.length,
                        itemBuilder: (context, index) {
                          final member = filteredStaff[index];
                          return _buildStaffCard(member);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStaffDialog(),
        label: Text('ADD STAFF', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
        icon: const Icon(Icons.person_add_rounded),
        backgroundColor: primaryGrey,
        elevation: 8,
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
            'Human Resources',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage hospital team, roles, and duty shifts',
            style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search by name, role, dept...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(Staff member) {
    final roleColor = _getRoleColor(member.role);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: roleColor.withOpacity(0.1),
              child: Icon(_getRoleIcon(member.role), color: roleColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(member.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      _buildDutyBadge(member.isOnDuty),
                    ],
                  ),
                  Text(
                    '${member.role} • ${member.department}',
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(member.shift, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(width: 12),
                      Icon(Icons.phone_rounded, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(member.mobile, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                    ],
                  ),
                ],
              ),
            ),
            _buildActionMenu(member),
          ],
        ),
      ),
    );
  }

  Widget _buildDutyBadge(bool isOnDuty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOnDuty ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOnDuty ? 'ON-DUTY' : 'OFF',
        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: isOnDuty ? Colors.green : Colors.grey, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildActionMenu(Staff member) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.blueGrey),
      onSelected: (val) {
        if (val == 'edit') _showStaffDialog(member);
        if (val == 'delete') _confirmDelete(member);
        if (val == 'duty') _toggleDuty(member);
      },
      itemBuilder: (c) => [
        PopupMenuItem(value: 'duty', child: Text(member.isOnDuty ? 'Mark Off-Duty' : 'Mark On-Duty')),
        const PopupMenuItem(value: 'edit', child: Text('Edit Details')),
        const PopupMenuItem(value: 'delete', child: Text('Remove Staff', style: TextStyle(color: Colors.red))),
      ],
    );
  }

  void _showStaffDialog([Staff? staff]) {
    final isEditing = staff != null;
    final nameController = TextEditingController(text: staff?.name);
    final mobileController = TextEditingController(text: staff?.mobile);
    String selectedDept = staff?.department ?? 'OPD';
    String selectedRole = staff?.role ?? 'Doctor';
    String selectedShift = staff?.shift ?? 'Morning';
    String? selectedAssignment = staff?.assignment;

    final depts = ['OPD', 'Emergency', 'Indoor', 'OT', 'Pharmacy', 'Lab', 'Radiology', 'General'];
    final roles = ['Doctor', 'Nurse', 'Technician', 'Receptionist', 'Pharmacist', 'Support'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          List<String> assignmentOptions = [];
          if (selectedDept == 'OPD') assignmentOptions = opdCategories.map((c) => c.name).toList();
          if (selectedDept == 'Indoor') assignmentOptions = predefinedWards.map((w) => w.name).toList();
          if (selectedDept == 'Emergency') assignmentOptions = emergencyUnits.map((u) => u.name).toList();

          return AlertDialog(
            title: Text(isEditing ? 'UPDATE STAFF' : 'REGISTER STAFF', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogField(nameController, 'Full Name', Icons.person_rounded),
                  const SizedBox(height: 16),
                  _buildDialogField(mobileController, 'Mobile Number', Icons.phone_rounded, TextInputType.phone),
                  const SizedBox(height: 24),
                  _buildDialogDropdown('Department', depts, selectedDept, (v) => setDialogState(() => selectedDept = v!)),
                  const SizedBox(height: 12),
                  _buildDialogDropdown('Role', roles, selectedRole, (v) => setDialogState(() => selectedRole = v!)),
                  const SizedBox(height: 12),
                  _buildDialogDropdown('Shift', ['Morning', 'Evening', 'Night'], selectedShift, (v) => setDialogState(() => selectedShift = v!)),
                  if (assignmentOptions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDialogDropdown('Assignment', assignmentOptions, selectedAssignment ?? assignmentOptions.first, (v) => setDialogState(() => selectedAssignment = v)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final s = Staff(
                      id: isEditing ? staff.id : const Uuid().v4(),
                      name: nameController.text.trim(),
                      role: selectedRole,
                      department: selectedDept,
                      mobile: mobileController.text.trim(),
                      shift: selectedShift,
                      assignment: selectedAssignment,
                      isOnDuty: staff?.isOnDuty ?? true,
                    );
                    await StorageService.saveStaff(s);
                    if (mounted) { Navigator.pop(context); _loadStaff(); }
                  }
                },
                child: const Text('SAVE'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDialogField(TextEditingController c, String label, IconData i, [TextInputType t = TextInputType.text]) {
    return TextField(controller: c, keyboardType: t, decoration: InputDecoration(labelText: label, prefixIcon: Icon(i, size: 20)));
  }

  Widget _buildDialogDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items.first,
      decoration: InputDecoration(labelText: label, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(fontSize: 14)))).toList(),
      onChanged: onChanged,
    );
  }

  void _confirmDelete(Staff member) {
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text('Remove Staff?'),
      content: Text('Delete ${member.name} permanently?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('CANCEL')),
        ElevatedButton(onPressed: () async { await StorageService.deleteStaff(member.id); Navigator.pop(c); _loadStaff(); }, 
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: const Text('REMOVE')),
      ],
    ));
  }

  Future<void> _toggleDuty(Staff member) async { await StorageService.saveStaff(member.copyWith(isOnDuty: !member.isOnDuty)); _loadStaff(); }

  Widget _buildEmptyState() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text('Directory is empty', style: GoogleFonts.outfit(color: Colors.grey.shade400)),
    ]));
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Doctor': return Icons.medical_services_rounded;
      case 'Nurse': return Icons.person_outline_rounded;
      case 'Technician': return Icons.biotech_rounded;
      default: return Icons.person_rounded;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Doctor': return Colors.blue;
      case 'Nurse': return Colors.teal;
      case 'Technician': return Colors.orange;
      default: return Colors.blueGrey;
    }
  }

  Widget _buildFilterBar() {
    final shifts = ['All', 'Morning', 'Evening', 'Night'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: shifts.map((shift) {
          final isSelected = _selectedShiftFilter == shift;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(shift.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.blueGrey)),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedShiftFilter = shift),
              selectedColor: const Color(0xFF607D8B),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
