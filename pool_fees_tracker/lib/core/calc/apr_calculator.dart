/// APR realizado (anualizado), a partir de fees realmente ganhas num período.
///
/// `feesUsdEarnedInPeriod / liquidityUsd` dá o retorno do período; anualiza-se
/// escalando por `365 / periodDays`. Devolve 0 em entradas degeneradas
/// (liquidez ou período inválidos) em vez de Infinity/NaN.
double realizedAprPct({
  required double feesUsdEarnedInPeriod,
  required double liquidityUsd,
  required num periodDays,
}) {
  if (liquidityUsd <= 0 || periodDays <= 0) return 0;
  final periodReturn = feesUsdEarnedInPeriod / liquidityUsd;
  return periodReturn * (365 / periodDays) * 100;
}
