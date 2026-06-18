import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/stock_repository.dart';
import '../../../core/storage/watchlist_storage.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc({
    required StockRepository repository,
    required WatchlistStorage storage,
  })  : _repository = repository,
        _storage = storage,
        super(const WatchlistState()) {
    on<WatchlistRequested>(_onRequested);
    on<WatchlistItemRemoved>(_onItemRemoved);
  }

  final StockRepository _repository;
  final WatchlistStorage _storage;

  Future<void> _onRequested(
    WatchlistRequested event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));

    final tickers = await _storage.getTickers();
    if (tickers.isEmpty) {
      emit(state.copyWith(status: WatchlistStatus.success, entries: const []));
      return;
    }

    try {
      final entries = <WatchlistEntry>[];
      // Sequential rather than Future.wait: keeps this simple and avoids
      // hammering the backend with N simultaneous requests for what is
      // expected to be a short personal watchlist, not hundreds of tickers.
      for (final ticker in tickers) {
        final stock = await _repository.getStock(ticker);
        final latest = await _repository.getLatestCandle(ticker);
        entries.add(WatchlistEntry(stock: stock, latestCandle: latest));
      }
      emit(state.copyWith(status: WatchlistStatus.success, entries: entries));
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: WatchlistStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _onItemRemoved(
    WatchlistItemRemoved event,
    Emitter<WatchlistState> emit,
  ) async {
    await _storage.remove(event.ticker);
    final updated = state.entries
        .where((e) => e.stock.ticker != event.ticker)
        .toList();
    emit(state.copyWith(entries: updated));
  }
}
