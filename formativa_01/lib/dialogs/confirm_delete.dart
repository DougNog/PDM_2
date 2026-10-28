import 'package:flutter/material.dart';

/// Pede confirmação antes de excluir. Retorna `true` apenas se o usuário
/// tocar em "Excluir".
Future<bool> confirmarExclusao(BuildContext context, String nomeLocal) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Excluir local?'),
        content: Text(
          '"$nomeLocal" será removido da lista. '
          'Essa ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
  return confirmou == true;
}
