import '../local/wallet.dart';

abstract class WalletRepository {
  Future<List<Wallet>> getAll();

  /// Adiciona ou atualiza (por endereço) uma carteira seguida, só-leitura.
  Future<void> upsert({required String address, required String label});

  Future<void> remove(String address);
}
