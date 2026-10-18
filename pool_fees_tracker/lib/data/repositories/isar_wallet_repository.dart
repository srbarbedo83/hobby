import 'package:isar_community/isar.dart';

import '../local/wallet.dart';
import 'wallet_repository.dart';

class IsarWalletRepository implements WalletRepository {
  final Isar _isar;

  IsarWalletRepository(this._isar);

  @override
  Future<List<Wallet>> getAll() =>
      _isar.wallets.where().sortByAddedAt().findAll();

  @override
  Future<void> upsert({required String address, required String label}) async {
    final normalized = address.trim().toLowerCase();
    await _isar.writeTxn(() async {
      final existing = await _isar.wallets
          .filter()
          .addressEqualTo(normalized)
          .findFirst();
      final wallet = existing ?? Wallet();
      wallet.address = normalized;
      wallet.label = label.trim().isEmpty
          ? _shortAddress(normalized)
          : label.trim();
      wallet.addedAt = existing?.addedAt ?? DateTime.now();
      await _isar.wallets.put(wallet);
    });
  }

  @override
  Future<void> remove(String address) async {
    final normalized = address.trim().toLowerCase();
    await _isar.writeTxn(() async {
      final existing = await _isar.wallets
          .filter()
          .addressEqualTo(normalized)
          .findFirst();
      if (existing != null) await _isar.wallets.delete(existing.id);
    });
  }
}

String _shortAddress(String address) {
  if (address.length <= 10) return address;
  return '${address.substring(0, 6)}…${address.substring(address.length - 4)}';
}
