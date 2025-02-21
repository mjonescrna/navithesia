class CaseLog {
  final String category;
  int count;

  CaseLog({required this.category, this.count = 0});

  // Convert a CaseLog into a Map for JSON encoding.
  Map<String, dynamic> toJson() {
    return {'category': category, 'count': count};
  }
}
