/// Delta de fees (em USD) entre dois refreshes, nunca negativo.
///
/// `null` [previousTotal] (primeira vez que se vê a posição) dá sempre 0 —
/// não há "anterior" para comparar, e atribuir tudo o que já se acumulou
/// (talvez há meses) a este instante distorceria o histórico.
///
/// Quando há um total anterior, o delta normalmente seria só
/// `currentTotal - previousTotal` — mas para posições v4 o total inclui
/// `feesUnclaimedUsd`, convertido do montante em tokens para USD ao preço
/// ATUAL de mercado. Se o preço do ativo descer entre dois refreshes, o
/// mesmo saldo (ainda) por reclamar vale menos em USD, e o delta dava
/// negativo mesmo sem a posição ter "perdido" fees (o fee growth on-chain
/// é monótono, só a valorização em USD oscila). Não é um valor real de
/// "taxas perdidas" — é só a conversão de moeda a mexer — por isso o chão
/// é 0 em vez de deixar passar negativo para os gráficos/APR/milestones,
/// que assumem "taxas geradas" nunca descem.
double clampFeeDeltaUsd({
  required double? previousTotal,
  required double currentTotal,
}) {
  if (previousTotal == null) return 0;
  final rawDelta = currentTotal - previousTotal;
  return rawDelta < 0 ? 0 : rawDelta;
}
