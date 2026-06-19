import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's watchlist (a set of ticker symbols) locally on
/// the device using [SharedPreferences].
///
/// There is no backend endpoint for watchlists in Phase 1 — this is
/// intentionally device-local only. A server-synced watchlist would
/// require a `/api/v1/watchlist` endpoint and user accounts, neither of
/// which exist yet.
class WatchlistStorage {
  WatchlistStorage({SharedPreferences? prefs}) : _prefsOverride = prefs;

  static const String _key = 'watchlist_tickers';

  final SharedPreferences? _prefsOverride;

  Future<SharedPreferences> _prefs() async {
    if (_prefsOverride != null) return _prefsOverride!;
    return SharedPreferences.getInstance();
  }

  Future<Set<String>> getTickers() async {
    final prefs = await _prefs();
    return (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  Future<void> add(String ticker) async {
    final prefs = await _prefs();
    final current = (prefs.getStringList(_key) ?? const <String>[]).toSet();
    current.add(ticker.toUpperCase());
    await prefs.setStringList(_key, current.toList());
  }

  Future<void> remove(String ticker) async {
    final prefs = await _prefs();
    final current = (prefs.getStringList(_key) ?? const <String>[]).toSet();
    current.remove(ticker.toUpperCase());
    await prefs.setStringList(_key, current.toList());
  }

  Future<bool> contains(String ticker) async {
    final tickers = await getTickers();
    return tickers.contains(ticker.toUpperCase());
  }
}
