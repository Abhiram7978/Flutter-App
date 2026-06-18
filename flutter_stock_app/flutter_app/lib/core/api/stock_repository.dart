import 'package:intl/intl.dart';

import '../../shared/models/candle.dart';
import '../../shared/models/stock.dart';
import 'api_client.dart';

/// Single point of contact between the app's Bloc layer and the backend
/// REST API for everything stock/market-data related.
///
/// Endpoints covered (see backend app/api/v1/routers/market_data.py):
///   GET /api/v1/stocks
///   GET /api/v1/stocks/search
///   GET /api/v1/stocks/{ticker}
///   GET /api/v1/stocks/{ticker}/ohlcv
///   GET /api/v1/stocks/{ticker}/latest
class StockRepository {
  StockRepository({ApiClient? apiClient}) : _client = apiClient ?? ApiClient();

  final ApiClient _client;

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// List active stocks, optionally filtered by universe (nifty50/nifty500)
  /// and/or exchange (NSE/BSE).
  Future<List<Stock>> listStocks({
    String? universe,
    String? exchange,
    int limit = 50,
    int offset = 0,
  }) async {
    final json = await _client.get(
      '/api/v1/stocks',
      queryParameters: {
        if (universe != null) 'universe': universe,
        if (exchange != null) 'exchange': exchange,
        'limit': limit,
        'offset': offset,
      },
    );
    final stocks = (json['stocks'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(Stock.fromListJson)
        .toList();
    return stocks;
  }

  /// Search stocks by ticker or company name prefix.
  Future<List<Stock>> searchStocks(String query, {int limit = 10}) async {
    if (query.trim().isEmpty) return const [];
    final json = await _client.get(
      '/api/v1/stocks/search',
      queryParameters: {'q': query, 'limit': limit},
    );
    final results = (json['results'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(Stock.fromListJson)
        .toList();
    return results;
  }

  /// Fetch the full profile for one stock.
  Future<Stock> getStock(String ticker, {String exchange = 'NSE'}) async {
    final json = await _client.get(
      '/api/v1/stocks/$ticker',
      queryParameters: {'exchange': exchange},
    );
    return Stock.fromProfileJson(json);
  }

  /// Fetch historical daily candles for a stock.
  ///
  /// The backend enforces a maximum 365-day range per request — callers
  /// requesting longer history should paginate via [fromDate]/[toDate].
  Future<List<Candle>> getOhlcv({
    required String ticker,
    required DateTime fromDate,
    required DateTime toDate,
    String exchange = 'NSE',
  }) async {
    final json = await _client.get(
      '/api/v1/stocks/$ticker/ohlcv',
      queryParameters: {
        'exchange': exchange,
        'from_date': _dateFormat.format(fromDate),
        'to_date': _dateFormat.format(toDate),
      },
    );
    final candles = (json['candles'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(Candle.fromJson)
        .toList();
    // Backend returns ascending by date already, but sort defensively —
    // chart widgets assume strictly ascending order.
    candles.sort((a, b) => a.date.compareTo(b.date));
    return candles;
  }

  /// Fetch the most recent candle for a stock.
  Future<Candle?> getLatestCandle(
    String ticker, {
    String exchange = 'NSE',
  }) async {
    final json = await _client.get(
      '/api/v1/stocks/$ticker/latest',
      queryParameters: {'exchange': exchange},
    );
    if (json.isEmpty) return null;
    return Candle.fromJson(json);
  }
}
