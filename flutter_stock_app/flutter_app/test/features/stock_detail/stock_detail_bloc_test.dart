import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_research_app/core/api/api_exception.dart';
import 'package:stock_research_app/core/api/stock_repository.dart';
import 'package:stock_research_app/core/storage/watchlist_storage.dart';
import 'package:stock_research_app/features/stock_detail/bloc/stock_detail_bloc.dart';
import 'package:stock_research_app/features/stock_detail/bloc/stock_detail_event.dart';
import 'package:stock_research_app/features/stock_detail/bloc/stock_detail_state.dart';
import 'package:stock_research_app/shared/models/candle.dart';
import 'package:stock_research_app/shared/models/stock.dart';

class MockStockRepository extends Mock implements StockRepository {}

class MockWatchlistStorage extends Mock implements WatchlistStorage {}

void main() {
  late MockStockRepository repository;
  late MockWatchlistStorage watchlistStorage;

  const reliance = Stock(
    id: '1',
    ticker: 'RELIANCE',
    name: 'Reliance Industries',
    exchange: 'NSE',
  );

  final latestCandle = Candle(
    date: DateTime(2025, 1, 15),
    open: 2450,
    high: 2480,
    low: 2430,
    close: 2465,
    volume: 1000000,
    prevClose: 2440,
    changePct: 1.02,
  );

  final sampleCandles = [
    Candle(
      date: DateTime(2025, 1, 14),
      open: 2400,
      high: 2450,
      low: 2390,
      close: 2440,
      volume: 900000,
    ),
    latestCandle,
  ];

  setUp(() {
    repository = MockStockRepository();
    watchlistStorage = MockWatchlistStorage();
  });

  group('StockDetailBloc', () {
    blocTest<StockDetailBloc, StockDetailState>(
      'loads stock profile, latest candle, watchlist status, then candles',
      setUp: () {
        when(
          () => repository.getStock('RELIANCE', exchange: 'NSE'),
        ).thenAnswer((_) async => reliance);
        when(
          () => repository.getLatestCandle('RELIANCE', exchange: 'NSE'),
        ).thenAnswer((_) async => latestCandle);
        when(
          () => watchlistStorage.contains('RELIANCE'),
        ).thenAnswer((_) async => false);
        when(
          () => repository.getOhlcv(
            ticker: 'RELIANCE',
            exchange: 'NSE',
            fromDate: any(named: 'fromDate'),
            toDate: any(named: 'toDate'),
          ),
        ).thenAnswer((_) async => sampleCandles);
      },
      build: () => StockDetailBloc(
        repository: repository,
        watchlistStorage: watchlistStorage,
      ),
      act: (bloc) => bloc.add(
        const StockDetailRequested(ticker: 'RELIANCE', exchange: 'NSE'),
      ),
      expect: () => [
        const StockDetailState(status: StockDetailStatus.loading),
        StockDetailState(
          status: StockDetailStatus.loading,
          stock: reliance,
          latestCandle: latestCandle,
          isInWatchlist: false,
        ),
        StockDetailState(
          status: StockDetailStatus.success,
          stock: reliance,
          latestCandle: latestCandle,
          isInWatchlist: false,
          candles: sampleCandles,
        ),
      ],
    );

    blocTest<StockDetailBloc, StockDetailState>(
      'emits failure when getStock throws',
      setUp: () {
        when(
          () => repository.getStock('RELIANCE', exchange: 'NSE'),
        ).thenThrow(const NotFoundException('Stock not found', 'STOCK_NOT_FOUND'));
      },
      build: () => StockDetailBloc(
        repository: repository,
        watchlistStorage: watchlistStorage,
      ),
      act: (bloc) => bloc.add(
        const StockDetailRequested(ticker: 'RELIANCE', exchange: 'NSE'),
      ),
      expect: () => [
        const StockDetailState(status: StockDetailStatus.loading),
        const StockDetailState(
          status: StockDetailStatus.failure,
          errorMessage: 'Stock not found',
        ),
      ],
    );

    blocTest<StockDetailBloc, StockDetailState>(
      'StockDetailWatchlistToggled adds ticker when not currently watched',
      setUp: () {
        when(
          () => repository.getStock('RELIANCE', exchange: 'NSE'),
        ).thenAnswer((_) async => reliance);
        when(
          () => repository.getLatestCandle('RELIANCE', exchange: 'NSE'),
        ).thenAnswer((_) async => null);
        when(
          () => watchlistStorage.contains('RELIANCE'),
        ).thenAnswer((_) async => false);
        when(
          () => repository.getOhlcv(
            ticker: 'RELIANCE',
            exchange: 'NSE',
            fromDate: any(named: 'fromDate'),
            toDate: any(named: 'toDate'),
          ),
        ).thenAnswer((_) async => []);
        when(() => watchlistStorage.add('RELIANCE')).thenAnswer((_) async {});
      },
      build: () => StockDetailBloc(
        repository: repository,
        watchlistStorage: watchlistStorage,
      ),
      // The bloc tracks the active ticker via an internal field that is
      // only populated when handling StockDetailRequested — seeding the
      // state directly would skip that, so the toggle test instead drives
      // the bloc through a real Requested event first, then the toggle.
      act: (bloc) async {
        bloc.add(
          const StockDetailRequested(ticker: 'RELIANCE', exchange: 'NSE'),
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const StockDetailWatchlistToggled());
      },
      verify: (_) {
        verify(() => watchlistStorage.add('RELIANCE')).called(1);
      },
    );
  });
}
