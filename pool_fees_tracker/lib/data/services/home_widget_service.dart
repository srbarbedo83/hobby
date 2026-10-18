import 'package:home_widget/home_widget.dart';

import '../../core/calc/dashboard_metrics.dart';
import '../local/settings_service.dart';

/// Qual valor de [DashboardMetrics] mostrar no widget, segundo a escolha do
/// utilizador em Definições → "Home screen widget" (`AppSettings.widgetMetric`).
double widgetMetricValueUsd(WidgetMetric metric, DashboardMetrics metrics) =>
    switch (metric) {
      WidgetMetric.totalFees => metrics.totalFeesUsd,
      WidgetMetric.fees24h => metrics.fees24hUsd,
      WidgetMetric.unclaimed => metrics.unclaimedUsd,
    };

/// Escreve o número e o título em destaque no widget de ecrã inicial
/// Android (`PoolFeesWidgetProvider`) — ambos dependem da estatística
/// escolhida em Definições (`WidgetMetric`), não só o total de fees.
/// Chamado tanto em primeiro plano (sempre que o dashboard recalcula os
/// totais) como na verificação periódica em background de alertas — assim
/// o widget continua a atualizar, só menos frequentemente (~15 min), com a
/// app fechada.
class HomeWidgetService {
  static const _androidProviderName = 'PoolFeesWidgetProvider';

  static Future<void> update({
    required String titleLabel,
    required String valueFormatted,
    required String updatedAtLabel,
  }) async {
    await HomeWidget.saveWidgetData('widget_title', titleLabel);
    await HomeWidget.saveWidgetData('value_formatted', valueFormatted);
    await HomeWidget.saveWidgetData('updated_at_label', updatedAtLabel);
    await HomeWidget.updateWidget(androidName: _androidProviderName);
  }
}
