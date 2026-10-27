import 'dart:convert';

import '../../data/local/chain.dart';
import '../../data/local/settings_service.dart';
import '../../data/local/wallet.dart';

const int _backupVersion = 1;

/// Uma carteira dentro do backup — só o que é preciso para recriar o
/// registo (endereço + rótulo), não o `id` interno do Isar.
class WalletBackupEntry {
  final String address;
  final String label;

  const WalletBackupEntry({required this.address, required this.label});
}

class SettingsBackup {
  final AppSettings settings;
  final List<WalletBackupEntry> wallets;

  const SettingsBackup({required this.settings, required this.wallets});
}

/// Serializa definições + carteiras para um JSON legível — pensado para ser
/// partilhado (ficheiro de texto, notas, email) e colado de volta mais
/// tarde em [decodeSettingsBackup]. Inclui a API key e o RPC URL tal como
/// estão guardados: é um backup pessoal, não algo para partilhar com
/// outra pessoa.
String encodeSettingsBackup(AppSettings settings, List<Wallet> wallets) {
  return jsonEncode({
    'version': _backupVersion,
    'settings': {
      'dataSourceMode': settings.dataSourceMode.name,
      'themeMode': settings.themeMode.name,
      'widgetMetric': settings.widgetMetric.name,
      'selectedChains': settings.selectedChains.map((c) => c.name).toList(),
      'subgraphApiKey': settings.subgraphApiKey,
      'rpcUrl': settings.rpcUrl,
      'refreshIntervalSeconds': settings.refreshIntervalSeconds,
      'currencyCode': settings.currencyCode,
      'alertsEnabled': settings.alertsEnabled,
      'outOfRangeAlertsEnabled': settings.outOfRangeAlertsEnabled,
      'outOfRangeDurationAlertsEnabled':
          settings.outOfRangeDurationAlertsEnabled,
      'outOfRangeDurationThresholdDays':
          settings.outOfRangeDurationThresholdDays,
      'feeMilestoneAlertsEnabled': settings.feeMilestoneAlertsEnabled,
      'feeMilestoneThresholdUsd': settings.feeMilestoneThresholdUsd,
      'feeSlowdownAlertsEnabled': settings.feeSlowdownAlertsEnabled,
      'concentrationRiskAlertsEnabled': settings.concentrationRiskAlertsEnabled,
      'weeklyDigestEnabled': settings.weeklyDigestEnabled,
    },
    'wallets': [
      for (final w in wallets) {'address': w.address, 'label': w.label},
    ],
  });
}

/// Inverso de [encodeSettingsBackup]. Lança [FormatException] com uma
/// mensagem em português se o texto não for um backup válido desta app —
/// quem chama decide o que mostrar ao utilizador.
SettingsBackup decodeSettingsBackup(String text) {
  late final Object? decoded;
  try {
    decoded = jsonDecode(text.trim());
  } catch (_) {
    throw const FormatException('Texto não é um JSON válido');
  }
  if (decoded is! Map<String, dynamic> || decoded['settings'] is! Map) {
    throw const FormatException(
      'Não parece ser um backup do Pool Fees Tracker',
    );
  }

  final s = decoded['settings'] as Map<String, dynamic>;
  final chainNames = (s['selectedChains'] as List?)?.cast<String>() ?? const [];
  final selectedChains = {
    for (final name in chainNames) ...Chain.values.where((c) => c.name == name),
  };

  final settings = AppSettings(
    dataSourceMode: DataSourceMode.values.firstWhere(
      (e) => e.name == s['dataSourceMode'],
      orElse: () => DataSourceMode.demo,
    ),
    themeMode: AppThemeMode.values.firstWhere(
      (e) => e.name == s['themeMode'],
      orElse: () => AppThemeMode.system,
    ),
    widgetMetric: WidgetMetric.values.firstWhere(
      (e) => e.name == s['widgetMetric'],
      orElse: () => WidgetMetric.totalFees,
    ),
    selectedChains: selectedChains.isEmpty
        ? const {Chain.ethereum}
        : selectedChains,
    subgraphApiKey: s['subgraphApiKey'] as String? ?? '',
    rpcUrl: s['rpcUrl'] as String? ?? '',
    refreshIntervalSeconds:
        (s['refreshIntervalSeconds'] as num?)?.toInt() ?? 30,
    currencyCode: s['currencyCode'] as String? ?? 'USD',
    alertsEnabled: s['alertsEnabled'] as bool? ?? false,
    outOfRangeAlertsEnabled: s['outOfRangeAlertsEnabled'] as bool? ?? true,
    outOfRangeDurationAlertsEnabled:
        s['outOfRangeDurationAlertsEnabled'] as bool? ?? true,
    outOfRangeDurationThresholdDays:
        (s['outOfRangeDurationThresholdDays'] as num?)?.toInt() ?? 3,
    feeMilestoneAlertsEnabled: s['feeMilestoneAlertsEnabled'] as bool? ?? true,
    feeMilestoneThresholdUsd:
        (s['feeMilestoneThresholdUsd'] as num?)?.toDouble() ?? 50,
    feeSlowdownAlertsEnabled: s['feeSlowdownAlertsEnabled'] as bool? ?? true,
    concentrationRiskAlertsEnabled:
        s['concentrationRiskAlertsEnabled'] as bool? ?? true,
    weeklyDigestEnabled: s['weeklyDigestEnabled'] as bool? ?? true,
  );

  final walletsJson = (decoded['wallets'] as List?) ?? const [];
  final wallets = [
    for (final w in walletsJson)
      if (w is Map && w['address'] is String)
        WalletBackupEntry(
          address: w['address'] as String,
          label: w['label'] as String? ?? w['address'] as String,
        ),
  ];

  return SettingsBackup(settings: settings, wallets: wallets);
}
