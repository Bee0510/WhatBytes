enum Priority { low, medium, high }

extension PriorityX on Priority {
  String get asKey => switch (this) { Priority.low => 'low', Priority.medium => 'medium', Priority.high => 'high' };
  static Priority from(String s) => s == 'high' ? Priority.high : s == 'medium' ? Priority.medium : Priority.low;
}
