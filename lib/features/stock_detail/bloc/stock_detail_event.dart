import 'package:equatable/equatable.dart';

sealed class StockDetailEvent extends Equatable {
  const StockDetailEvent();

  @override
  List<Object?> get props => [];
}

final class StockDetailRequested extends StockDetailEvent {
  const StockDetailRequested({required this.ticker, required this.exchange});

  final String ticker;
  final String exchange;

  @override
  List<Object?> get props => [ticker, exchange];
}

/// User picked a different chart range (e.g. 1M / 3M / 6M / 1Y).
final class StockDetailRangeChanged extends StockDetailEvent {
  const StockDetailRangeChanged(this.rangeDays);

  final int rangeDays;

  @override
  List<Object?> get props => [rangeDays];
}

final class StockDetailWatchlistToggled extends StockDetailEvent {
  const StockDetailWatchlistToggled();
}
