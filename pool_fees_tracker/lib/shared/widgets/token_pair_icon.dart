import 'package:flutter/material.dart';

const Map<String, Color> _tokenColors = {
  'ETH': Color(0xFF627EEA),
  'WETH': Color(0xFF627EEA),
  'WBTC': Color(0xFFF7931A),
  'BTC': Color(0xFFF7931A),
  'USDC': Color(0xFF2775CA),
  'USDT': Color(0xFF26A17B),
  'ARB': Color(0xFF28A0F0),
  'DAI': Color(0xFFF5AC37),
  'MATIC': Color(0xFF8247E5),
};

const Map<String, String> _tokenGlyphs = {
  'ETH': 'Ξ',
  'WETH': 'Ξ',
  'WBTC': '₿',
  'BTC': '₿',
};

Color _colorFor(String symbol) =>
    _tokenColors[symbol.toUpperCase()] ?? const Color(0xFF5B6168);

String _glyphFor(String symbol) =>
    _tokenGlyphs[symbol.toUpperCase()] ?? symbol.substring(0, 1).toUpperCase();

/// Duas moedas sobrepostas representando o par de tokens de uma pool.
class TokenPairIcon extends StatelessWidget {
  final String token0;
  final String token1;
  final double size;

  const TokenPairIcon({
    super.key,
    required this.token0,
    required this.token1,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return SizedBox(
      width: size * 1.55,
      height: size,
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, child: _coin(token0, background)),
          Positioned(
            left: size * 0.6,
            top: 0,
            child: _coin(token1, background),
          ),
        ],
      ),
    );
  }

  Widget _coin(String symbol, Color borderColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _colorFor(symbol),
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        _glyphFor(symbol),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
