import 'package:home_widget/home_widget.dart';

/// Escreve o número de fees total no widget de ecrã inicial Android
/// (`PoolFeesWidgetProvider`). Chamado tanto em primeiro plano (sempre que
/// o dashboard recalcula os totais) como na verificação periódica em
/// background de alertas — assim o widget continua a atualizar, só menos
/// frequentemente (~15 min), com a app fechada.
class HomeWidgetService {
  static const _androidProviderName = 'PoolFeesWidgetProvider';

  static Future<void> update({
    required String totalFeesFormatted,
    required String updatedAtLabel,
  }) async {
    await HomeWidget.saveWidgetData('total_fees_formatted', totalFeesFormatted);
    await HomeWidget.saveWidgetData('updated_at_label', updatedAtLabel);
    await HomeWidget.updateWidget(androidName: _androidProviderName);
  }
}
