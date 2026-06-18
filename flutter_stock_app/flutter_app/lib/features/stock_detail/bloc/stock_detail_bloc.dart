import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/stock_repository.dart';
import '../../../core/storage/watchlist_storage.dart';
import 'stock_detail_event.dart';
import 'stock_detail_state.dart';

class StockDetailBloc extends Bloc<StockDetailEvent, StockDetailState> {
  StockDetailBloc({
    required StockRepository repository,
    required WatchlistStorage watchlistStorage,
  })  : _repository = repository,
        _watchlistStorage = watchlistStorage,
        super(const StockDetailState()) {
    on<StockDetailRequested>(_onRequested);
    on<StockDetailRangeChanged>(_onRangeChanged);
    on<StockDetailWatchlistToggled>(_onWatchlistToggled);
  }

  final StockRepository _repository;
  final WatchlistStorage _watchlistStorage;

  String? _ticker;
  String? _exchange;

  Future<void> _onRequested(
    StockDetailRequested event,
    Emitter<StockDetailState> emit,
  ) async {
    _ticker = event.ticker;
    _exchange = event.exchange;
    emit(state.copyWith(status: StockDetailStatus.loading));
    await _loadAll(emit);
  }

  Future<void> _onRangeChanged(
    StockDetailRangeChanged event,
    Emitter<StockDetailState> emit,
  ) async {
    if (_ticker == null) return;
    emit(state.copyWith(rangeDays: event.rangeDays, status: StockDetailStatus.loading));
    await _loadCandles(emit, rangeDays: event.rangeDays);
  }

  Future<void> _onWatchlistToggled(
    StockDetailWatchlistToggled event,
    Emitter<StockDetailState> emit,
  ) async {
    final ticker = _ticker;
    if (ticker == null) return;

    if (state.isInWatchlist) {
      await _watchlistStorage.remove(ticker);
    } else {
      await _watchlistStorage.add(ticker);
    }
    emit(state.copyWith(isInWatchlist: !state.isInWatchlist));
  }

  Future<void> _loadAll(Emitter<StockDetailState> emit) async {
    final ticker = _ticker;
    final exchange = _exchange;
    if (ticker == null || exchange == null) return;

    try {
      final stockFuture = _repository.getStock(ticker, exchange: exchange);
      final latestFuture = _repository.getLatestCandle(ticker, exchange: exchange);
      final watchlistFuture = _watchlistStorage.contains(ticker);

      final stock = await stockFuture;
      final latest = await latestFuture;
      final inWatchlist = await watchlistFuture;

      emit(
        state.copyWith(
          stock: stock,
          latestCandle: latest,
          isInWatchlist: inWatchlist,
        ),
      );

      await _loadCandles(emit, rangeDays: state.rangeDays);
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: StockDetailStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _loadCandles(
    Emitter<StockDetailState> emit, {
    required int rangeDays,
  }) async {
    final ticker = _ticker;
    final exchange = _exchange;
    if (ticker == null || exchange == null) return;

    final toDate = DateTime.now().subtract(const Duration(days: 1));
    final fromDate = toDate.subtract(Duration(days: rangeDays));

    try {
      final candles = await _repository.getOhlcv(
        ticker: ticker,
        exchange: exchange,
        fromDate: fromDate,
        toDate: toDate,
      );
      emit(
        state.copyWith(
          status: StockDetailStatus.success,
          candles: candles,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: StockDetailStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }
}
