import 'package:shared_preferences/shared_preferences.dart';

import 'chain.dart';

enum DataSourceMode { demo, live }

/// Preferências simples da app (não precisam da estrutura de uma coleção
/// Isar): fonte de dados, credenciais de API, intervalo de refresh, moeda,
/// e configuração de alertas (lidas também pelo isolate em background do
/// Workmanager — ver `alert_check_worker.dart`).
class AppSettings {
  final DataSourceMode dataSourceMode;

  /// Chains ativas em modo Live — as posições de todas são agregadas no
  /// mesmo dashboard (ver `LivePoolFeesRepository`). Nunca vazio: o setter
  /// nas Definições impede desmarcar a última.
  final Set<Chain> selectedChains;
  final String subgraphApiKey;
  final String rpcUrl;
  final int refreshIntervalSeconds;
  final String currencyCode;

  final bool alertsEnabled;
  final bool outOfRangeAlertsEnabled;
  final bool feeMilestoneAlertsEnabled;
  final double feeMilestoneThresholdUsd;

  const AppSettings({
    this.dataSourceMode = DataSourceMode.demo,
    this.selectedChains = const {Chain.ethereum},
    this.subgraphApiKey = '',
    this.rpcUrl = '',
    this.refreshIntervalSeconds = 30,
    this.currencyCode = 'USD',
    this.alertsEnabled = false,
    this.outOfRangeAlertsEnabled = true,
    this.feeMilestoneAlertsEnabled = true,
    this.feeMilestoneThresholdUsd = 50,
  });

  AppSettings copyWith({
    DataSourceMode? dataSourceMode,
    Set<Chain>? selectedChains,
    String? subgraphApiKey,
    String? rpcUrl,
    int? refreshIntervalSeconds,
    String? currencyCode,
    bool? alertsEnabled,
    bool? outOfRangeAlertsEnabled,
    bool? feeMilestoneAlertsEnabled,
    double? feeMilestoneThresholdUsd,
  }) {
    return AppSettings(
      dataSourceMode: dataSourceMode ?? this.dataSourceMode,
      selectedChains: selectedChains ?? this.selectedChains,
      subgraphApiKey: subgraphApiKey ?? this.subgraphApiKey,
      rpcUrl: rpcUrl ?? this.rpcUrl,
      refreshIntervalSeconds:
          refreshIntervalSeconds ?? this.refreshIntervalSeconds,
      currencyCode: currencyCode ?? this.currencyCode,
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      outOfRangeAlertsEnabled:
          outOfRangeAlertsEnabled ?? this.outOfRangeAlertsEnabled,
      feeMilestoneAlertsEnabled:
          feeMilestoneAlertsEnabled ?? this.feeMilestoneAlertsEnabled,
      feeMilestoneThresholdUsd:
          feeMilestoneThresholdUsd ?? this.feeMilestoneThresholdUsd,
    );
  }

  /// Em modo demo não há credenciais para validar; em modo live é preciso
  /// pelo menos uma API key de subgraph configurada.
  bool get isLiveModeReady =>
      dataSourceMode == DataSourceMode.demo || subgraphApiKey.isNotEmpty;
}

class SettingsService {
  static const _keyDataSource = 'data_source_mode';
  static const _keySelectedChains = 'selected_chains';
  static const _keySubgraphApiKey = 'subgraph_api_key';
  static const _keyRpcUrl = 'rpc_url';
  static const _keyRefreshInterval = 'refresh_interval_seconds';
  static const _keyCurrency = 'currency_code';
  static const _keyAlertsEnabled = 'alerts_enabled';
  static const _keyOutOfRangeAlerts = 'out_of_range_alerts_enabled';
  static const _keyFeeMilestoneAlerts = 'fee_milestone_alerts_enabled';
  static const _keyFeeMilestoneThreshold = 'fee_milestone_threshold_usd';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  AppSettings load() {
    final sourceName = _prefs.getString(_keyDataSource);
    final chainNames = _prefs.getStringList(_keySelectedChains);
    final selectedChains = chainNames == null
        ? const {Chain.ethereum}
        : {
            for (final name in chainNames)
              ...Chain.values.where((c) => c.name == name),
          };
    return AppSettings(
      dataSourceMode: DataSourceMode.values.firstWhere(
        (e) => e.name == sourceName,
        orElse: () => DataSourceMode.demo,
      ),
      selectedChains: selectedChains.isEmpty
          ? const {Chain.ethereum}
          : selectedChains,
      subgraphApiKey: _prefs.getString(_keySubgraphApiKey) ?? '',
      rpcUrl: _prefs.getString(_keyRpcUrl) ?? '',
      refreshIntervalSeconds: _prefs.getInt(_keyRefreshInterval) ?? 30,
      currencyCode: _prefs.getString(_keyCurrency) ?? 'USD',
      alertsEnabled: _prefs.getBool(_keyAlertsEnabled) ?? false,
      outOfRangeAlertsEnabled: _prefs.getBool(_keyOutOfRangeAlerts) ?? true,
      feeMilestoneAlertsEnabled: _prefs.getBool(_keyFeeMilestoneAlerts) ?? true,
      feeMilestoneThresholdUsd:
          _prefs.getDouble(_keyFeeMilestoneThreshold) ?? 50,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_keyDataSource, settings.dataSourceMode.name);
    await _prefs.setStringList(
      _keySelectedChains,
      settings.selectedChains.map((c) => c.name).toList(),
    );
    await _prefs.setString(_keySubgraphApiKey, settings.subgraphApiKey);
    await _prefs.setString(_keyRpcUrl, settings.rpcUrl);
    await _prefs.setInt(_keyRefreshInterval, settings.refreshIntervalSeconds);
    await _prefs.setString(_keyCurrency, settings.currencyCode);
    await _prefs.setBool(_keyAlertsEnabled, settings.alertsEnabled);
    await _prefs.setBool(
      _keyOutOfRangeAlerts,
      settings.outOfRangeAlertsEnabled,
    );
    await _prefs.setBool(
      _keyFeeMilestoneAlerts,
      settings.feeMilestoneAlertsEnabled,
    );
    await _prefs.setDouble(
      _keyFeeMilestoneThreshold,
      settings.feeMilestoneThresholdUsd,
    );
  }
}
