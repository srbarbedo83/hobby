import 'package:flutter/material.dart';

import '../../core/calc/range_health.dart';
import '../../core/theme/app_theme.dart';

extension RangeStatusPresentation on RangeStatus {
  /// A cor depende do tema ativo (dark/light) — por isso recebe a
  /// [AppPalette] em vez de ser uma constante fixa.
  Color colorFor(AppPalette palette) => switch (this) {
    RangeStatus.inRange => palette.positive,
    RangeStatus.nearEdge => palette.warning,
    RangeStatus.outOfRange => palette.negative,
  };

  String get label => switch (this) {
    RangeStatus.inRange => 'Em range',
    RangeStatus.nearEdge => 'Perto da margem',
    RangeStatus.outOfRange => 'Fora do range',
  };
}

/// Pequena pill "• In range" usada nas listas de pools.
class RangeStatusPill extends StatelessWidget {
  final RangeStatus status;

  const RangeStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.colorFor(AppPalette.of(context));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(status.label, style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}

/// Barra que mostra onde o preço atual está dentro do range da posição,
/// usada no ecrã de detalhe (Krystal/Revert-style "range health").
class RangeHealthBar extends StatelessWidget {
  final RangeHealth health;

  /// Preço mínimo/máximo do range, já formatados (ex.: "1,840.12") — o
  /// range real criado no mint da posição (tickLower/tickUpper são
  /// imutáveis), não só a fração 0..1. `null` quando não há decimais
  /// fiáveis para calcular (não deve acontecer, mas evita rebentar).
  final String? minPriceLabel;
  final String? maxPriceLabel;

  /// "USDC per ETH", para dar contexto aos números acima.
  final String? priceUnitLabel;

  const RangeHealthBar({
    super.key,
    required this.health,
    this.minPriceLabel,
    this.maxPriceLabel,
    this.priceUnitLabel,
  });

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final statusColor = health.status.colorFor(palette);
    // Pedido do utilizador: fora do range, a bolinha fica colada à
    // margem (perde-se "quanto" está fora) — passa a poder sair da
    // barra colorida, até uma margem reservada de cada lado, comprimindo
    // o excesso em vez de cortá-lo de repente.
    const overflowFraction = 0.25;
    final dotFraction = rangeDotPositionFraction(
      health.positionFraction,
      overflowFraction: overflowFraction,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Range de preço',
              style: TextStyle(fontSize: 11.5, color: palette.textSecondary),
            ),
            RangeStatusPill(status: health.status),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            // Margem reservada de cada lado da barra, para a bolinha ter
            // para onde ir quando está fora do range.
            final sideMargin = constraints.maxWidth * overflowFraction;
            final trackWidth = constraints.maxWidth - sideMargin * 2;
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sideMargin),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      // Pedido do utilizador: a barra era uma cor sólida
                      // — passa a um degradê que também dá contexto:
                      // tons do negative nas pontas (fora do range) e do
                      // positive no meio (dentro do range).
                      gradient: LinearGradient(
                        colors: [
                          palette.negative.withValues(alpha: 0.35),
                          palette.positive.withValues(alpha: 0.35),
                          palette.negative.withValues(alpha: 0.35),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Builder(
                  builder: (context) {
                    final dotX = sideMargin + trackWidth * dotFraction - 5;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: dotX.clamp(0, constraints.maxWidth - 10),
                      ),
                      child: Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.only(top: -1),
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: palette.background,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              minPriceLabel == null ? 'Mín' : 'Mín $minPriceLabel',
              style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
            ),
            Text(
              maxPriceLabel == null ? 'Máx' : 'Máx $maxPriceLabel',
              style: TextStyle(fontSize: 9.5, color: palette.textTertiary),
            ),
          ],
        ),
        if (priceUnitLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            priceUnitLabel!,
            style: TextStyle(fontSize: 9, color: palette.textTertiary),
          ),
        ],
      ],
    );
  }
}
