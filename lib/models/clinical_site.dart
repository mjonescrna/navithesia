import 'package:hive/hive.dart';
import 'dart:math' as math;

part 'clinical_site.g.dart';

@HiveType(typeId: 3)
class ClinicalSite extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String address;

  @HiveField(3)
  double latitude;

  @HiveField(4)
  double longitude;

  @HiveField(5)
  final String phoneNumber;

  @HiveField(6)
  final String website;

  @HiveField(7)
  final List<String> specialties;

  @HiveField(8)
  final Map<String, int> caseVolumes;

  ClinicalSite({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    required this.website,
    required this.specialties,
    required this.caseVolumes,
  });

  double distanceTo(double lat, double lng) {
    const double earthRadius = 6371.0; // km
    double lat1 = latitude * math.pi / 180.0;
    double lat2 = lat * math.pi / 180.0;
    double dlat = (lat - latitude) * math.pi / 180.0;
    double dlng = (lng - longitude) * math.pi / 180.0;

    double a =
        math.sin(dlat / 2.0) * math.sin(dlat / 2.0) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dlng / 2.0) *
            math.sin(dlng / 2.0);
    double c = 2.0 * math.asin(math.sqrt(a));
    return earthRadius * c;
  }

  factory ClinicalSite.fromJson(Map<String, dynamic> json) {
    return ClinicalSite(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      phoneNumber: json['phoneNumber'] as String,
      website: json['website'] as String,
      specialties: List<String>.from(json['specialties']),
      caseVolumes: Map<String, int>.from(json['caseVolumes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'website': website,
      'specialties': specialties,
      'caseVolumes': caseVolumes,
    };
  }
}
