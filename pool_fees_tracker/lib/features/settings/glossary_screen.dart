import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Lista central de explicações — pedido do utilizador depois de perguntar
/// o que significam vários números/ecrãs espalhados pela app. Os sítios
/// relevantes continuam a ter o seu próprio ⓘ tocável (contexto importa),
/// isto é só um sítio único para rever tudo de uma vez.
class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  static const _entries = [
    (
      term: 'Taxas geradas vs. não reclamadas',
      body:
          '"Taxas geradas" é o total acumulado desde que abriste a '
          'posição (reclamadas + por reclamar). "Não reclamadas" é só a '
          'parte que ainda está na pool, à espera de um collect() — é a '
          'que aparece com destaque dourado no ecrã de detalhe.',
    ),
    (
      term: 'APR (7d)',
      body:
          'Taxa de retorno anualizada, calculada a partir das fees dos '
          'últimos 7 dias e do valor atual da posição. Como é anualizada, '
          'amplifica o que aconteceu numa semana — uma posição nova (sem '
          '7 dias de histórico ainda) mostra um número pouco fiável até '
          'esse histórico se preencher.',
    ),
    (
      term: 'Impermanent loss (IL)',
      body:
          'A diferença entre o que tens fornecendo liquidez e o que '
          'terias se só tivesses guardado os dois tokens na carteira. '
          'Aparece sempre que o preço se move, nalguma direção, desde que '
          'abriste a posição — e volta a 0% se o preço voltar ao sítio '
          'de entrada. Ver o ⓘ no ecrã de detalhe para um exemplo numérico.',
    ),
    (
      term: 'Net vs. HODL',
      body:
          'Taxas geradas menos o impermanent loss. Positivo: compensou '
          'fornecer liquidez em vez de só guardar os tokens. Negativo: as '
          'taxas não chegaram para cobrir o IL.',
    ),
    (
      term: 'Gas break-even',
      body:
          'Quantas taxas ainda faltam gerar para cobrir o custo de gás '
          'gasto a abrir a posição. Para v4, o custo de gás só cobre o '
          'mint — increases/decreases/collects posteriores ainda não '
          'estão incluídos.',
    ),
    (
      term: 'Projeção deste mês/ano',
      body:
          'Estende a taxa diária média dos últimos 7 dias até ao fim do '
          'mês/ano — uma tendência, não uma garantia. Só fica fiável '
          'depois de uma semana de histórico (ver nota sobre posições v4 '
          'abaixo).',
    ),
    (
      term: 'Health score (coração)',
      body:
          'Média de 3 sinais: se está dentro do range, a tendência de '
          'fees (últimas 24h vs. média de 7 dias) e o impermanent loss. '
          'Toca no badge no cartão de cada pool para ver os 3 '
          'separadamente.',
    ),
    (
      term: 'Simulador de largura de range',
      body:
          'Backtest contra o histórico de preço já gravado desta posição: '
          'e se tivesses escolhido um range mais estreito ou mais largo? '
          'É uma estimativa, não uma previsão.',
    ),
    (
      term: 'LIVE / SEM ATUALIZAR',
      body:
          'Confirma se o refresh automático está a correr. "Sem '
          'atualizar" aparece quando o último refresh foi há mais tempo '
          'do que o esperado (sem rede, RPC em baixo, app em background '
          'há muito tempo) — os números podem estar desatualizados.',
    ),
    (
      term: 'Atividade',
      body:
          'Histórico de mints, aumentos/diminuições de liquidez e '
          'collects. Só disponível para posições v3 (vem do subgraph) — '
          'para v4 fica sempre vazio, não por falta de eventos.',
    ),
    (
      term: 'Limitações conhecidas das posições v4',
      body:
          'Sem subgraph fiável para v4, tudo vem on-chain + CoinGecko. '
          'Isto cobre bem: range, liquidez, preço e taxas (reclamadas e '
          'não reclamadas) — tudo real. Fica por resolver, de propósito '
          '(arriscado de calcular sem um subgraph): o lucro/perda "desde '
          'a abertura" (fica a 0), e o custo de gás de '
          'increases/decreases/collects posteriores ao mint. Posições v4 '
          'já fechadas também não aparecem na lista de fechadas, por não '
          'terem nenhuma informação útil para mostrar.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(title: const Text('Glossário')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          itemCount: _entries.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final entry = _entries[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.term,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.body,
                    style: TextStyle(
                      fontSize: 12,
                      color: palette.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
