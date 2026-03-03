import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor_model.dart';
import '../models/ward_model.dart';
import '../models/staff_model.dart';
import '../models/ot_schedule_model.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Keys
  static const String _opdPatientsKey = 'opd_patients';
  static const String _emergencyPatientsKey = 'emergency_patients';
  static const String _staffKey = 'staff';
  static const String _otSchedulesKey = 'ot_schedules';
  static const String _wardsKey = 'wards';
  static const String _emergencyUnitsKey = 'emergency_units';
  static const String _operationTheatersKey = 'operation_theaters';
  static const String _opdTokensKey = 'opd_tokens';
  static const String _emergencyTokensKey = 'emergency_tokens';

  // ─── OPD PATIENTS ───────────────────────────────────────────────────────

  static Future<void> savePatient(Patient patient) async {
    final patients = await getAllPatients();
    final index = patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      patients[index] = patient;
    } else {
      patients.add(patient);
    }
    await _prefs.setString(_opdPatientsKey, jsonEncode(patients.map((p) => p.toJson()).toList()));
  }

  static Future<void> deletePatient(String id) async {
    final patients = await getAllPatients();
    patients.removeWhere((p) => p.id == id);
    await _prefs.setString(_opdPatientsKey, jsonEncode(patients.map((p) => p.toJson()).toList()));
  }

  static Future<List<Patient>> getAllPatients() async {
    final data = _prefs.getString(_opdPatientsKey);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((item) => Patient.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching patients: $e');
      return [];
    }
  }

  static Future<List<Patient>> getPatientsForCategory(String categoryName) async {
    final all = await getAllPatients();
    return all.where((p) => p.categoryName == categoryName).toList();
  }

  // ─── EMERGENCY PATIENTS ──────────────────────────────────────────────────

  static Future<void> saveEmergencyPatient(Patient patient) async {
    final patients = await getAllEmergencyPatients();
    final index = patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      patients[index] = patient;
    } else {
      patients.add(patient);
    }
    await _prefs.setString(_emergencyPatientsKey, jsonEncode(patients.map((p) => p.toJson()).toList()));
  }

  static Future<List<Patient>> getAllEmergencyPatients() async {
    final data = _prefs.getString(_emergencyPatientsKey);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((item) => Patient.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching emergency patients: $e');
      return [];
    }
  }

  static Future<void> deleteEmergencyPatient(String id) async {
    final patients = await getAllEmergencyPatients();
    patients.removeWhere((p) => p.id == id);
    await _prefs.setString(_emergencyPatientsKey, jsonEncode(patients.map((p) => p.toJson()).toList()));
  }

  // ─── TOKEN COUNTERS ──────────────────────────────────────────────────────

  static Future<void> saveTokens() async {
    await _prefs.setInt(_opdTokensKey, TokenManager.getTokens());
  }

  static Future<void> loadTokens() async {
    final count = _prefs.getInt(_opdTokensKey) ?? 0;
    TokenManager.setTokens(count);
  }

  static Future<void> saveEmergencyTokens(int count) async {
    await _prefs.setInt(_emergencyTokensKey, count);
  }

  static Future<int> loadEmergencyTokens() async {
    return _prefs.getInt(_emergencyTokensKey) ?? 0;
  }

  // ─── WARDS / BEDS ────────────────────────────────────────────────────────

  static Future<void> saveWards(List<Ward> wards) async {
    await _prefs.setString(_wardsKey, jsonEncode(wards.map((w) => w.toJson()).toList()));
  }

  static Future<void> saveEmergencyUnits(List<Ward> units) async {
    await _prefs.setString(_emergencyUnitsKey, jsonEncode(units.map((u) => u.toJson()).toList()));
  }

  static Future<void> saveOperationTheaters(List<Ward> ots) async {
    await _prefs.setString(_operationTheatersKey, jsonEncode(ots.map((o) => o.toJson()).toList()));
  }

  static Future<void> loadWards() async {
    try {
      // Load Indoor Wards
      final wardsData = _prefs.getString(_wardsKey);
      if (wardsData != null) {
        final List<dynamic> list = jsonDecode(wardsData);
        for (final wardData in list) {
          final name = wardData['name'] as String?;
          final index = predefinedWards.indexWhere((w) => w.name == name);
          if (index != -1) {
            final loadedWard = Ward.fromJson(wardData, predefinedWards[index]);
            predefinedWards[index].beds.clear();
            predefinedWards[index].beds.addAll(loadedWard.beds);
          }
        }
      }

      // Load Emergency Units
      final emergencyData = _prefs.getString(_emergencyUnitsKey);
      if (emergencyData != null) {
        final List<dynamic> list = jsonDecode(emergencyData);
        for (final unitData in list) {
          final name = unitData['name'] as String?;
          final index = emergencyUnits.indexWhere((u) => u.name == name);
          if (index != -1) {
            final loadedUnit = Ward.fromJson(unitData, emergencyUnits[index]);
            emergencyUnits[index].beds.clear();
            emergencyUnits[index].beds.addAll(loadedUnit.beds);
          }
        }
      }

      // Load Operation Theaters
      final otData = _prefs.getString(_operationTheatersKey);
      if (otData != null) {
        final List<dynamic> list = jsonDecode(otData);
        for (final otData in list) {
          final name = otData['name'] as String?;
          final index = operationTheaters.indexWhere((o) => o.name == name);
          if (index != -1) {
            final loadedOt = Ward.fromJson(otData, operationTheaters[index]);
            operationTheaters[index].beds.clear();
            operationTheaters[index].beds.addAll(loadedOt.beds);
          }
        }
      }
    } catch (e) {
      print('Error loading wards: $e');
    }
  }

  // ─── PHARMACY HELPERS ────────────────────────────────────────────────────

  static Future<List<Patient>> getPendingPharmacyPatients() async {
    final all = await getAllPatients();
    return all.where((p) => p.status == 'Checked' && p.history.any((c) => !c.isDispensed)).toList();
  }

  static Future<List<Patient>> getPendingEmergencyPharmacyPatients() async {
    final all = await getAllEmergencyPatients();
    return all.where((p) => (p.emergencyMedicines?.isNotEmpty ?? false) && !p.isEmergencyMedicinesDispensed).toList();
  }

  static Future<List<Patient>> getPendingDischargePharmacyPatients() async {
    final all = await getAllEmergencyPatients();
    return all.where((p) => (p.dischargeMedicines?.isNotEmpty ?? false) && !p.isDischargeMedicinesDispensed).toList();
  }

  // ─── ADMIN STATS ─────────────────────────────────────────────────────────

  static Future<Map<String, int>> getHospitalOccupancyStats() async {
    await loadWards();
    int indoorOccupied = 0;
    int indoorTotal = 0;
    for (var w in predefinedWards) {
      indoorOccupied += w.occupiedBedsCount;
      indoorTotal += w.beds.length;
    }

    int emergencyOccupied = 0;
    int emergencyTotal = 0;
    for (var u in emergencyUnits) {
      emergencyOccupied += u.occupiedBedsCount;
      emergencyTotal += u.beds.length;
    }

    int otOccupied = 0;
    int otTotal = 0;
    for (var o in operationTheaters) {
      otOccupied += o.occupiedBedsCount;
      otTotal += o.beds.length;
    }

    return {
      'indoorOccupied': indoorOccupied,
      'indoorTotal': indoorTotal,
      'emergencyOccupied': emergencyOccupied,
      'emergencyTotal': emergencyTotal,
      'otOccupied': otOccupied,
      'otTotal': otTotal,
    };
  }

  static Future<int> getTodayTotalPatients() async {
    final now = DateTime.now();
    final todayStr = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

    final opd = await getAllPatients();
    final emergency = await getAllEmergencyPatients();

    int count = 0;
    count += opd.where((p) => p.registrationDate == todayStr).length;
    count += emergency.where((p) => p.registrationDate == todayStr).length;

    return count;
  }

  // ─── STAFF MANAGEMENT ────────────────────────────────────────────────────

  static Future<void> saveStaff(Staff member) async {
    final staff = await getAllStaff();
    final index = staff.indexWhere((s) => s.id == member.id);
    if (index != -1) {
      staff[index] = member;
    } else {
      staff.add(member);
    }
    await _prefs.setString(_staffKey, jsonEncode(staff.map((s) => s.toJson()).toList()));
  }

  static Future<void> deleteStaff(String id) async {
    final staff = await getAllStaff();
    staff.removeWhere((s) => s.id == id);
    await _prefs.setString(_staffKey, jsonEncode(staff.map((s) => s.toJson()).toList()));
  }

  static Future<List<Staff>> getAllStaff() async {
    final data = _prefs.getString(_staffKey);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((item) => Staff.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching staff: $e');
      return [];
    }
  }

  // ─── OT SCHEDULES ────────────────────────────────────────────────────────

  static Future<void> saveOTSchedule(OTSchedule schedule) async {
    final schedules = await getAllOTSchedules();
    final index = schedules.indexWhere((s) => s.id == schedule.id);
    if (index != -1) {
      schedules[index] = schedule;
    } else {
      schedules.add(schedule);
    }
    await _prefs.setString(_otSchedulesKey, jsonEncode(schedules.map((s) => s.toJson()).toList()));
  }

  static Future<List<OTSchedule>> getAllOTSchedules() async {
    final data = _prefs.getString(_otSchedulesKey);
    if (data == null) return [];
    try {
      final List<dynamic> list = jsonDecode(data);
      return list.map((item) => OTSchedule.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching OT schedules: $e');
      return [];
    }
  }

  static Future<List<OTSchedule>> getOTSchedulesForOTRoom(String otRoom, String date) async {
    final all = await getAllOTSchedules();
    return all.where((s) => s.otRoom == otRoom && s.date == date).toList();
  }
}
