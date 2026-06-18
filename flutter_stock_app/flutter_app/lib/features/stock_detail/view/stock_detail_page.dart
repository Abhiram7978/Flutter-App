import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/stock_repository.dart';
import '../../../core/storage/watchlist_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/stock.dart';
import '../bloc/stock_detail_bloc.dart';
import '../bloc/stock_detail_event.dart';
import '../bloc/stock_detail_state.dart';
import '../widgets/price_chart.dart';
import '../widgets/price_header.dart';
import '../widgets/range_selector.dart';

class StockDetailPage extends StatelessWidget {
  const StockDetailPage({
    required this.ticker,
    required this.exchange,
    super.key,
  });

  final String ticker;
  final String exchange;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockDetailBloc(
        repository: StockRepository(),
        watchlistStorage: WatchlistStorage(),
      )..add(StockDetailRequested(ticker: ticker, exchange: exchange)),
      child: _StockDetailView(ticker: ticker),
    );
  }
}

class _StockDetailView extends StatelessWidget {
  const _StockDetailView({required this.ticker});

  final String ticker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ticker),
        actions: [
          BlocBuilder<StockDetailBloc, StockDetailState>(
            buildWhen: (previous, current) =>
                previous.isInWatchlist != current.isInWatchlist,
            builder: (context, state) {
              return IconButton(
                icon: Icon(
                  state.isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                  color: state.isInWatchlist
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                tooltip: state.isInWatchlist
                    ? 'Remove from watchlist'
                    : 'Add to watchlist',
                onPressed: () => context
                    .read<StockDetailBloc>()
                    .add(const StockDetailWatchlistToggled()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<StockDetailBloc, StockDetailState>(
        builder: (context, state) {
          if (state.status == StockDetailStatus.failure &&
              state.stock == null) {
            return _ErrorView(
              message: state.errorMessage ?? 'Failed to load stock.',
              onRetry: () => context.read<StockDetailBloc>().add(
                    StockDetailRequested(
                      ticker: ticker,
                      exchange: state.stock?.exchange ?? 'NSE',
                    ),
                  ),
            );
          }

          if (state.stock == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final stock = state.stock!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                stock.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              PriceHeader(candle: state.latestCandle),
              const SizedBox(height: 24),
              if (state.status == StockDetailStatus.loading &&
                  state.candles.isEmpty)
                const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                PriceChart(candles: state.candles),
              const SizedBox(height: 12),
              RangeSelector(
                selectedDays: state.rangeDays,
                onChanged: (days) => context
                    .read<StockDetailBloc>()
                    .add(StockDetailRangeChanged(days)),
              ),
              const SizedBox(height: 24),
              _StockInfoCard(stock: stock),
            ],
          );
        },
      ),
    );
  }
}

class _StockInfoCard extends StatelessWidget {
  const _StockInfoCard({required this.stock});

  final Stock stock;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Exchange', value: stock.exchange),
            if (stock.sector != null)
              _InfoRow(label: 'Sector', value: stock.sector!),
            _InfoRow(
              label: 'F&O Enabled',
              value: stock.isFo ? 'Yes' : 'No',
            ),
            if (stock.latestDataDate != null)
              _InfoRow(
                label: 'Latest Data',
                value: stock.latestDataDate!,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
