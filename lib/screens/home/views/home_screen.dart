import 'dart:math';
import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/add_expense/views/add_expense.dart';
import 'package:expenses_tracker/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/home/views/main_screen.dart';
import 'package:expenses_tracker/screens/stats/stats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../add_expense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  late Color selectedItem = Colors.blue;
  Color unselectedItem = Colors.grey;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetExpensesBloc, GetExpensesState>(
      builder: (context, state) {
        if (state is GetExpensesSuccess) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Expenses Tracker'),
           
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                        transform: const GradientRotation(pi / 4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            CupertinoIcons.person_fill,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userData?['name'] ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (userData?['income'] != null)
                          Text(
                            '\$${userData!['income'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About Us'),
                    onTap: () {
                     Navigator.pop(context);
                      showAboutDialog(
                        context: context,
                        applicationName: "Expenses Tracker",
                        applicationVersion: "1.0.0",
                        children: const [
                          Text(
                              "This app helps users manage and track expenses.")
                        ],
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('About Developers'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('About Developers'),
                          content: const Text('Developed by Pixel Forge Team.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Settings"),
                          content: const Text("Settings options go here."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            )
                          ],
                        ),
                      );
                      // TODO: Implement settings logic or screen here
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Log out'),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            bottomNavigationBar: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              child: BottomNavigationBar(
                onTap: (value) {
                  setState(() {
                    index = value;
                  });
                },
                showSelectedLabels: false,
                showUnselectedLabels: false,
                elevation: 3,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      CupertinoIcons.home,
                      color: index == 0 ? selectedItem : unselectedItem,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      CupertinoIcons.graph_square_fill,
                      color: index == 1 ? selectedItem : unselectedItem,
                    ),
                    label: 'Stats',
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                Expense? newExpense = await Navigator.push(
                  context,
                  MaterialPageRoute<Expense>(
                    builder: (BuildContext context) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => CreateCategoryBloc(FirebaseExpenseRepo()),
                        ),
                        BlocProvider(
                          create: (context) => GetCategoriesBloc(FirebaseExpenseRepo())..add(GetCategories()),
                        ),
                        BlocProvider(
                          create: (context) => CreateExpenseBloc(FirebaseExpenseRepo()),
                        ),
                      ],
                      child: const AddExpense(),
                    ),
                  ),
                );

                if (newExpense != null) {
                  setState(() {
                    state.expenses.insert(0, newExpense);
                  });
                }
              },
              shape: const CircleBorder(),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.secondary,
                      Theme.of(context).colorScheme.primary,
                    ],
                    transform: const GradientRotation(pi / 4),
                  ),
                ),
                child: const Icon(CupertinoIcons.add),
              ),
            ),
            body: index == 0 ? MainScreen(state.expenses) : StatScreen(
              expenses: state.expenses,
              totalIncome: userData?['income']?.toDouble() ?? 5000.0,
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
