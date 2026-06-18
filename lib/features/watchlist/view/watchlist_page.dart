import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/stock_repository.dart';
import '../../../core/storage/watchlist_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../stock_detail/view/stock_detail_page.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';
import '../widgets/watchlist_tile.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WatchlistBloc(
        repository: StockRepository(),
        storage: WatchlistStorage(),
      )..add(const WatchlistRequested()),
      child: const _WatchlistView(),
    );
  }
}

class _WatchlistView extends StatelessWidget {
  const _WatchlistView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          switch (state.status) {
            case WatchlistStatus.initial:
            case WatchlistStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case WatchlistStatus.failure:
              return _ErrorView(
                message: state.errorMessage ?? 'Failed to load watchlist.',
                onRetry: () => context
                    .read<WatchlistBloc>()
                    .add(const WatchlistRequested()),
              );

            case WatchlistStatus.success:
              if (state.entries.isEmpty) {
                return const _EmptyWatchlist();
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<WatchlistBloc>().add(const WatchlistRequested());
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                },
                child: ListView.separated(
                  itemCount: state.entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = state.entries[index];
                    return WatchlistTile(
                      entry: entry,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => StockDetailPage(
                            ticker: entry.stock.ticker,
                            exchange: entry.stock.exchange,
                          ),
                        ),
                      ),
                      onRemove: () => context
                          .read<WatchlistBloc>()
                          .add(WatchlistItemRemoved(entry.stock.ticker)),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}

class _EmptyWatchlist extends StatelessWidget {
  const _EmptyWatchlist();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'Your watchlist is empty',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            SizedBox(height: 4),
            Text(
              'Tap the bookmark icon on any stock to add it here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
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
