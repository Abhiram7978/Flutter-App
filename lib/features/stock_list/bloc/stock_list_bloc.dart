import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/stock_repository.dart';
import 'stock_list_event.dart';
import 'stock_list_state.dart';

const int _pageSize = 50;
const Duration _searchDebounce = Duration(milliseconds: 350);

class StockListBloc extends Bloc<StockListEvent, StockListState> {
  StockListBloc({required StockRepository repository})
      : _repository = repository,
        super(const StockListState()) {
    on<StockListRequested>(_onRequested);
    on<StockListUniverseChanged>(_onUniverseChanged);
    on<StockListSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) =>
          events.debounce(_searchDebounce).switchMap(mapper),
    );
    on<StockListMoreRequested>(_onMoreRequested);
  }

  final StockRepository _repository;

  Future<void> _onRequested(
    StockListRequested event,
    Emitter<StockListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StockListStatus.loading,
        universe: event.universe,
        clearUniverse: event.universe == null,
        searchQuery: '',
        hasReachedMax: false,
      ),
    );
    await _fetchFirstPage(universe: event.universe, emit: emit);
  }

  Future<void> _onUniverseChanged(
    StockListUniverseChanged event,
    Emitter<StockListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: StockListStatus.loading,
        universe: event.universe,
        clearUniverse: event.universe == null,
        hasReachedMax: false,
      ),
    );
    await _fetchFirstPage(universe: event.universe, emit: emit);
  }

  Future<void> _onSearchChanged(
    StockListSearchChanged event,
    Emitter<StockListState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(searchQuery: query, status: StockListStatus.loading));

    if (query.isEmpty) {
      await _fetchFirstPage(universe: state.universe, emit: emit);
      return;
    }

    try {
      final results = await _repository.searchStocks(query);
      emit(
        state.copyWith(
          status: StockListStatus.success,
          stocks: results,
          hasReachedMax: true, // search results are not paginated
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: StockListStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _onMoreRequested(
    StockListMoreRequested event,
    Emitter<StockListState> emit,
  ) async {
    if (state.hasReachedMax || state.isSearching) return;
    if (state.status == StockListStatus.loadingMore) return;

    emit(state.copyWith(status: StockListStatus.loadingMore));

    try {
      final nextPage = await _repository.listStocks(
        universe: state.universe,
        offset: state.stocks.length,
        limit: _pageSize,
      );
      emit(
        state.copyWith(
          status: StockListStatus.success,
          stocks: [...state.stocks, ...nextPage],
          hasReachedMax: nextPage.length < _pageSize,
        ),
      );
    } on ApiException catch (e) {
      // Keep existing stocks visible; surface the error without clearing
      // the list the user is currently scrolling.
      emit(
        state.copyWith(
          status: StockListStatus.success,
          errorMessage: e.message,
        ),
      );
    }
  }

  Future<void> _fetchFirstPage({
    required String? universe,
    required Emitter<StockListState> emit,
  }) async {
    try {
      final stocks = await _repository.listStocks(
        universe: universe,
        limit: _pageSize,
        offset: 0,
      );
      emit(
        state.copyWith(
          status: StockListStatus.success,
          stocks: stocks,
          hasReachedMax: stocks.length < _pageSize,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: StockListStatus.failure,
          errorMessage: e.message,
        ),
      );
    }
  }
}
