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

/// Para posições v4 (ver `_mapV4Positions`): não há subgraph v4 para ler
/// eventos de `collect()` passados, por isso `feesClaimedUsd` nunca é
/// creditado diretamente — cada refresh lê o on-chain do zero e começava
/// sempre com `feesClaimedUsd = 0`. Sem isto, um collect() feito fora da
/// app (ou até só uma pequena revalorização de preço do ativo) fazia o
/// total vitalício "desaparecer": o `unclaimed` on-chain reseta ao
/// reclamar, e sem nada a substituir esse valor no `claimed`,
/// `feesTotalUsd` cai a pique de repente.
///
/// Mantém o total vitalício sempre ≥ ao que já se tinha visto antes,
/// atribuindo a diferença a `feesClaimedUsd` — o dinheiro chegou mesmo à
/// wallet (lido on-chain, só não se sabe o timestamp exato do collect).
/// `feesTotalUsd` resultante é sempre
/// `max(currentUnclaimedUsd, previousTotalUsd)`.
double preservedV4FeesClaimedUsd({
  required double previousTotalUsd,
  required double currentUnclaimedUsd,
}) {
  final shortfall = previousTotalUsd - currentUnclaimedUsd;
  return shortfall > 0 ? shortfall : 0;
}
