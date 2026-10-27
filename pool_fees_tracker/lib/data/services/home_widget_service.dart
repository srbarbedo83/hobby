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

/// Os outros dois `WidgetMetric` além do escolhido como principal — para
/// mostrar como estatísticas secundárias no widget (ver `HomeWidgetService`),
/// em vez de ficarem de fora só porque não foram o escolhido.
List<WidgetMetric> secondaryWidgetMetrics(WidgetMetric primary) =>
    WidgetMetric.values.where((m) => m != primary).toList();

/// Escreve o número em destaque (escolhido em Definições → `WidgetMetric`)
/// e, pedido do utilizador ("só tem uma info, dá para pôr o máximo
/// possível?"), também os outros dois valores, mais pequenos, numa linha
/// por baixo — o widget deixa de mostrar só uma estatística isolada.
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
    required String secondary1Label,
    required String secondary1Value,
    required String secondary2Label,
    required String secondary2Value,
  }) async {
    await HomeWidget.saveWidgetData('widget_title', titleLabel);
    await HomeWidget.saveWidgetData('value_formatted', valueFormatted);
    await HomeWidget.saveWidgetData('updated_at_label', updatedAtLabel);
    await HomeWidget.saveWidgetData('secondary1_label', secondary1Label);
    await HomeWidget.saveWidgetData('secondary1_value', secondary1Value);
    await HomeWidget.saveWidgetData('secondary2_label', secondary2Label);
    await HomeWidget.saveWidgetData('secondary2_value', secondary2Value);
    await HomeWidget.updateWidget(androidName: _androidProviderName);
  }
}
