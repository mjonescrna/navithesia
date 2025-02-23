import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/clinical_site.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class ClinicalSiteService {
  static final ClinicalSiteService _instance = ClinicalSiteService._internal();
  factory ClinicalSiteService() => _instance;
  ClinicalSiteService._internal();

  final List<ClinicalSite> _sites = [];
  double _currentLat = 0;
  double _currentLng = 0;

  Future<void> initialize() async {
    // In a real app, this would load from an API or database
    _sites.add(
      ClinicalSite(
        id: '1',
        name: 'Memorial Regional Hospital',
        latitude: 26.0187,
        longitude: -80.1798,
        address: '3501 Johnson St, Hollywood, FL 33021',
        type: 'Hospital',
        specialties: ['General', 'Trauma', 'Cardiac'],
      ),
    );
  }

  Future<void> updateCurrentLocation(double lat, double lng) async {
    _currentLat = lat;
    _currentLng = lng;
  }

  Future<List<ClinicalSite>> searchSites(String query) async {
    final normalizedQuery = query.toLowerCase();
    return _sites.where((site) {
      return site.name.toLowerCase().contains(normalizedQuery) ||
          site.type.toLowerCase().contains(normalizedQuery) ||
          site.specialties.any(
            (s) => s.toLowerCase().contains(normalizedQuery),
          );
    }).toList();
  }

  Future<Map<String, int>> getCaseVolumes(String siteId) async {
    try {
      final site = _sites.firstWhere((s) => s.id == siteId);
      return site.caseVolumes;
    } catch (e) {
      print('Error getting case volumes: $e');
      return {};
    }
  }

  Future<List<String>> getSpecialties(String siteId) async {
    try {
      final site = _sites.firstWhere((s) => s.id == siteId);
      return site.specialties;
    } catch (e) {
      print('Error getting specialties: $e');
      return [];
    }
  }

  double? getDistance(String siteId) {
    final site = _sites.firstWhere((s) => s.id == siteId);
    return _calculateDistance(
      _currentLat,
      _currentLng,
      site.latitude,
      site.longitude,
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 3958.8; // Earth's radius in miles
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  Future<void> refreshSiteData(String siteId) async {
    // Implement API call to refresh site data
    // This would typically update case volumes and specialties
    try {
      final response = await http.get(
        Uri.parse('https://api.example.com/sites/$siteId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final index = _sites.indexWhere((s) => s.id == siteId);
        if (index != -1) {
          _sites[index] = ClinicalSite.fromJson(data);
        }
      }
    } catch (e) {
      print('Error refreshing site data: $e');
    }
  }
}
