import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/candle.dart';

/// Line chart of closing prices over the selected range.
///
/// A true OHLC candlestick renderer is a reasonable future upgrade, but
/// fl_chart has no first-class candlestick chart type — building one
/// correctly (wicks, bodies, gap handling for non-trading days) is a
/// meaningful chunk of work on its own. A close-price line chart is the
/// honest Phase-1 scope: it's what the backend's daily-EOD-only data
/// supports well, without overstating visual sophistication the data
/// doesn't yet back up (no intraday, no volume profile).
class PriceChart extends StatelessWidget {
  const PriceChart({required this.candles, super.key});

  final List<Candle> candles;

  @override
  Widget build(BuildContext context) {
    if (candles.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: Text(
            'No price data for this range',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final spots = <FlSpot>[
      for (var i = 0; i < candles.length; i++)
        FlSpot(i.toDouble(), candles[i].close),
    ];

    final minY = candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    final maxY = candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.08;

    final isOverallBullish = candles.last.close >= candles.first.close;
    final lineColor =
        isOverallBullish ? AppColors.bullish : AppColors.bearish;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: (candles.length / 4).clamp(1, candles.length).toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= candles.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      Formatters.shortDate(candles[index].date),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceVariant,
              getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
                final candle = candles[spot.x.toInt()];
                return LineTooltipItem(
                  '${Formatters.shortDate(candle.date)}\n'
                  '${Formatters.price(candle.close)}',
                  const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: lineColor,
              barWidth: 1.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withOpacity(0.18),
                    lineColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
