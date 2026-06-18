import 'package:equatable/equatable.dart';

/// Mirrors the stock summary shape from GET /api/v1/stocks
/// and the fuller profile shape from GET /api/v1/stocks/{ticker}.
///
/// Fields are nullable where the two backend endpoints differ in payload
/// shape (list endpoint returns a subset of profile endpoint fields).
class Stock extends Equatable {
  const Stock({
    required this.id,
    required this.ticker,
    required this.name,
    required this.exchange,
    this.sector,
    this.marketCap,
    this.inNifty50 = false,
    this.inNifty500 = false,
    this.isFo = false,
    this.isIndex = false,
    this.tickSize,
    this.circuitPct,
    this.latestDataDate,
  });

  factory Stock.fromListJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] as String,
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      exchange: json['exchange'] as String,
      sector: json['sector'] as String?,
      marketCap: json['market_cap'] as String?,
      inNifty50: json['in_nifty50'] as bool? ?? false,
      inNifty500: json['in_nifty500'] as bool? ?? false,
      isFo: json['is_fo'] as bool? ?? false,
    );
  }

  factory Stock.fromProfileJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'] as String,
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      exchange: json['exchange'] as String,
      sector: json['sector'] as String?,
      marketCap: json['market_cap'] as String?,
      inNifty50: json['in_nifty50'] as bool? ?? false,
      inNifty500: json['in_nifty500'] as bool? ?? false,
      isFo: json['is_fo_enabled'] as bool? ?? false,
      isIndex: json['is_index'] as bool? ?? false,
      tickSize: (json['tick_size'] as num?)?.toDouble(),
      circuitPct: (json['circuit_pct'] as num?)?.toDouble(),
      latestDataDate: json['latest_data_date'] as String?,
    );
  }

  final String id;
  final String ticker;
  final String name;
  final String exchange;
  final String? sector;
  final String? marketCap;
  final bool inNifty50;
  final bool inNifty500;
  final bool isFo;
  final bool isIndex;
  final double? tickSize;
  final double? circuitPct;
  final String? latestDataDate;

  @override
  List<Object?> get props => [id, ticker, exchange];
}
