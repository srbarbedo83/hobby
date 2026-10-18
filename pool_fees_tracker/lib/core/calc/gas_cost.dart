/// Interpreta um valor hexadecimal `0x...` devolvido por um RPC EVM
/// (`eth_getTransactionReceipt`, `eth_chainId`, ...) como [BigInt].
/// Devolve 0 para `null`/vazio em vez de rebentar — alguns clientes RPC
/// omitem campos opcionais.
BigInt parseHexBigInt(String? hex) {
  if (hex == null || hex.isEmpty) return BigInt.zero;
  final cleaned = hex.startsWith('0x') || hex.startsWith('0X')
      ? hex.substring(2)
      : hex;
  if (cleaned.isEmpty) return BigInt.zero;
  return BigInt.parse(cleaned, radix: 16);
}

/// Custo de gás (`gasUsed × effectiveGasPrice`) de um recibo de transação.
BigInt receiptGasCostWei({required BigInt gasUsed, required BigInt gasPrice}) {
  return gasUsed * gasPrice;
}

/// Soma o custo de gás de vários recibos — usado para somar todas as
/// transações (mint/collects/burn) de uma posição.
BigInt sumGasCostWei(Iterable<({BigInt gasUsed, BigInt gasPrice})> receipts) {
  var total = BigInt.zero;
  for (final r in receipts) {
    total += receiptGasCostWei(gasUsed: r.gasUsed, gasPrice: r.gasPrice);
  }
  return total;
}
