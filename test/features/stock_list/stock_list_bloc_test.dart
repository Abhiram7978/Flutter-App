import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_research_app/core/api/api_exception.dart';
import 'package:stock_research_app/core/api/stock_repository.dart';
import 'package:stock_research_app/features/stock_list/bloc/stock_list_bloc.dart';
import 'package:stock_research_app/features/stock_list/bloc/stock_list_event.dart';
import 'package:stock_research_app/features/stock_list/bloc/stock_list_state.dart';
import 'package:stock_research_app/shared/models/stock.dart';

class MockStockRepository extends Mock implements StockRepository {}

void main() {
  late MockStockRepository repository;

  setUp(() {
    repository = MockStockRepository();
  });

  const reliance = Stock(
    id: '1',
    ticker: 'RELIANCE',
    name: 'Reliance Industries',
    exchange: 'NSE',
  );
  const tcs = Stock(
    id: '2',
    ticker: 'TCS',
    name: 'Tata Consultancy Services',
    exchange: 'NSE',
  );

  group('StockListBloc', () {
    blocTest<StockListBloc, StockListState>(
      'emits [loading, success] when StockListRequested succeeds',
      setUp: () {
        when(
          () => repository.listStocks(
            universe: any(named: 'universe'),
            exchange: any(named: 'exchange'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [reliance, tcs]);
      },
      build: () => StockListBloc(repository: repository),
      act: (bloc) => bloc.add(const StockListRequested()),
      expect: () => [
        const StockListState(status: StockListStatus.loading),
        StockListState(
          status: StockListStatus.success,
          stocks: [reliance, tcs],
          hasReachedMax: true, // 2 results < page size of 50
        ),
      ],
    );

    blocTest<StockListBloc, StockListState>(
      'emits [loading, failure] when the repository throws',
      setUp: () {
        when(
          () => repository.listStocks(
            universe: any(named: 'universe'),
            exchange: any(named: 'exchange'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenThrow(const NetworkException());
      },
      build: () => StockListBloc(repository: repository),
      act: (bloc) => bloc.add(const StockListRequested()),
      expect: () => [
        const StockListState(status: StockListStatus.loading),
        const StockListState(
          status: StockListStatus.failure,
          errorMessage: 'Could not reach the server. Check your connection.',
        ),
      ],
    );

    blocTest<StockListBloc, StockListState>(
      'StockListUniverseChanged refetches with the new universe filter',
      setUp: () {
        when(
          () => repository.listStocks(
            universe: 'nifty50',
            exchange: any(named: 'exchange'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [reliance]);
      },
      build: () => StockListBloc(repository: repository),
      act: (bloc) => bloc.add(const StockListUniverseChanged('nifty50')),
      expect: () => [
        const StockListState(
          status: StockListStatus.loading,
          universe: 'nifty50',
        ),
        const StockListState(
          status: StockListStatus.success,
          universe: 'nifty50',
          stocks: [reliance],
          hasReachedMax: true,
        ),
      ],
      verify: (_) {
        verify(
          () => repository.listStocks(
            universe: 'nifty50',
            exchange: any(named: 'exchange'),
            limit: any(named: 'limit'),
            offset: 0,
          ),
        ).called(1);
      },
    );

    blocTest<StockListBloc, StockListState>(
      'StockListSearchChanged with empty query falls back to listStocks',
      setUp: () {
        when(
          () => repository.listStocks(
            universe: any(named: 'universe'),
            exchange: any(named: 'exchange'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [reliance, tcs]);
      },
      build: () => StockListBloc(repository: repository),
      act: (bloc) => bloc.add(const StockListSearchChanged('')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        const StockListState(
          status: StockListStatus.loading,
          searchQuery: '',
        ),
        StockListState(
          status: StockListStatus.success,
          searchQuery: '',
          stocks: [reliance, tcs],
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<StockListBloc, StockListState>(
      'StockListSearchChanged with a query calls searchStocks, not listStocks',
      setUp: () {
        when(() => repository.searchStocks('RELI', limit: any(named: 'limit')))
            .thenAnswer((_) async => [reliance]);
      },
      build: () => StockListBloc(repository: repository),
      act: (bloc) => bloc.add(const StockListSearchChanged('RELI')),
      wait: const Duration(milliseconds: 400),
      expect: () => [
        const StockListState(
          status: StockListStatus.loading,
          searchQuery: 'RELI',
        ),
        const StockListState(
          status: StockListStatus.success,
          searchQuery: 'RELI',
          stocks: [reliance],
          hasReachedMax: true,
        ),
      ],
      verify: (_) {
        verify(() => repository.searchStocks('RELI', limit: any(named: 'limit')))
            .called(1);
        verifyNever(
          () => repository.listStocks(
            universe: any(named: 'universe'),
            exchange: any(named: 'exchange'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );

    blocTest<StockListBloc, StockListState>(
      'StockListMoreRequested appends the next page and respects hasReachedMax',
      seed: () => StockListState(
        status: StockListStatus.success,
        stocks: [reliance],
        hasReachedMax: false,
      ),
      setUp: () {
        when(
          () => repository.listStocks(
            universe: any(named: 'universe'),
            exchange: any(named: 'exchange'),
            limit: any(named: 'limit'),
            offset: 1,
          ),
        ).thenAnswer((_) async => [tcs]);
      },
      build: () => StockListBloc(repository: repository),
      act: (bloc) => bloc.add(const StockListMoreRequested()),
      expect: () => [
        StockListState(
          status: StockListStatus.loadingMore,
          stocks: [reliance],
        ),
        StockListState(
          status: StockListStatus.success,
          stocks: [reliance, tcs],
          hasReachedMax: true, // 1 result < page size of 50
        ),
      ],
    );

    blocTest<StockListBloc, StockListState>(
      'StockListMoreRequested does nothing when hasReachedMax is true',
      seed: () => StockListState(
        status: StockListStatus.success,
        stocks: [reliance],
        hasReachedMax: true,
      ),
      build: () => StockListBloc(repository: repository),
      act: (bloc) => bloc.add(const StockListMoreRequested()),
      expect: () => <StockListState>[],
      verify: (_) {
        verifyNever(
          () => repository.listStocks(
            universe: any(named: 'universe'),
            exchange: any(named: 'exchange'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        );
      },
    );
  });
}
