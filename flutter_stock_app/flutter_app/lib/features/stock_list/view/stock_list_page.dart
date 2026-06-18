import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/stock_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../stock_detail/view/stock_detail_page.dart';
import '../bloc/stock_list_bloc.dart';
import '../bloc/stock_list_event.dart';
import '../bloc/stock_list_state.dart';
import '../widgets/stock_list_tile.dart';
import '../widgets/universe_filter_bar.dart';

class StockListPage extends StatelessWidget {
  const StockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StockListBloc(repository: StockRepository())
        ..add(const StockListRequested()),
      child: const _StockListView(),
    );
  }
}

class _StockListView extends StatefulWidget {
  const _StockListView();

  @override
  State<_StockListView> createState() => _StockListViewState();
}

class _StockListViewState extends State<_StockListView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<StockListBloc>().add(const StockListMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stocks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => context
                  .read<StockListBloc>()
                  .add(StockListSearchChanged(value)),
              decoration: const InputDecoration(
                hintText: 'Search by ticker or company name',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          BlocBuilder<StockListBloc, StockListState>(
            buildWhen: (previous, current) =>
                previous.universe != current.universe ||
                previous.isSearching != current.isSearching,
            builder: (context, state) {
              if (state.isSearching) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: UniverseFilterBar(
                  selected: state.universe,
                  onSelected: (universe) => context
                      .read<StockListBloc>()
                      .add(StockListUniverseChanged(universe)),
                ),
              );
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<StockListBloc, StockListState>(
              builder: (context, state) {
                switch (state.status) {
                  case StockListStatus.initial:
                  case StockListStatus.loading:
                    return const Center(child: CircularProgressIndicator());

                  case StockListStatus.failure:
                    return _ErrorView(
                      message: state.errorMessage ?? 'Something went wrong.',
                      onRetry: () => context
                          .read<StockListBloc>()
                          .add(StockListRequested(universe: state.universe)),
                    );

                  case StockListStatus.success:
                  case StockListStatus.loadingMore:
                    if (state.stocks.isEmpty) {
                      return const _EmptyView();
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<StockListBloc>().add(
                              StockListRequested(universe: state.universe),
                            );
                        await Future<void>.delayed(
                          const Duration(milliseconds: 400),
                        );
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount: state.stocks.length +
                            (state.status == StockListStatus.loadingMore
                                ? 1
                                : 0),
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 68),
                        itemBuilder: (context, index) {
                          if (index >= state.stocks.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          final stock = state.stocks[index];
                          return StockListTile(
                            stock: stock,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => StockDetailPage(
                                  ticker: stock.ticker,
                                  exchange: stock.exchange,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'No stocks found',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
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
