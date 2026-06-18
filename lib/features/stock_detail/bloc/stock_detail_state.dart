import 'package:equatable/equatable.dart';

import '../../../shared/models/candle.dart';
import '../../../shared/models/stock.dart';

enum StockDetailStatus { initial, loading, success, failure }

/// Chart range presets, in calendar days, matching common retail trading
/// app conventions (1M / 3M / 6M / 1Y). The backend caps any single
/// request at 365 days, so 1Y is the maximum supported here.
const List<int> stockDetailRangeOptions = [30, 90, 180, 365];

class StockDetailState extends Equatable {
  const StockDetailState({
    this.status = StockDetailStatus.initial,
    this.stock,
    this.candles = const <Candle>[],
    this.latestCandle,
    this.rangeDays = 90,
    this.isInWatchlist = false,
    this.errorMessage,
  });

  final StockDetailStatus status;
  final Stock? stock;
  final List<Candle> candles;
  final Candle? latestCandle;
  final int rangeDays;
  final bool isInWatchlist;
  final String? errorMessage;

  StockDetailState copyWith({
    StockDetailStatus? status,
    Stock? stock,
    List<Candle>? candles,
    Candle? latestCandle,
    int? rangeDays,
    bool? isInWatchlist,
    String? errorMessage,
  }) {
    return StockDetailState(
      status: status ?? this.status,
      stock: stock ?? this.stock,
      candles: candles ?? this.candles,
      latestCandle: latestCandle ?? this.latestCandle,
      rangeDays: rangeDays ?? this.rangeDays,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        stock,
        candles,
        latestCandle,
        rangeDays,
        isInWatchlist,
        errorMessage,
      ];
}
