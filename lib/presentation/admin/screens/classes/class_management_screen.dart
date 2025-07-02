import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_colors.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/domain/providers/class_provider.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final classProvider = context.read<ClassProvider>();
    await Future.wait([
      classProvider.loadClasses(),
      classProvider.loadSchedules(),
      classProvider.loadInstructors(),
      classProvider.loadStudios(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.classManagement),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dersler'),
            Tab(text: 'Program'),
            Tab(text: 'Eğitmenler'),
            Tab(text: 'Stüdyolar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _classesTab(),
          _scheduleTab(),
          _instructorsTab(),
          _studiosTab(),
        ],
      ),
    );
  }

  Widget _classesTab() {
    return Center(
      child: Text(
        "Class Management",
        //context.l10n.classesTab,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _scheduleTab() {
    return Center(
      child: Text(
        "Schedule Management",
        //context.l10n.scheduleTab,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _instructorsTab() {
    return Center(
      child: Text(
        "Instructors Management",
        //context.l10n.instructorsTab,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _studiosTab() {
    return Center(
      child: Text(
        "Studios Management",
        //context.l10n.studiosTab,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
      ),
    );
  }
}
