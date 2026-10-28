import 'package:flutter/material.dart';

import '../models/local.dart';
import '../utils/constantes.dart';
import 'imagem_placeholder.dart';

enum AcaoLocal { editar, excluir }

/// Item da lista de resultados: nome, categoria, distância e avaliação.
class LocalCard extends StatelessWidget {
  const LocalCard({
    super.key,
    required this.local,
    required this.onTap,
    required this.onEditar,
    required this.onExcluir,
  });

  final Local local;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final estiloSecundario = TextStyle(fontSize: 12, color: Colors.grey.shade700);

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ImagemPlaceholder(
                largura: 72,
                altura: 72,
                icone: iconeCategoria(local.categoria),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            local.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (local.favorito) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.favorite, size: 14, color: Colors.red),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${local.categoria} · ${local.cidade}', style: estiloSecundario),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 14),
                        const SizedBox(width: 2),
                        Text('${local.distancia.toStringAsFixed(1)} km',
                            style: estiloSecundario),
                        const SizedBox(width: 12),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(local.avaliacao.toStringAsFixed(1),
                            style: estiloSecundario),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<AcaoLocal>(
                tooltip: 'Opções',
                onSelected: (acao) {
                  switch (acao) {
                    case AcaoLocal.editar:
                      onEditar();
                    case AcaoLocal.excluir:
                      onExcluir();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: AcaoLocal.editar,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                    ),
                  ),
                  PopupMenuItem(
                    value: AcaoLocal.excluir,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Excluir'),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
