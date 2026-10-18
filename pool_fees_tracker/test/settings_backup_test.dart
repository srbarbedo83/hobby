import 'package:flutter_test/flutter_test.dart';
import 'package:pool_fees_tracker/core/export/settings_backup.dart';
import 'package:pool_fees_tracker/data/local/chain.dart';
import 'package:pool_fees_tracker/data/local/settings_service.dart';
import 'package:pool_fees_tracker/data/local/wallet.dart';

Wallet _wallet(String address, String label) {
  return Wallet()
    ..address = address
    ..label = label
    ..addedAt = DateTime(2026, 1, 1);
}

void main() {
  group('encode/decodeSettingsBackup', () {
    test('ida e volta preserva as definições e as carteiras', () {
      const settings = AppSettings(
        dataSourceMode: DataSourceMode.live,
        themeMode: AppThemeMode.dark,
        widgetMetric: WidgetMetric.fees24h,
        selectedChains: {Chain.ethereum, Chain.arbitrum},
        subgraphApiKey: 'abc123',
        rpcUrl: 'https://rpc.example.com',
        refreshIntervalSeconds: 60,
        currencyCode: 'EUR',
        alertsEnabled: true,
        feeMilestoneThresholdUsd: 100,
      );
      final wallets = [
        _wallet('0x1111', 'Principal'),
        _wallet('0x2222', 'Secundária'),
      ];

      final backup = decodeSettingsBackup(
        encodeSettingsBackup(settings, wallets),
      );

      expect(backup.settings.dataSourceMode, DataSourceMode.live);
      expect(backup.settings.themeMode, AppThemeMode.dark);
      expect(backup.settings.widgetMetric, WidgetMetric.fees24h);
      expect(backup.settings.selectedChains, {Chain.ethereum, Chain.arbitrum});
      expect(backup.settings.subgraphApiKey, 'abc123');
      expect(backup.settings.rpcUrl, 'https://rpc.example.com');
      expect(backup.settings.refreshIntervalSeconds, 60);
      expect(backup.settings.currencyCode, 'EUR');
      expect(backup.settings.alertsEnabled, isTrue);
      expect(backup.settings.feeMilestoneThresholdUsd, 100);
      expect(backup.wallets, hasLength(2));
      expect(backup.wallets[0].address, '0x1111');
      expect(backup.wallets[0].label, 'Principal');
    });

    test('lança FormatException para texto que não é JSON', () {
      expect(
        () => decodeSettingsBackup('isto não é json'),
        throwsFormatException,
      );
    });

    test('lança FormatException para JSON válido mas sem a forma esperada', () {
      expect(
        () => decodeSettingsBackup('{"foo": "bar"}'),
        throwsFormatException,
      );
    });

    test('lista de carteiras vazia é válida', () {
      final backup = decodeSettingsBackup(
        encodeSettingsBackup(const AppSettings(), const []),
      );
      expect(backup.wallets, isEmpty);
    });
  });
}
