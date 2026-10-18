import 'package:flutter/material.dart';

class AddWalletResult {
  final String address;
  final String label;

  const AddWalletResult(this.address, this.label);
}

Future<AddWalletResult?> showAddWalletDialog(BuildContext context) {
  final addressController = TextEditingController();
  final labelController = TextEditingController();

  return showDialog<AddWalletResult>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Adicionar wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Endereço (0x…)'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Nome (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final address = addressController.text.trim();
              if (address.isEmpty) return;
              Navigator.of(context)
                  .pop(AddWalletResult(address, labelController.text.trim()));
            },
            child: const Text('Adicionar'),
          ),
        ],
      );
    },
  );
}
