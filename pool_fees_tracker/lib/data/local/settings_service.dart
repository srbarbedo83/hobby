import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'chain.dart';

enum DataSourceMode { demo, live }

/// Tema da app — `system` segue o tema do telemóvel (via
/// `MediaQuery.platformBrightness`), `light`/`dark` fixam-no.
enum AppThemeMode { system, light, dark, extraDark }

extension AppThemeModeLabel on AppThemeMode {
  String get label => switch (this) {
    AppThemeMode.system => 'Sistema',
    AppThemeMode.light => 'Claro',
    AppThemeMode.dark => 'Escuro',
    AppThemeMode.extraDark => 'Escuro extra (degradê)',
  };
}

/// Qual estatística o widget de ecrã inicial Android mostra em destaque —
/// ver `HomeWidgetService`.
enum WidgetMetric { totalFees, fees24h, unclaimed }

extension WidgetMetricLabel on WidgetMetric {
  String get label => switch (this) {
    WidgetMetric.totalFees => 'Total de taxas geradas',
    WidgetMetric.fees24h => 'Taxas 24h',
    WidgetMetric.unclaimed => 'Taxas não reclamadas',
  };

  /// Título mostrado no widget acima do número (maiúsculas, como no
  /// layout atual).
  String get widgetTitle => switch (this) {
    WidgetMetric.totalFees => 'TOTAL DE TAXAS GERADAS',
    WidgetMetric.fees24h => 'TAXAS 24H',
    WidgetMetric.unclaimed => 'TAXAS NÃO RECLAMADAS',
  };
}

/// Preferências simples da app (não precisam da estrutura de uma coleção
/// Isar): fonte de dados, credenciais de API, intervalo de refresh, moeda,
/// e configuração de alertas (lidas também pelo isolate em background do
/// Workmanager — ver `alert_check_worker.dart`).
class AppSettings {
  final DataSourceMode dataSourceMode;
  final AppThemeMode themeMode;
  final WidgetMetric widgetMetric;

  /// Chains ativas em modo Live — as posições de todas são agregadas no
  /// mesmo dashboard (ver `LivePoolFeesRepository`). Nunca vazio: o setter
  /// nas Definições impede desmarcar a última.
  final Set<Chain> selectedChains;
  final String subgraphApiKey;

  /// Override manual do id do subgraph por chain — avançado, normalmente
  /// vazio (usa-se o id publicado em [ChainInfo.uniswapV3SubgraphId]). Serve
  /// para testar outro deployment sem precisar de recompilar a app, caso o
  /// subgraph oficial deixe de responder (deployments na rede do The Graph
  /// mudam de id ao longo do tempo, e indexadores podem deixar de servir um
  /// id antigo).
  final Map<Chain, String> subgraphIdOverrides;

  /// Override manual do endereço do contrato `PositionManager` v4 por chain
  /// — ver [ChainInfo.uniswapV4PositionManagerAddress]. Avançado, normalmente
  /// vazio.
  final Map<Chain, String> v4PositionManagerOverrides;

  /// RPC URL por chain — um único endpoint RPC só responde por UMA chain
  /// (confirmada via `eth_chainId`), por isso uma wallet com posições v4
  /// em mais do que uma chain precisa de um RPC por cada uma. [rpcUrl]
  /// (o campo "antigo", de antes de existir mais que uma chain v4
  /// suportada) continua a funcionar sem mudanças — a chain que o RPC lá
  /// configurado detetar automaticamente usa esse valor como padrão, se
  /// não houver aqui um override explícito para essa chain.
  final Map<Chain, String> v4RpcUrlOverrides;
  final String rpcUrl;
  final int refreshIntervalSeconds;
  final String currencyCode;

  final bool alertsEnabled;
  final bool outOfRangeAlertsEnabled;
  final bool feeMilestoneAlertsEnabled;
  final double feeMilestoneThresholdUsd;
  final bool feeSlowdownAlertsEnabled;
  final bool concentrationRiskAlertsEnabled;
  final bool weeklyDigestEnabled;

  const AppSettings({
    this.dataSourceMode = DataSourceMode.demo,
    this.themeMode = AppThemeMode.system,
    this.widgetMetric = WidgetMetric.totalFees,
    this.selectedChains = const {Chain.ethereum},
    this.subgraphApiKey = '',
    this.subgraphIdOverrides = const {},
    this.v4PositionManagerOverrides = const {},
    this.v4RpcUrlOverrides = const {},
    this.rpcUrl = '',
    this.refreshIntervalSeconds = 30,
    this.currencyCode = 'USD',
    this.alertsEnabled = false,
    this.outOfRangeAlertsEnabled = true,
    this.feeMilestoneAlertsEnabled = true,
    this.feeMilestoneThresholdUsd = 50,
    this.feeSlowdownAlertsEnabled = true,
    this.concentrationRiskAlertsEnabled = true,
    this.weeklyDigestEnabled = true,
  });

  AppSettings copyWith({
    DataSourceMode? dataSourceMode,
    AppThemeMode? themeMode,
    WidgetMetric? widgetMetric,
    Set<Chain>? selectedChains,
    String? subgraphApiKey,
    Map<Chain, String>? subgraphIdOverrides,
    Map<Chain, String>? v4PositionManagerOverrides,
    Map<Chain, String>? v4RpcUrlOverrides,
    String? rpcUrl,
    int? refreshIntervalSeconds,
    String? currencyCode,
    bool? alertsEnabled,
    bool? outOfRangeAlertsEnabled,
    bool? feeMilestoneAlertsEnabled,
    double? feeMilestoneThresholdUsd,
    bool? feeSlowdownAlertsEnabled,
    bool? concentrationRiskAlertsEnabled,
    bool? weeklyDigestEnabled,
  }) {
    return AppSettings(
      dataSourceMode: dataSourceMode ?? this.dataSourceMode,
      themeMode: themeMode ?? this.themeMode,
      widgetMetric: widgetMetric ?? this.widgetMetric,
      selectedChains: selectedChains ?? this.selectedChains,
      subgraphApiKey: subgraphApiKey ?? this.subgraphApiKey,
      subgraphIdOverrides: subgraphIdOverrides ?? this.subgraphIdOverrides,
      v4PositionManagerOverrides:
          v4PositionManagerOverrides ?? this.v4PositionManagerOverrides,
      v4RpcUrlOverrides: v4RpcUrlOverrides ?? this.v4RpcUrlOverrides,
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
      feeSlowdownAlertsEnabled:
          feeSlowdownAlertsEnabled ?? this.feeSlowdownAlertsEnabled,
      concentrationRiskAlertsEnabled:
          concentrationRiskAlertsEnabled ?? this.concentrationRiskAlertsEnabled,
      weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
    );
  }

  /// Em modo demo não há credenciais para validar; em modo live é preciso
  /// pelo menos uma API key de subgraph configurada.
  bool get isLiveModeReady =>
      dataSourceMode == DataSourceMode.demo || subgraphApiKey.isNotEmpty;
}

class SettingsService {
  static const _keyDataSource = 'data_source_mode';
  static const _keyThemeMode = 'theme_mode';
  static const _keyWidgetMetric = 'widget_metric';
  static const _keySelectedChains = 'selected_chains';
  static const _keySubgraphApiKey = 'subgraph_api_key';
  static const _keySubgraphIdOverrides = 'subgraph_id_overrides';
  static const _keyV4PositionManagerOverrides = 'v4_position_manager_overrides';
  static const _keyV4RpcUrlOverrides = 'v4_rpc_url_overrides';
  static const _keyRpcUrl = 'rpc_url';
  static const _keyRefreshInterval = 'refresh_interval_seconds';
  static const _keyCurrency = 'currency_code';
  static const _keyAlertsEnabled = 'alerts_enabled';
  static const _keyOutOfRangeAlerts = 'out_of_range_alerts_enabled';
  static const _keyFeeMilestoneAlerts = 'fee_milestone_alerts_enabled';
  static const _keyFeeMilestoneThreshold = 'fee_milestone_threshold_usd';
  static const _keyFeeSlowdownAlerts = 'fee_slowdown_alerts_enabled';
  static const _keyConcentrationRiskAlerts =
      'concentration_risk_alerts_enabled';
  static const _keyWeeklyDigestEnabled = 'weekly_digest_enabled';

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
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == _prefs.getString(_keyThemeMode),
        orElse: () => AppThemeMode.system,
      ),
      widgetMetric: WidgetMetric.values.firstWhere(
        (e) => e.name == _prefs.getString(_keyWidgetMetric),
        orElse: () => WidgetMetric.totalFees,
      ),
      selectedChains: selectedChains.isEmpty
          ? const {Chain.ethereum}
          : selectedChains,
      subgraphApiKey: _prefs.getString(_keySubgraphApiKey) ?? '',
      subgraphIdOverrides: _decodeChainStringMap(
        _prefs.getString(_keySubgraphIdOverrides),
      ),
      v4PositionManagerOverrides: _decodeChainStringMap(
        _prefs.getString(_keyV4PositionManagerOverrides),
      ),
      v4RpcUrlOverrides: _decodeChainStringMap(
        _prefs.getString(_keyV4RpcUrlOverrides),
      ),
      rpcUrl: _prefs.getString(_keyRpcUrl) ?? '',
      refreshIntervalSeconds: _prefs.getInt(_keyRefreshInterval) ?? 30,
      currencyCode: _prefs.getString(_keyCurrency) ?? 'USD',
      alertsEnabled: _prefs.getBool(_keyAlertsEnabled) ?? false,
      outOfRangeAlertsEnabled: _prefs.getBool(_keyOutOfRangeAlerts) ?? true,
      feeMilestoneAlertsEnabled: _prefs.getBool(_keyFeeMilestoneAlerts) ?? true,
      feeMilestoneThresholdUsd:
          _prefs.getDouble(_keyFeeMilestoneThreshold) ?? 50,
      feeSlowdownAlertsEnabled: _prefs.getBool(_keyFeeSlowdownAlerts) ?? true,
      concentrationRiskAlertsEnabled:
          _prefs.getBool(_keyConcentrationRiskAlerts) ?? true,
      weeklyDigestEnabled: _prefs.getBool(_keyWeeklyDigestEnabled) ?? true,
    );
  }

  Future<void> save(AppSettings settings) async {
    await _prefs.setString(_keyDataSource, settings.dataSourceMode.name);
    await _prefs.setString(_keyThemeMode, settings.themeMode.name);
    await _prefs.setString(_keyWidgetMetric, settings.widgetMetric.name);
    await _prefs.setStringList(
      _keySelectedChains,
      settings.selectedChains.map((c) => c.name).toList(),
    );
    await _prefs.setString(_keySubgraphApiKey, settings.subgraphApiKey);
    await _prefs.setString(
      _keySubgraphIdOverrides,
      _encodeChainStringMap(settings.subgraphIdOverrides),
    );
    await _prefs.setString(
      _keyV4PositionManagerOverrides,
      _encodeChainStringMap(settings.v4PositionManagerOverrides),
    );
    await _prefs.setString(
      _keyV4RpcUrlOverrides,
      _encodeChainStringMap(settings.v4RpcUrlOverrides),
    );
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
    await _prefs.setBool(
      _keyFeeSlowdownAlerts,
      settings.feeSlowdownAlertsEnabled,
    );
    await _prefs.setBool(
      _keyConcentrationRiskAlerts,
      settings.concentrationRiskAlertsEnabled,
    );
    await _prefs.setBool(_keyWeeklyDigestEnabled, settings.weeklyDigestEnabled);
  }

  static String _encodeChainStringMap(Map<Chain, String> map) {
    return jsonEncode({
      for (final entry in map.entries) entry.key.name: entry.value,
    });
  }

  static Map<Chain, String> _decodeChainStringMap(String? raw) {
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          for (final chain in Chain.values)
            if (chain.name == entry.key && (entry.value as String).isNotEmpty)
              chain: entry.value as String,
      };
    } catch (_) {
      // Prefs corrompidas ou de uma versão anterior — ignora em vez de
      // rebentar o carregamento de todas as outras definições.
      return const {};
    }
  }
}
