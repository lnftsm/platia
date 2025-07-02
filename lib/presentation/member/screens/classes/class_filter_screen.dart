import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:platia/config/theme/app_text_styles.dart';
import 'package:platia/core/extensions/context_extensions.dart';
import 'package:platia/data/models/class.dart';
import 'package:platia/data/models/filter_options.dart';
import 'package:platia/domain/providers/class_provider.dart';
import 'package:platia/presentation/common/widgets/app_button.dart';

class ClassFilterScreen extends StatefulWidget {
  const ClassFilterScreen({super.key});

  @override
  State<ClassFilterScreen> createState() => _ClassFilterScreenState();
}

class _ClassFilterScreenState extends State<ClassFilterScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  final Set<String> _selectedInstructors = {};
  final Set<String> _selectedStudios = {};
  final Set<ClassDifficulty> _selectedDifficulties = {};
  final Set<ClassCategory> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    final currentFilter = context.read<ClassProvider>().currentFilter;
    if (currentFilter != null) {
      _startDate = currentFilter.startDate;
      _endDate = currentFilter.endDate;
      _selectedInstructors.addAll(currentFilter.instructorIds ?? []);
      _selectedStudios.addAll(currentFilter.studioIds ?? []);
      _selectedDifficulties.addAll(currentFilter.difficulties ?? []);
      _selectedCategories.addAll(currentFilter.categories ?? []);
    }
  }

  void _applyFilter() {
    final filter = FilterOptions(
      startDate: _startDate,
      endDate: _endDate,
      instructorIds: _selectedInstructors.isNotEmpty
          ? _selectedInstructors.toList()
          : null,
      studioIds: _selectedStudios.isNotEmpty ? _selectedStudios.toList() : null,
      difficulties: _selectedDifficulties.isNotEmpty
          ? _selectedDifficulties.toList()
          : null,
      categories: _selectedCategories.isNotEmpty
          ? _selectedCategories.toList()
          : null,
    );

    context.pop(filter);
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedInstructors.clear();
      _selectedStudios.clear();
      _selectedDifficulties.clear();
      _selectedCategories.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = context.watch<ClassProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.filter),
        actions: [
          TextButton(onPressed: _clearFilter, child: const Text('Temizle')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range
            Text('Tarih Aralığı', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Başlangıç',
                    date: _startDate,
                    onDateSelected: (date) {
                      setState(() {
                        _startDate = date;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Bitiş',
                    date: _endDate,
                    onDateSelected: (date) {
                      setState(() {
                        _endDate = date;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Categories
            Text('Kategori', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ClassCategory.values.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  label: Text(_getCategoryText(category)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Difficulty
            Text('Seviye', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ClassDifficulty.values.map((difficulty) {
                final isSelected = _selectedDifficulties.contains(difficulty);
                return FilterChip(
                  label: Text(_getDifficultyText(difficulty)),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDifficulties.add(difficulty);
                      } else {
                        _selectedDifficulties.remove(difficulty);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Instructors
            Text('Eğitmen', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            ...classProvider.instructors.map((instructor) {
              final isSelected = _selectedInstructors.contains(instructor.id);
              return CheckboxListTile(
                title: Text(instructor.fullName),
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedInstructors.add(instructor.id);
                    } else {
                      _selectedInstructors.remove(instructor.id);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 24),

            // Studios
            Text('Stüdyo', style: AppTextStyles.h4),
            const SizedBox(height: 12),
            ...classProvider.studios.map((studio) {
              final isSelected = _selectedStudios.contains(studio.id);
              return CheckboxListTile(
                title: Text(studio.name),
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedStudios.add(studio.id);
                    } else {
                      _selectedStudios.remove(studio.id);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(text: 'Filtreleri Uygula', onPressed: _applyFilter),
        ),
      ),
    );
  }

  String _getCategoryText(ClassCategory category) {
    switch (category) {
      case ClassCategory.pilates:
        return 'Pilates';
      case ClassCategory.yoga:
        return 'Yoga';
      case ClassCategory.meditation:
        return 'Meditasyon';
      case ClassCategory.workshop:
        return 'Workshop';
      case ClassCategory.wellness:
        return 'Wellness';
    }
  }

  String _getDifficultyText(ClassDifficulty difficulty) {
    switch (difficulty) {
      case ClassDifficulty.beginner:
        return 'Başlangıç';
      case ClassDifficulty.intermediate:
        return 'Orta';
      case ClassDifficulty.advanced:
        return 'İleri';
    }
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final ValueChanged<DateTime?> onDateSelected;

  const _DateField({
    required this.label,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        onDateSelected(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          date != null
              ? '${date!.day}/${date!.month}/${date!.year}'
              : 'Seçiniz',
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }
}
