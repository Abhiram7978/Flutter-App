import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/candle.dart';

class PriceHeader extends StatelessWidget {
  const PriceHeader({this.candle, super.key});

  final Candle? candle;

  @override
  Widget build(BuildContext context) {
    final c = candle;
    if (c == null) {
      return const SizedBox(
        height: 56,
        child: Center(
          child: Text(
            'No recent data',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final changeColor = AppTheme.colorForChange(c.changePct);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          Formatters.price(c.close),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                c.changePct != null && c.changePct! >= 0
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
                color: changeColor,
                size: 20,
              ),
              Text(
                Formatters.changePct(c.changePct),
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        if (c.isFlagged) ...[
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Tooltip(
              message: 'This data point was flagged by automated '
                  'validation (status: ${c.validationStatus}) and may '
                  'be less reliable.',
              child: const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
