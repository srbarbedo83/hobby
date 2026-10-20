import 'package:flutter/material.dart';

/// Rede EVM suportada. O subgraph id e o RPC ficam associados aqui para que
/// o resto da app nunca tenha de saber detalhes de endpoints.
enum Chain { ethereum, arbitrum, base, optimism, polygon }

extension ChainInfo on Chain {
  String get displayName => switch (this) {
    Chain.ethereum => 'Ethereum',
    Chain.arbitrum => 'Arbitrum',
    Chain.base => 'Base',
    Chain.optimism => 'Optimism',
    Chain.polygon => 'Polygon',
  };

  /// Abreviação curta para badges compactos (listas de pools) — o nome
  /// completo ([displayName]) é usado onde há mais espaço, como o ecrã de
  /// detalhe.
  String get shortLabel => switch (this) {
    Chain.ethereum => 'ETH',
    Chain.arbitrum => 'ARB',
    Chain.base => 'BASE',
    Chain.optimism => 'OP',
    Chain.polygon => 'POLY',
  };

  String get nativeSymbol => switch (this) {
    Chain.polygon => 'MATIC',
    _ => 'ETH',
  };

  Color get accentColor => switch (this) {
    Chain.ethereum => const Color(0xFF627EEA),
    Chain.arbitrum => const Color(0xFF28A0F0),
    Chain.base => const Color(0xFF0052FF),
    Chain.optimism => const Color(0xFFFF0420),
    Chain.polygon => const Color(0xFF8247E5),
  };

  /// Subgraph id publicado pela Uniswap na rede descentralizada do The Graph
  /// (usado como sufixo de `https://gateway.thegraph.com/api/<key>/subgraphs/id/<id>`).
  /// Preenchido só para as chains com subgraph oficial de Uniswap v3.
  String? get uniswapV3SubgraphId => switch (this) {
    Chain.ethereum => '5zvR82QoaXYFyDEKLZ9t6v9adgnptxYpKpSbxtgVENFV',
    Chain.arbitrum => 'FbCGRftH4a3yZugY7TnbYgPJVEv2LvMT6oF1fxPe9aJM',
    Chain.base => 'GqzP4Xaehti8KSfQmv3ZctFSjnSUYZ4En5NRsiTbvZpz',
    Chain.optimism => 'Cghf4LfVqPiFw6fp6Y5X5Ubc8UpmUhSfJL82zwiBFLaj',
    Chain.polygon => '3hCPRGf4z88VC5rsBKU5AA9FBBq5nF3jbKJG7VZCbhjm',
  };

  /// Endereço do contrato `PositionManager` da Uniswap v4 — ao contrário do
  /// v3, não há subgraph fiável para posições v4 (ver nota em
  /// `uniswap_v4_position_manager_client.dart`: mostrou-se globalmente não
  /// fiável nesta sessão), por isso tudo é lido on-chain. Por isso o modo
  /// Live v4 precisa sempre de um RPC URL configurado para a MESMA chain
  /// (ver `AppSettings.v4RpcUrlOverrides`), ao contrário do v3 (onde o RPC
  /// é só para custo de gás). Confirmado para Ethereum e Arbitrum (via
  /// Arbiscan + a página oficial de deployments da Uniswap); as outras
  /// chains ficam `null` até validarmos os endereços certos.
  String? get uniswapV4PositionManagerAddress => switch (this) {
    Chain.ethereum => '0xbd216513d74c8cf14cf4747e6aaa6420ff64ee9e',
    Chain.arbitrum => '0xd88f38f930b7952f2db2432cb002e7abbf3dd869',
    _ => null,
  };

  /// Endereço do contrato `StateView` da Uniswap v4 — lens on-chain para
  /// ler o estado de uma pool (tick atual, preço) sem precisar de um
  /// subgraph. Confirmado via a página oficial de deployments da Uniswap
  /// (https://developers.uniswap.org/docs/protocols/v4/deployments).
  String? get uniswapV4StateViewAddress => switch (this) {
    Chain.ethereum => '0x7ffe42c4a5deea5b0fec41c94c136cf115597227',
    Chain.arbitrum => '0x76fd297e2d437cd7f76d50f01afe6160f86e9990',
    _ => null,
  };

  /// Id da plataforma CoinGecko (para o endpoint `/simple/token_price/<id>`)
  /// — usado para o preço USD dos tokens de posições v4, já que não há
  /// subgraph fiável para isso (ver `uniswapV4PositionManagerAddress`).
  String? get coingeckoPlatformId => switch (this) {
    Chain.ethereum => 'ethereum',
    Chain.arbitrum => 'arbitrum-one',
    _ => null,
  };

  /// EVM chain id (EIP-155) — usado para confirmar a que chain um RPC URL
  /// responde de facto (`eth_chainId`), já que o utilizador só configura
  /// um URL e pode ter várias chains selecionadas.
  int get evmChainId => switch (this) {
    Chain.ethereum => 1,
    Chain.arbitrum => 42161,
    Chain.base => 8453,
    Chain.optimism => 10,
    Chain.polygon => 137,
  };
}

Chain? chainFromEvmChainId(int id) {
  for (final chain in Chain.values) {
    if (chain.evmChainId == id) return chain;
  }
  return null;
}
