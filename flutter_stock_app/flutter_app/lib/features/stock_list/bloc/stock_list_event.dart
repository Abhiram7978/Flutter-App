import 'package:equatable/equatable.dart';

sealed class StockListEvent extends Equatable {
  const StockListEvent();

  @override
  List<Object?> get props => [];
}

/// Initial load or pull-to-refresh of the stock list.
final class StockListRequested extends StockListEvent {
  const StockListRequested({this.universe});

  final String? universe;

  @override
  List<Object?> get props => [universe];
}

/// User switched the universe filter (e.g. All / Nifty50 / Nifty500).
final class StockListUniverseChanged extends StockListEvent {
  const StockListUniverseChanged(this.universe);

  final String? universe;

  @override
  List<Object?> get props => [universe];
}

/// User typed into the search box. The Bloc debounces this internally.
final class StockListSearchChanged extends StockListEvent {
  const StockListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// User scrolled near the end of the list — load the next page.
final class StockListMoreRequested extends StockListEvent {
  const StockListMoreRequested();
}
