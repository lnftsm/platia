import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/domain/providers/auth_provider.dart';
import 'package:platia/domain/providers/instructor_provider.dart';
import 'package:platia/presentation/instructor/screens/dashboard/instructor_dashboard_screen.dart';
import 'package:platia/presentation/instructor/screens/classes/instructor_schedule_screen.dart';
import 'package:platia/presentation/instructor/screens/profile/instructor_profile_screen.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const InstructorDashboardScreen(),
    const InstructorScheduleScreen(),
    const InstructorProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadInstructorData();
  }

  Future<void> _loadInstructorData() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      await context.read<InstructorProvider>().loadInstructorByUserId(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: 'Panel',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today_outlined),
            activeIcon: const Icon(Icons.calendar_today),
            label: 'Derslerim',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: context.l10n.profile,
          ),
        ],
      ),
    );
  }
}
