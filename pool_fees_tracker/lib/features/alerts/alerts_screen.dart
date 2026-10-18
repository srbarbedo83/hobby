import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Ainda não há motor de notificações (precisa de um serviço em background
/// e permissões de notificação) — fica honesto sobre isso em vez de fingir
/// alertas que não disparam mesmo.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              size: 40,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Alerts are coming soon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Out-of-range warnings and fee-milestone notifications need a background '
              'refresh service, which isn\'t wired up yet. For now, check the Pools tab '
              'for each position\'s range status.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
