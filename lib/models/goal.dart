class Goal {
  final String id;
  final String category;
  final int target;
  final int current;
  final DateTime deadline;

  Goal({
    required this.id,
    required this.category,
    required this.target,
    this.current = 0,
    required this.deadline,
  });
}
