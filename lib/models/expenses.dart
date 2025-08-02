
class Expenses {
  int? id;
  String category;
  double amount;
  DateTime date;
  String? notes;

  Expenses({this.id, required this.category, required this.amount, required this.date, this.notes});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Expenses.fromMap(Map<String, dynamic> map) {
    return Expenses(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }
}