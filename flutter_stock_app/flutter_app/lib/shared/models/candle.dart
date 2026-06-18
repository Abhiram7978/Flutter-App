import 'package:equatable/equatable.dart';

/// A single daily OHLCV candle, mirroring the shape returned by
/// GET /api/v1/stocks/{ticker}/ohlcv and /latest.
class Candle extends Equatable {
  const Candle({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.prevClose,
    this.changePct,
    this.validationStatus,
  });

  factory Candle.fromJson(Map<String, dynamic> json) {
    return Candle(
      date: DateTime.parse(json['date'] as String),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toInt(),
      prevClose: (json['prev_close'] as num?)?.toDouble(),
      changePct: (json['change_pct'] as num?)?.toDouble(),
      validationStatus: json['validation_status'] as String?,
    );
  }

  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
  final double? prevClose;
  final double? changePct;
  final String? validationStatus;

  /// True if this candle was flagged WARNING or FAILED by the backend
  /// validation engine. The UI should visually de-emphasise these.
  bool get isFlagged =>
      validationStatus != null &&
      validationStatus != 'PASSED' &&
      validationStatus != 'NOT_RUN';

  bool get isBullish => close >= open;

  @override
  List<Object?> get props => [date, open, high, low, close, volume];
}
