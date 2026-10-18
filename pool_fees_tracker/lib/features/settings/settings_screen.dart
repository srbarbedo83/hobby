import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/chain.dart';
import '../../data/local/settings_service.dart';
import 'add_wallet_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = AppPalette.of(context);
    final settings = ref.watch(appSettingsProvider);
    final walletsAsync = ref.watch(walletsProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Appearance'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: RadioGroup<AppThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .update((s) => s.copyWith(themeMode: mode));
                }
              },
              child: Column(
                children: [
                  for (final mode in AppThemeMode.values)
                    RadioListTile<AppThemeMode>(
                      contentPadding: EdgeInsets.zero,
                      value: mode,
                      title: Text(
                        mode.label,
                        style: TextStyle(color: palette.textPrimary),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Wallets'),
          const SizedBox(height: 8),
          ...walletsAsync.when(
            data: (wallets) => [
              for (final wallet in wallets)
                _SettingsCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      wallet.label,
                      style: TextStyle(color: palette.textPrimary),
                    ),
                    subtitle: Text(
                      wallet.address,
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: palette.textSecondary,
                      ),
                      onPressed: () async {
                        await ref
                            .read(walletRepositoryProvider)
                            .remove(wallet.address);
                        ref.invalidate(walletsProvider);
                      },
                    ),
                  ),
                ),
              if (wallets.isEmpty)
                _SettingsCard(
                  child: Text(
                    'No wallets added — the Demo data source works without one.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ),
            ],
            loading: () => const [SizedBox(height: 4)],
            error: (e, st) => [Text('Error loading wallets: $e')],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              final result = await showAddWalletDialog(context);
              if (result == null) return;
              await ref
                  .read(walletRepositoryProvider)
                  .upsert(address: result.address, label: result.label);
              ref.invalidate(walletsProvider);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add wallet'),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Data source'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: RadioGroup<DataSourceMode>(
              groupValue: settings.dataSourceMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .update((s) => s.copyWith(dataSourceMode: mode));
                }
              },
              child: Column(
                children: [
                  RadioListTile<DataSourceMode>(
                    contentPadding: EdgeInsets.zero,
                    value: DataSourceMode.demo,
                    title: Text(
                      'Demo',
                      style: TextStyle(color: palette.textPrimary),
                    ),
                    subtitle: Text(
                      'Synthetic positions and fee history — no wallet or API key needed.',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  RadioListTile<DataSourceMode>(
                    contentPadding: EdgeInsets.zero,
                    value: DataSourceMode.live,
                    title: Text(
                      'Live (experimental)',
                      style: TextStyle(color: palette.textPrimary),
                    ),
                    subtitle: Text(
                      'Reads real positions from the Uniswap v3 subgraph + an RPC endpoint. '
                      'Needs a subgraph API key below.',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Chains'),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Pick every chain to watch — positions from all of them are summed '
              'into one dashboard.',
              style: TextStyle(color: palette.textTertiary, fontSize: 11),
            ),
          ),
          _SettingsCard(
            child: Column(
              children: [
                for (final chain in Chain.values)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: palette.accent,
                    title: Text(
                      chain.displayName,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13.5,
                      ),
                    ),
                    value: settings.selectedChains.contains(chain),
                    onChanged: (checked) {
                      if (checked == null) return;
                      final updated = {...settings.selectedChains};
                      if (checked) {
                        updated.add(chain);
                      } else if (updated.length > 1) {
                        // Pelo menos uma chain tem de ficar selecionada.
                        updated.remove(chain);
                      }
                      ref
                          .read(appSettingsProvider.notifier)
                          .update((s) => s.copyWith(selectedChains: updated));
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Live mode credentials'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: settings.subgraphApiKey,
                  decoration: const InputDecoration(
                    labelText: 'Subgraph API key (The Graph)',
                  ),
                  obscureText: true,
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .update((s) => s.copyWith(subgraphApiKey: v)),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: settings.rpcUrl,
                  decoration: const InputDecoration(
                    labelText:
                        'RPC URL (Alchemy / Infura / QuickNode) — optional',
                  ),
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .update((s) => s.copyWith(rpcUrl: v)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Optional — only used to show the real gas cost (and gas break-even) '
                  'on the detail screen, by reading the receipts of your position\'s '
                  'transactions. Must point to the same chain as one of your selected '
                  'chains above; leave empty to skip. Not used for anything else — '
                  'positions always come from the subgraph.',
                  style: TextStyle(color: palette.textTertiary, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stored only on this device. Never your seed phrase or private key — '
                  'this app is read-only.',
                  style: TextStyle(color: palette.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Refresh interval'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Every ${settings.refreshIntervalSeconds}s',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: settings.refreshIntervalSeconds.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 11,
                  activeColor: palette.accent,
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .update(
                        (s) => s.copyWith(refreshIntervalSeconds: v.round()),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Alerts'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: palette.accent,
                  title: Text(
                    'Enable alerts',
                    style: TextStyle(color: palette.textPrimary),
                  ),
                  subtitle: Text(
                    'Background check roughly every 15 minutes (Android WorkManager).',
                    style: TextStyle(color: palette.textTertiary, fontSize: 11),
                  ),
                  value: settings.alertsEnabled,
                  onChanged: (value) => ref
                      .read(appSettingsProvider.notifier)
                      .update((s) => s.copyWith(alertsEnabled: value)),
                ),
                if (settings.alertsEnabled) ...[
                  Divider(color: palette.border, height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: palette.accent,
                    title: Text(
                      'Out-of-range alerts',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13.5,
                      ),
                    ),
                    value: settings.outOfRangeAlertsEnabled,
                    onChanged: (value) => ref
                        .read(appSettingsProvider.notifier)
                        .update(
                          (s) => s.copyWith(outOfRangeAlertsEnabled: value),
                        ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: palette.accent,
                    title: Text(
                      'Fee milestone alerts',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13.5,
                      ),
                    ),
                    value: settings.feeMilestoneAlertsEnabled,
                    onChanged: (value) => ref
                        .read(appSettingsProvider.notifier)
                        .update(
                          (s) => s.copyWith(feeMilestoneAlertsEnabled: value),
                        ),
                  ),
                  if (settings.feeMilestoneAlertsEnabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Every \$${settings.feeMilestoneThresholdUsd.toStringAsFixed(0)} per position',
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Slider(
                            value: settings.feeMilestoneThresholdUsd,
                            min: 5,
                            max: 500,
                            divisions: 99,
                            activeColor: palette.accent,
                            onChanged: (v) => ref
                                .read(appSettingsProvider.notifier)
                                .update(
                                  (s) =>
                                      s.copyWith(feeMilestoneThresholdUsd: v),
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Home screen widget'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: RadioGroup<WidgetMetric>(
              groupValue: settings.widgetMetric,
              onChanged: (metric) {
                if (metric != null) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .update((s) => s.copyWith(widgetMetric: metric));
                }
              },
              child: Column(
                children: [
                  for (final metric in WidgetMetric.values)
                    RadioListTile<WidgetMetric>(
                      contentPadding: EdgeInsets.zero,
                      value: metric,
                      title: Text(
                        metric.label,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Currency'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'USD', label: Text('USD')),
                ButtonSegment(value: 'EUR', label: Text('EUR')),
              ],
              selected: {settings.currencyCode},
              onSelectionChanged: (selection) => ref
                  .read(appSettingsProvider.notifier)
                  .update((s) => s.copyWith(currencyCode: selection.first)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: palette.textSecondary,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: child,
    );
  }
}
