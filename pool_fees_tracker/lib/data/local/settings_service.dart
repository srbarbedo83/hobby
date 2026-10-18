import 'package:shared_preferences/shared_preferences.dart';

import 'chain.dart';

enum DataSourceMode { demo, live }

/// Preferências simples da app (não precisam da estrutura de uma coleção
/// Isar): fonte de dados, credenciais de API, intervalo de refresh e moeda.
class AppSettings {
  final DataSourceMode dataSourceMode;
  final Chain chain;
  final String subgraphApiKey;
  final String rpcUrl;
  final int refreshIntervalSeconds;
  final String currencyCode;

  const AppSettings({
    this.dataSourceMode = DataSourceMode.demo,
    this.chain = Chain.ethereum,
    this.subgraphApiKey = '',
    this.rpcUrl = '',
    this.refreshIntervalSeconds = 30,
    this.currencyCode = 'USD',
  });

  AppSettings copyWith({
    DataSourceMode? dataSourceMode,
    Chain? chain,
    String? subgraphApiKey,
    String? rpcUrl,
    int? refreshIntervalSeconds,
    String? currencyCode,
  }) {
    return AppSettings(
      dataSourceMode: dataSourceMode ?? this.dataSourceMode,
      chain: chain ?? this.chain,
      subgraphApiKey: subgraphApiKey ?? this.subgraphApiKey,
      rpcUrl: rpcUrl ?? this.rpcUrl,
      refreshIntervalSeconds:
          refreshIntervalSeconds ?? this.refreshIntervalSeconds,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  /// Em modo demo não há credenciais para validar; em modo live é preciso
  /// pelo menos uma API key de subgraph configurada.
  bool get isLiveModeReady =>
      dataSourceMode == DataSourceMode.demo || subgraphApiKey.isNotEmpty;
}

class SettingsService {
  static const _keyDataSource = 'data_source_mode';
  static const _keyChain = 'chain';
  static const _keySubgraphApiKey = 'subgraph_api_key';
  static const _keyRpcUrl = 'rpc_url';
  static const _keyRefreshInterval = 'refresh_interval_seconds';
  static const _keyCurrency = 'currency_code';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  AppSettings load() {
    final sourceName = _prefs.getString(_keyDataSource);
    final chainName = _prefs.getString(_keyChain);
    return AppSettings(
      dataSourceMode: DataSourceMode.values.firstWhere(
        (e) => e.name == sourceName,
        orElse: () => DataSourceMode.demo,
      ),
      chain: Chain.values.firstWhere(
        (e) => e.name == chainName,
        orElse: () => Chain.ethereum,
      ),
      subgraphApiKey: _prefs.getString(_keySubgraphApiKey) ?? '',
      rpcUrl: _prefs.getString(_keyRpcUrl) ?? '',
      refreshIntervalSeconds: _prefs.getInt(_keyRefreshInterval) ?? 30,
      currencyCode: _prefs.getString(_keyCurrency) ?? 'USD',
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_keyDataSource, settings.dataSourceMode.name);
    await _prefs.setString(_keyChain, settings.chain.name);
    await _prefs.setString(_keySubgraphApiKey, settings.subgraphApiKey);
    await _prefs.setString(_keyRpcUrl, settings.rpcUrl);
    await _prefs.setInt(_keyRefreshInterval, settings.refreshIntervalSeconds);
    await _prefs.setString(_keyCurrency, settings.currencyCode);
  }
}
