import 'package:equatable/equatable.dart';

sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

final class WatchlistRequested extends WatchlistEvent {
  const WatchlistRequested();
}

final class WatchlistItemRemoved extends WatchlistEvent {
  const WatchlistItemRemoved(this.ticker);

  final String ticker;

  @override
  List<Object?> get props => [ticker];
}
