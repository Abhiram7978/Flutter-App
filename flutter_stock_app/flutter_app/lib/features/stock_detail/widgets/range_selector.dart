import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../bloc/stock_detail_state.dart';

class RangeSelector extends StatelessWidget {
  const RangeSelector({
    required this.selectedDays,
    required this.onChanged,
    super.key,
  });

  final int selectedDays;
  final ValueChanged<int> onChanged;

  String _label(int days) {
    switch (days) {
      case 30:
        return '1M';
      case 90:
        return '3M';
      case 180:
        return '6M';
      case 365:
        return '1Y';
      default:
        return '${days}D';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final days in stockDetailRangeOptions)
          _RangeButton(
            label: _label(days),
            isSelected: days == selectedDays,
            onTap: () => onChanged(days),
          ),
      ],
    );
  }
}

class _RangeButton extends StatelessWidget {
  const _RangeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.15) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
