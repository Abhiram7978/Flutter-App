import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Horizontal chip row for filtering the stock list by universe.
/// `null` represents "All".
class UniverseFilterBar extends StatelessWidget {
  const UniverseFilterBar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;

  static const List<(String? value, String label)> _options = [
    (null, 'All'),
    ('nifty50', 'Nifty 50'),
    ('nifty500', 'Nifty 500'),
    ('sensex', 'Sensex'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label) = _options[index];
          final isSelected = selected == value;
          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(value),
            selectedColor: AppColors.primary.withOpacity(0.2),
            backgroundColor: AppColors.surfaceVariant,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}
