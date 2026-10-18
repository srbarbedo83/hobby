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
    final settings = ref.watch(appSettingsProvider);
    final walletsAsync = ref.watch(walletsProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
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
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      wallet.address,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.textSecondary,
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
                const _SettingsCard(
                  child: Text(
                    'No wallets added — the Demo data source works without one.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
              child: const Column(
                children: [
                  RadioListTile<DataSourceMode>(
                    contentPadding: EdgeInsets.zero,
                    value: DataSourceMode.demo,
                    title: Text(
                      'Demo',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Synthetic positions and fee history — no wallet or API key needed.',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                  RadioListTile<DataSourceMode>(
                    contentPadding: EdgeInsets.zero,
                    value: DataSourceMode.live,
                    title: Text(
                      'Live (experimental)',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Reads real positions from the Uniswap v3 subgraph + an RPC endpoint. '
                      'Needs a subgraph API key below.',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Chain'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: DropdownButtonFormField<Chain>(
              initialValue: settings.chain,
              dropdownColor: AppColors.surfaceAlt,
              decoration: const InputDecoration(border: InputBorder.none),
              items: [
                for (final chain in Chain.values)
                  DropdownMenuItem(
                    value: chain,
                    child: Text(chain.displayName),
                  ),
              ],
              onChanged: (chain) {
                if (chain != null) {
                  ref
                      .read(appSettingsProvider.notifier)
                      .update((s) => s.copyWith(chain: chain));
                }
              },
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
                    labelText: 'RPC URL (Alchemy / Infura / QuickNode)',
                  ),
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .update((s) => s.copyWith(rpcUrl: v)),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Stored only on this device. Never your seed phrase or private key — '
                  'this app is read-only.',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: settings.refreshIntervalSeconds.toDouble(),
                  min: 10,
                  max: 120,
                  divisions: 11,
                  activeColor: AppColors.accent,
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
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
