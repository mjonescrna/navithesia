import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/clinical_site.dart';

class SchoolDataService {
  static final SchoolDataService _instance = SchoolDataService._internal();
  factory SchoolDataService() => _instance;
  SchoolDataService._internal();

  Map<String, List<ClinicalSite>> _hospitalCache = {};

  Future<void> initialize() async {
    try {
      final String jsonContent = await rootBundle.loadString(
        'assets/hospitals.json',
      );
      final data = json.decode(jsonContent) as Map<String, dynamic>;

      // Process each category of hospitals
      for (var entry in data.entries) {
        _hospitalCache[entry.key] = List<ClinicalSite>.from(
          (entry.value as List).map((x) => ClinicalSite.fromJson(x)),
        );
      }
    } catch (e) {
      print('Error loading hospital data: $e');
      _hospitalCache = {};
    }
  }

  Future<List<ClinicalSite>> getClinicalSites() async {
    if (_hospitalCache.isEmpty) {
      await initialize();
    }

    List<ClinicalSite> allSites = [];
    _hospitalCache.values.forEach(allSites.addAll);
    return allSites;
  }

  Future<List<ClinicalSite>> getAllTeachingHospitals() async {
    if (_hospitalCache.isEmpty) {
      await initialize();
    }
    return _hospitalCache['teaching_hospitals'] ?? [];
  }

  Future<List<ClinicalSite>> getAllTraumaCenters() async {
    if (_hospitalCache.isEmpty) {
      await initialize();
    }
    return _hospitalCache['trauma_centers'] ?? [];
  }

  Future<List<ClinicalSite>> getAllChildrensHospitals() async {
    if (_hospitalCache.isEmpty) {
      await initialize();
    }
    return _hospitalCache['childrens_hospitals'] ?? [];
  }

  Future<List<ClinicalSite>> getHospitalsByType(String type) async {
    if (_hospitalCache.isEmpty) {
      await initialize();
    }
    return _hospitalCache[type] ?? [];
  }

  Future<ClinicalSite?> getHospitalById(String id) async {
    if (_hospitalCache.isEmpty) {
      await initialize();
    }

    for (var hospitals in _hospitalCache.values) {
      final match = hospitals.firstWhere(
        (hospital) => hospital.id == id,
        orElse:
            () => ClinicalSite(
              id: '',
              name: '',
              address: '',
              latitude: 0,
              longitude: 0,
              phoneNumber: '',
              website: '',
              specialties: [],
              caseVolumes: {},
            ),
      );
      if (match.id.isNotEmpty) return match;
    }
    return null;
  }
}
