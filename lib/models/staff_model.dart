
class Staff {
  final String id;
  final String name;
  final String role;
  final String department;
  final String mobile;
  final String shift; // Morning, Evening, Night
  final String? assignment; // Specific Category, Ward, OT room, etc.
  final bool isOnDuty;

  Staff({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.mobile,
    required this.shift,
    this.assignment,
    this.isOnDuty = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'department': department,
    'mobile': mobile,
    'shift': shift,
    'assignment': assignment,
    'isOnDuty': isOnDuty,
  };

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    id: json['id'],
    name: json['name'],
    role: json['role'],
    department: json['department'],
    mobile: json['mobile'],
    shift: json['shift'],
    assignment: json['assignment'],
    isOnDuty: json['isOnDuty'] ?? true,
  );

  Staff copyWith({
    String? name,
    String? role,
    String? department,
    String? mobile,
    String? shift,
    String? assignment,
    bool? isOnDuty,
  }) {
    return Staff(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      department: department ?? this.department,
      mobile: mobile ?? this.mobile,
      shift: shift ?? this.shift,
      assignment: assignment ?? this.assignment,
      isOnDuty: isOnDuty ?? this.isOnDuty,
    );
  }
}
