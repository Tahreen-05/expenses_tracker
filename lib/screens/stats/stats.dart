import 'package:flutter/material.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/chart_screen.dart';

class StatScreen extends StatelessWidget {
  final List<Expense> expenses;
  final double totalIncome;

  const StatScreen({
    super.key,
    required this.expenses,
    this.totalIncome = 5000.0, // Default value, should be updated with actual income
  });

  @override
  Widget build(BuildContext context) {
    return ChartScreen(
      expenses: expenses,
      totalIncome: totalIncome,
    );
  }
}