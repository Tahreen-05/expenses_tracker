import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_tracker/screens/home/views/home_screen.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  bool isLoading = false;

  Future<void> saveProfile() async {
    if (nameController.text.isEmpty || incomeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': nameController.text.trim(),
          'income': double.parse(incomeController.text.trim()),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => GetExpensesBloc(FirebaseExpenseRepo())..add(GetExpenses()),
              child: const HomeScreen(),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Your Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: incomeController,
              decoration: const InputDecoration(
                labelText: "Monthly Income",
                border: OutlineInputBorder(),
                prefixText: "\$ ",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: saveProfile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Save Profile"),
                  ),
          ],
        ),
      ),
    );
  }
} 