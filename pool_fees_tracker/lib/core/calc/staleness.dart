/// Considera os dados "obsoletos" quando não há refresh há mais do que
/// 3x o intervalo configurado (mínimo de 2 minutos) — dá margem para um
/// refresh atrasado sem gerar falsos positivos a cada pequeno atraso de
/// rede, mas ainda assim avisa se o refresh automático parou mesmo
/// (RPC em baixo, sem rede, app em background há muito tempo).
bool isDataStale({
  required DateTime? lastUpdatedAt,
  required int refreshIntervalSeconds,
  DateTime? now,
}) {
  if (lastUpdatedAt == null) return false;
  final effectiveNow = now ?? DateTime.now();
  final thresholdSeconds = (refreshIntervalSeconds * 3).clamp(120, 3600);
  return effectiveNow.difference(lastUpdatedAt).inSeconds > thresholdSeconds;
}
