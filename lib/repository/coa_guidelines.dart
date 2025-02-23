// lib/repository/coa_guidelines.dart
// This file defines a comprehensive list of COA clinical experience categories
// based on the COA Guidelines for Counting Clinical Experiences (Revised July 2017).

/// Model class representing a COA category.
class COACategory {
  final String name;
  final int requiredCount;
  final String description;
  final List<String> subcategories;

  COACategory({
    required this.name,
    required this.requiredCount,
    required this.description,
    this.subcategories = const [],
  });
}

/// The COAGuidelines class provides a static list of COACategory objects
/// for all the clinical experience categories as defined in the guidelines.
class COAGuidelines {
  static final Map<String, int> requiredCounts = {
    'Total Clinical Hours': 600,
    'Special Cases - Geriatric (65+ years)': 100,
    'Special Cases - Pediatric (2 to 12 years)': 75,
    'Obstetrical Management - Analgesia for labor': 40,
    'ASA I & II': 50,
    'ASA III': 25,
    'ASA IV & V': 10,
    'Geriatric 65+ years': 100,
    'Pediatric 2-12 years': 75,
    'Pediatric (under 2 years)': 25,
    'Trauma/Emergency': 30,
    'Intra-abdominal': 75,
    'Extrathoracic': 50,
    'Intrathoracic': 40,
    'Vascular': 30,
    'Head': 40,
    'Neck': 40,
    'General Anesthesia': 400,
    'IV Induction': 300,
    'Mask Induction': 25,
    'Regional Anesthesia': 40,
    'Spinal': 50,
    'Epidural': 50,
    'Peripheral Nerve Block': 40,
    'Cesarean Delivery': 30,
    'Analgesia for Labor': 40,
    'Central Line Placement': 20,
    'Arterial Line Placement': 25,
    'Ultrasound Guided Techniques': 40,
    'Pain Management Encounters': 20,
  };

  static final List<COACategory> categories = [
    COACategory(
      name: 'Patient Physical Status',
      requiredCount: 85,
      description: 'ASA Physical Status classifications',
      subcategories: ['ASA I & II', 'ASA III', 'ASA IV & V'],
    ),
    COACategory(
      name: 'Special Cases',
      requiredCount: 230,
      description: 'Age-specific and emergency cases',
      subcategories: [
        'Geriatric 65+ years',
        'Pediatric 2-12 years',
        'Pediatric (under 2 years)',
        'Trauma/Emergency',
      ],
    ),
    // Add more categories as needed
  ];
}
