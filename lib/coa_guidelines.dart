// coa_guidelines.dart
class COACategory {
  final String name;
  final int requiredCount;

  COACategory({required this.name, required this.requiredCount});
}

class COAGuidelines {
  static List<COACategory> get categories => [
    COACategory(name: "Total Clinical Hours", requiredCount: 2000),
    // Patient Physical Status (only counts if the student administers anesthesia)
    COACategory(name: "Patient Physical Status Class I", requiredCount: 0),
    COACategory(name: "Patient Physical Status Class II", requiredCount: 0),
    COACategory(
      name: "Patient Physical Status Classes III - VI",
      requiredCount: 200,
    ),
    // Special Cases
    COACategory(
      name: "Special Cases - Geriatric 65+ years",
      requiredCount: 100,
    ),
    COACategory(
      name: "Special Cases - Pediatric 2 to 12 years",
      requiredCount: 30,
    ),
    COACategory(
      name: "Special Cases - Pediatric (<2 years)",
      requiredCount: 10,
    ),
    COACategory(name: "Special Cases - Neonate (<4 weeks)", requiredCount: 5),
    COACategory(name: "Special Cases - Trauma/Emergency", requiredCount: 30),
    // Obstetrical Management
    COACategory(
      name: "Obstetrical Management - Cesarean delivery",
      requiredCount: 10,
    ),
    COACategory(
      name: "Obstetrical Management - Analgesia for labor",
      requiredCount: 10,
    ),
    // Pain Management Encounters
    COACategory(name: "Pain Management Encounters", requiredCount: 15),
    // Methods of Anesthesia
    COACategory(
      name: "Methods of Anesthesia - General anesthesia",
      requiredCount: 400,
    ),
    COACategory(
      name: "Methods of Anesthesia - Inhalation induction",
      requiredCount: 25,
    ),
    COACategory(
      name: "Methods of Anesthesia - Mask management",
      requiredCount: 25,
    ),
    COACategory(
      name:
          "Methods of Anesthesia - Supraglottic airway devices - Laryngeal Mask",
      requiredCount: 35,
    ),
    COACategory(
      name: "Methods of Anesthesia - Supraglottic airway devices - Other",
      requiredCount: 35,
    ),
    COACategory(
      name: "Methods of Anesthesia - Tracheal intubation - Oral",
      requiredCount: 250,
    ),
    COACategory(
      name: "Methods of Anesthesia - Tracheal intubation - Nasal",
      requiredCount: 5,
    ),
    COACategory(
      name:
          "Methods of Anesthesia - Alternative tracheal intubation/endoscopic techniques",
      requiredCount: 25,
    ),
    COACategory(
      name: "Methods of Anesthesia - Emergence from anesthesia",
      requiredCount: 300,
    ),
    // Regional Techniques
    COACategory(name: "Regional Techniques - Spinal", requiredCount: 10),
    COACategory(name: "Regional Techniques - Epidural", requiredCount: 10),
    COACategory(name: "Regional Techniques - Peripheral", requiredCount: 10),
    COACategory(name: "Regional Techniques - Other", requiredCount: 10),
    // Moderate/Deep Sedation
    COACategory(name: "Moderate/deep sedation", requiredCount: 25),
    // Arterial Technique
    COACategory(
      name: "Arterial Technique - Arterial puncture/catheter insertion",
      requiredCount: 25,
    ),
    // Central Venous Catheter Placement
    COACategory(
      name: "Central Venous Catheter Placement - Non-PICC",
      requiredCount: 10,
    ),
    // Pulmonary Artery Catheter Placement
    COACategory(name: "Pulmonary Artery Catheter Placement", requiredCount: 5),
    // Intravenous catheter placement
    COACategory(name: "Intravenous catheter placement", requiredCount: 100),
    // Advanced noninvasive hemodynamic monitoring (if applicable)
    COACategory(
      name: "Advanced noninvasive hemodynamic monitoring",
      requiredCount: 0,
    ),
  ];
}
