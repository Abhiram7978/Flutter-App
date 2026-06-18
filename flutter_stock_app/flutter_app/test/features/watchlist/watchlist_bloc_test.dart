import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stock_research_app/core/api/api_exception.dart';
import 'package:stock_research_app/core/api/stock_repository.dart';
import 'package:stock_research_app/core/storage/watchlist_storage.dart';
import 'package:stock_research_app/features/watchlist/bloc/watchlist_bloc.dart';
import 'package:stock_research_app/features/watchlist/bloc/watchlist_event.dart';
import 'package:stock_research_app/features/watchlist/bloc/watchlist_state.dart';
import 'package:stock_research_app/shared/models/candle.dart';
import 'package:stock_research_app/shared/models/stock.dart';

class MockStockRepository extends Mock implements StockRepository {}

class MockWatchlistStorage extends Mock implements WatchlistStorage {}

void main() {
  late MockStockRepository repository;
  late MockWatchlistStorage storage;

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

  final relianceCandle = Candle(
    date: DateTime(2025, 1, 15),
    open: 2450,
    high: 2480,
    low: 2430,
    close: 2465,
    volume: 1000000,
    changePct: 1.02,
  );

  setUp(() {
    repository = MockStockRepository();
    storage = MockWatchlistStorage();
  });

  group('WatchlistBloc', () {
    blocTest<WatchlistBloc, WatchlistState>(
      'emits [loading, success] with empty entries when storage has no tickers',
      setUp: () {
        when(() => storage.getTickers()).thenAnswer((_) async => <String>{});
      },
      build: () => WatchlistBloc(repository: repository, storage: storage),
      act: (bloc) => bloc.add(const WatchlistRequested()),
      expect: () => [
        const WatchlistState(status: WatchlistStatus.loading),
        const WatchlistState(status: WatchlistStatus.success, entries: []),
      ],
      verify: (_) {
        verifyNever(() => repository.getStock(any()));
      },
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'fetches stock + latest candle for each stored ticker',
      setUp: () {
        when(() => storage.getTickers())
            .thenAnswer((_) async => {'RELIANCE'});
        when(() => repository.getStock('RELIANCE'))
            .thenAnswer((_) async => reliance);
        when(() => repository.getLatestCandle('RELIANCE'))
            .thenAnswer((_) async => relianceCandle);
      },
      build: () => WatchlistBloc(repository: repository, storage: storage),
      act: (bloc) => bloc.add(const WatchlistRequested()),
      expect: () => [
        const WatchlistState(status: WatchlistStatus.loading),
        WatchlistState(
          status: WatchlistStatus.success,
          entries: [
            WatchlistEntry(stock: reliance, latestCandle: relianceCandle),
          ],
        ),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits failure when fetching a watched stock throws',
      setUp: () {
        when(() => storage.getTickers())
            .thenAnswer((_) async => {'RELIANCE'});
        when(() => repository.getStock('RELIANCE'))
            .thenThrow(const NetworkException());
      },
      build: () => WatchlistBloc(repository: repository, storage: storage),
      act: (bloc) => bloc.add(const WatchlistRequested()),
      expect: () => [
        const WatchlistState(status: WatchlistStatus.loading),
        const WatchlistState(
          status: WatchlistStatus.failure,
          errorMessage: 'Could not reach the server. Check your connection.',
        ),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'WatchlistItemRemoved removes the entry from storage and state',
      seed: () => WatchlistState(
        status: WatchlistStatus.success,
        entries: [
          WatchlistEntry(stock: reliance, latestCandle: relianceCandle),
          const WatchlistEntry(stock: tcs),
        ],
      ),
      setUp: () {
        when(() => storage.remove('RELIANCE')).thenAnswer((_) async {});
      },
      build: () => WatchlistBloc(repository: repository, storage: storage),
      act: (bloc) => bloc.add(const WatchlistItemRemoved('RELIANCE')),
      expect: () => [
        WatchlistState(
          status: WatchlistStatus.success,
          entries: const [WatchlistEntry(stock: tcs)],
        ),
      ],
      verify: (_) {
        verify(() => storage.remove('RELIANCE')).called(1);
      },
    );
  });
}
