import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String date;
  final String? description;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
  });

  @override
  List<Object?> get props => [id, title, amount, category, date, description];

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    String? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
      'description': description,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: json['date'] as String,
      description: json['description'] as String?,
    );
  }
} 