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

  /// O mesmo para o subgraph Uniswap v4 — protocolo/arquitetura diferente
  /// (singleton `PoolManager` + hooks), subgraph diferente. Só Ethereum por
  /// agora (único confirmado); as outras chains ficam `null` até validarmos
  /// os ids certos.
  String? get uniswapV4SubgraphId => switch (this) {
    Chain.ethereum => 'DiYPVdygkfjDWhbxGSqAQxwBKmfKnkWQojqeM2rkLb3G',
    _ => null,
  };

  /// Endereço do contrato `PositionManager` da Uniswap v4 — ao contrário do
  /// v3, o subgraph v4 não guarda range/liquidez por posição (só o
  /// tokenId), por isso é preciso ler isto on-chain (ver
  /// `uniswap_v4_position_manager_client.dart`). Por isso o modo Live v4
  /// precisa sempre de um RPC URL configurado, ao contrário do v3 (onde o
  /// RPC é só para custo de gás).
  String? get uniswapV4PositionManagerAddress => switch (this) {
    Chain.ethereum => '0xbd216513d74c8cf14cf4747e6aaa6420ff64ee9e',
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
