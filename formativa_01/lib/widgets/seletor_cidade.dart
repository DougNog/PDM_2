import 'package:flutter/material.dart';

import '../utils/constantes.dart';

/// Lista de cidades em um Bottom Sheet. Retorna a cidade escolhida ou `null`.
///
/// Com [incluirTodas], acrescenta a opção "Todas" (usada no filtro).
Future<String?> selecionarCidade(
  BuildContext context, {
  required String atual,
  bool incluirTodas = false,
}) {
  final opcoes = [if (incluirTodas) todasCidades, ...cidades];

  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Selecione a cidade',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          for (final cidade in opcoes)
            ListTile(
              leading: Icon(
                cidade == todasCidades ? Icons.public : Icons.location_city,
              ),
              title: Text(cidade == todasCidades ? 'Todas as cidades' : cidade),
              trailing: cidade == atual
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () => Navigator.pop(context, cidade),
            ),
        ],
      ),
    ),
  );
}
