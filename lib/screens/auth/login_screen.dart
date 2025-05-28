import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_tracker/screens/home/views/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expenses_tracker/screens/auth/signup_screen.dart';
import 'package:expenses_tracker/screens/auth/profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> checkUserProfile(User user) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!mounted) return;
    
    if (!doc.exists) {
      // User hasn't completed profile setup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
      );
    } else {
      // User has completed profile setup
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
  }

  void login() async {
    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      // Check if user has completed profile setup
      if (userCredential.user != null) {
        await checkUserProfile(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        msg = 'Incorrect email or password.';
      } else if (e.code == 'user-not-found') {
        msg = 'No user found for this email.';
      } else {
        msg = e.message ?? 'Login failed.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Login"),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
              child: const Text("Don't have an account? Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
