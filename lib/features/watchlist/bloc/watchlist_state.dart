import 'package:equatable/equatable.dart';

import '../../../shared/models/candle.dart';
import '../../../shared/models/stock.dart';

enum WatchlistStatus { initial, loading, success, failure }

/// A watchlist entry pairs the stock profile with its latest candle so
/// the list view can show current price/change without a second screen.
class WatchlistEntry extends Equatable {
  const WatchlistEntry({required this.stock, this.latestCandle});

  final Stock stock;
  final Candle? latestCandle;

  @override
  List<Object?> get props => [stock, latestCandle];
}

class WatchlistState extends Equatable {
  const WatchlistState({
    this.status = WatchlistStatus.initial,
    this.entries = const <WatchlistEntry>[],
    this.errorMessage,
  });

  final WatchlistStatus status;
  final List<WatchlistEntry> entries;
  final String? errorMessage;

  WatchlistState copyWith({
    WatchlistStatus? status,
    List<WatchlistEntry>? entries,
    String? errorMessage,
  }) {
    return WatchlistState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, entries, errorMessage];
}
