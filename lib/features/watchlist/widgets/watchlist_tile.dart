import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../bloc/watchlist_state.dart';

class WatchlistTile extends StatelessWidget {
  const WatchlistTile({
    required this.entry,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final WatchlistEntry entry;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final candle = entry.latestCandle;
    final changeColor = AppTheme.colorForChange(candle?.changePct);

    return Dismissible(
      key: ValueKey(entry.stock.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(),
      background: Container(
        color: AppColors.bearish.withOpacity(0.15),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: AppColors.bearish),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          entry.stock.ticker,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          entry.stock.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: candle == null
            ? const Text('—', style: TextStyle(color: AppColors.textSecondary))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Formatters.price(candle.close),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    Formatters.changePct(candle.changePct),
                    style: TextStyle(color: changeColor, fontSize: 13),
                  ),
                ],
              ),
      ),
    );
  }
}
