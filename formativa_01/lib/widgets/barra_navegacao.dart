import 'package:flutter/material.dart';

import '../screens/resultados_screen.dart';
import '../utils/constantes.dart';

enum AbaNavegacao { mapa, favoritos, perfil }

/// Barra inferior do wireframe (Mapa, Favoritos, Perfil), usada nas três telas.
class BarraNavegacao extends StatelessWidget {
  const BarraNavegacao({super.key, this.atual = AbaNavegacao.mapa});

  final AbaNavegacao atual;

  void _selecionar(BuildContext context, int indice) {
    final navegador = Navigator.of(context);
    switch (AbaNavegacao.values[indice]) {
      case AbaNavegacao.mapa:
        navegador.popUntil((rota) => rota.isFirst);
      case AbaNavegacao.favoritos:
        if (atual == AbaNavegacao.favoritos) return;
        navegador.popUntil((rota) => rota.isFirst);
        navegador.push(
          MaterialPageRoute(
            builder: (_) => const ResultadosScreen(
              cidade: todasCidades,
              somenteFavoritos: true,
            ),
          ),
        );
      case AbaNavegacao.perfil:
        _mostrarPerfil(context);
    }
  }

  void _mostrarPerfil(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
              SizedBox(height: 12),
              Text(
                'Visitante',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Login e perfil de usuário ficam como extensão '
                '(Desafio nível 3 — Autenticação).',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: atual.index,
      backgroundColor: Colors.white,
      height: 64,
      onDestinationSelected: (indice) => _selecionar(context, indice),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
