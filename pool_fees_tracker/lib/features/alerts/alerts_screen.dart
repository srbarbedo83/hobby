import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/background/background_sync_worker.dart';
import '../../data/local/alert_log_entry.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  bool _checking = false;

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    try {
      await runBackgroundSync();
      ref.invalidate(alertLogProvider);
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final settings = ref.watch(appSettingsProvider);
    final logAsync = ref.watch(alertLogProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alerts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: palette.textPrimary,
                ),
              ),
              TextButton(
                onPressed: settings.alertsEnabled && !_checking
                    ? _checkNow
                    : null,
                child: _checking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Check now'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (!settings.alertsEnabled)
            _InfoCard(
              icon: Icons.notifications_off_outlined,
              text:
                  'Alerts are off. Turn them on in Settings to get notified when a '
                  'position goes out of range or crosses a fee milestone.',
            )
          else
            _InfoCard(
              icon: Icons.info_outline,
              text:
                  'Checked roughly every 15 minutes in the background (Android '
                  'WorkManager — timing isn\'t exact and the OS may delay it under '
                  'battery optimization). "Check now" runs it immediately.',
            ),
          const SizedBox(height: 18),
          logAsync.when(
            data: (entries) => entries.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No alerts yet',
                        style: TextStyle(color: palette.textSecondary),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final entry in entries) ...[
                        _AlertLogTile(entry: entry),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Could not load alerts',
                  style: TextStyle(color: palette.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: palette.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                color: palette.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertLogTile extends StatelessWidget {
  final AlertLogEntry entry;

  const _AlertLogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final color = switch (entry.kind) {
      AlertLogKind.outOfRange => palette.warning,
      AlertLogKind.feeMilestone => palette.positive,
      AlertLogKind.feeSlowdown => palette.negative,
      AlertLogKind.priceThreshold => palette.accent,
    };
    final icon = switch (entry.kind) {
      AlertLogKind.outOfRange => Icons.warning_amber_rounded,
      AlertLogKind.feeMilestone => Icons.celebration_outlined,
      AlertLogKind.feeSlowdown => Icons.trending_down,
      AlertLogKind.priceThreshold => Icons.notifications_active_outlined,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.body,
                  style: TextStyle(fontSize: 12, color: palette.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  _relativeTime(entry.firedAt),
                  style: TextStyle(fontSize: 10.5, color: palette.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
