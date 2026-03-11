import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/filament.dart';
import '../models/print_job.dart';

class StorageService {

  static const String filamentsKey = "filaments_data";
  static const String jobsKey = "jobs_data";

  /// ======================
  /// FILAMENTS
  /// ======================

  static Future<List<Filament>> loadFilaments() async {

    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(filamentsKey);

    if (jsonString == null) return [];

    final List decoded = jsonDecode(jsonString);

    return decoded
        .map((e) => Filament.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveFilaments(List<Filament> filaments) async {

    final prefs = await SharedPreferences.getInstance();

    final data = filaments.map((f) => f.toJson()).toList();

    await prefs.setString(filamentsKey, jsonEncode(data));
  }

  /// ======================
  /// PRINT JOBS
  /// ======================

  static Future<List<PrintJob>> loadJobs() async {

    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(jobsKey);

    if (jsonString == null) return [];

    final List decoded = jsonDecode(jsonString);

    return decoded
        .map((e) => PrintJob.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveJobs(List<PrintJob> jobs) async {

    final prefs = await SharedPreferences.getInstance();

    final data = jobs.map((j) => j.toJson()).toList();

    await prefs.setString(jobsKey, jsonEncode(data));
  }
}