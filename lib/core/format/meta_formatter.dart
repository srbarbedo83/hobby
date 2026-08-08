import '../../data/local/hobby.dart';

/// Resumo curto de uma [Meta] para mostrar em listas (ex. "3h / semana").
String formatarMeta(Meta? meta) {
  if (meta == null) return 'Sem meta definida';

  switch (meta.tipo) {
    case TipoMeta.diaria:
      return '${_formatarMinutos(meta.valorMinutos)} / dia';
    case TipoMeta.semanal:
      return '${_formatarMinutos(meta.valorMinutos)} / semana';
    case TipoMeta.porNumeroSessoes:
      final sessoes = meta.numeroSessoes ?? 0;
      final periodo = meta.periodicidade == Periodicidade.diario ? 'dia' : 'semana';
      return '${sessoes}x / $periodo';
  }
}

String _formatarMinutos(int? minutos) {
  if (minutos == null || minutos <= 0) return '0min';
  final horas = minutos ~/ 60;
  final resto = minutos % 60;
  if (horas == 0) return '${resto}min';
  if (resto == 0) return '${horas}h';
  return '${horas}h${resto.toString().padLeft(2, '0')}';
}
