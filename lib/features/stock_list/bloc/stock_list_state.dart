import 'package:equatable/equatable.dart';

import '../../../shared/models/stock.dart';

enum StockListStatus { initial, loading, success, failure, loadingMore }

class StockListState extends Equatable {
  const StockListState({
    this.status = StockListStatus.initial,
    this.stocks = const <Stock>[],
    this.universe,
    this.searchQuery = '',
    this.errorMessage,
    this.hasReachedMax = false,
  });

  final StockListStatus status;
  final List<Stock> stocks;
  final String? universe;
  final String searchQuery;
  final String? errorMessage;
  final bool hasReachedMax;

  bool get isSearching => searchQuery.trim().isNotEmpty;

  StockListState copyWith({
    StockListStatus? status,
    List<Stock>? stocks,
    String? universe,
    bool clearUniverse = false,
    String? searchQuery,
    String? errorMessage,
    bool? hasReachedMax,
  }) {
    return StockListState(
      status: status ?? this.status,
      stocks: stocks ?? this.stocks,
      universe: clearUniverse ? null : (universe ?? this.universe),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
        status,
        stocks,
        universe,
        searchQuery,
        errorMessage,
        hasReachedMax,
      ];
}
