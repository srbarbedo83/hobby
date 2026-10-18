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
            'Definições',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Aparência'),
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
                    'Ainda sem wallets — a fonte de dados Demo funciona sem nenhuma.',
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ),
            ],
            loading: () => const [SizedBox(height: 4)],
            error: (e, st) => [Text('Erro ao carregar wallets: $e')],
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
            label: const Text('Adicionar wallet'),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Fonte de dados'),
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
                      'Posições e histórico de taxas sintéticos — não precisa de wallet nem de API key.',
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
                      'Lê posições reais do subgraph Uniswap v3 + um endpoint RPC. '
                      'Precisa de uma API key de subgraph abaixo.',
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
              'Escolhe todas as chains a acompanhar — as posições de todas são '
              'somadas num só dashboard.',
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
          _SectionLabel('Credenciais do modo Live'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: settings.subgraphApiKey,
                  decoration: const InputDecoration(
                    labelText: 'API key do subgraph (The Graph)',
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
                        'RPC URL (Alchemy / Infura / QuickNode) — opcional',
                  ),
                  onChanged: (v) => ref
                      .read(appSettingsProvider.notifier)
                      .update((s) => s.copyWith(rpcUrl: v)),
                ),
                const SizedBox(height: 6),
                Text(
                  'Opcional — só usado para mostrar o custo real de gas (e o gas '
                  'break-even) no ecrã de detalhe, lendo os recibos das transações '
                  'desta posição. Tem de apontar para a mesma chain de uma das '
                  'chains selecionadas acima; deixa vazio para ignorar. Não é usado '
                  'para mais nada — as posições vêm sempre do subgraph.',
                  style: TextStyle(color: palette.textTertiary, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  'Guardado só neste dispositivo. Nunca a tua seed phrase ou chave '
                  'privada — esta app é só de leitura.',
                  style: TextStyle(color: palette.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Intervalo de atualização'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A cada ${settings.refreshIntervalSeconds}s',
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
          _SectionLabel('Alertas'),
          const SizedBox(height: 8),
          _SettingsCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: palette.accent,
                  title: Text(
                    'Ativar alertas',
                    style: TextStyle(color: palette.textPrimary),
                  ),
                  subtitle: Text(
                    'Verificação em background a cada ~15 minutos (Android WorkManager).',
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
                      'Alertas de fora do range',
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
                      'Alertas de milestones de taxas',
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
                            'A cada \$${settings.feeMilestoneThresholdUsd.toStringAsFixed(0)} por posição',
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
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: palette.accent,
                    title: Text(
                      'Alertas de abrandamento de taxas',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13.5,
                      ),
                    ),
                    subtitle: Text(
                      'Taxas de 24h bem abaixo da média de 7 dias — pode significar que '
                      'a pool está a ter menos volume.',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    value: settings.feeSlowdownAlertsEnabled,
                    onChanged: (value) => ref
                        .read(appSettingsProvider.notifier)
                        .update(
                          (s) => s.copyWith(feeSlowdownAlertsEnabled: value),
                        ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: palette.accent,
                    title: Text(
                      'Alertas de concentração de risco',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 13.5,
                      ),
                    ),
                    subtitle: Text(
                      'Uma única chain a passar 60% do valor total da carteira — '
                      'considera diversificar.',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    value: settings.concentrationRiskAlertsEnabled,
                    onChanged: (value) => ref
                        .read(appSettingsProvider.notifier)
                        .update(
                          (s) =>
                              s.copyWith(concentrationRiskAlertsEnabled: value),
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Widget do ecrã inicial'),
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
          _SectionLabel('Moeda'),
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
