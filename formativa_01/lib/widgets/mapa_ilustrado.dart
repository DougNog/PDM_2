import 'dart:math';

import 'package:flutter/material.dart';

import '../models/local.dart';
import '../utils/mapa_destaque.dart';

/// Representação de mapa desenhada no próprio Flutter (sem API de mapas).
///
/// Cada cidade tem um traçado diferente, e cada local recebe um marcador em
/// posição fixa calculada a partir do seu ID. Aceita arrastar e dar zoom.
class MapaIlustrado extends StatelessWidget {
  const MapaIlustrado({
    super.key,
    required this.cidade,
    required this.locais,
    required this.controlador,
    required this.selecionadoId,
    required this.onSelecionar,
    required this.onAbrir,
    this.satelite = false,
  });

  final String cidade;
  final List<Local> locais;
  final TransformationController controlador;
  final String? selecionadoId;
  final ValueChanged<String?> onSelecionar;
  final ValueChanged<Local> onAbrir;
  final bool satelite;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricoes) {
        final tamanho = restricoes.biggest;
        // O selecionado é desenhado por último para ficar por cima.
        final ordenados = [...locais]..sort((a, b) {
            if (a.id == selecionadoId) return 1;
            if (b.id == selecionadoId) return -1;
            return 0;
          });

        return InteractiveViewer(
          transformationController: controlador,
          minScale: 1,
          maxScale: 4,
          child: GestureDetector(
            onTap: () => onSelecionar(null),
            child: SizedBox.fromSize(
              size: tamanho,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MapaPainter(
                        semente: sementeDe(cidade),
                        satelite: satelite,
                      ),
                    ),
                  ),
                  Positioned(
                    left: tamanho.width / 2 - 28,
                    top: tamanho.height / 2 - 28,
                    child: const _PosicaoUsuario(),
                  ),
                  for (final local in ordenados)
                    _marcador(local, tamanho),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _marcador(Local local, Size tamanho) {
    final posicao = posicaoNoMapa(local.id);
    final selecionado = local.id == selecionadoId;
    const larguraEtiqueta = 180.0;
    const alturaMarcador = 90.0;

    // A ponta do ícone (base da coluna) fica exatamente na posição do local.
    return Positioned(
      left: posicao.x * tamanho.width - larguraEtiqueta / 2,
      top: posicao.y * tamanho.height - alturaMarcador + 4,
      width: larguraEtiqueta,
      height: alturaMarcador,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (selecionado)
            GestureDetector(
              onTap: () => onAbrir(local),
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        local.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ),
          GestureDetector(
            onTap: () => onSelecionar(local.id),
            child: Icon(
              Icons.location_on,
              size: 40,
              color: selecionado ? Colors.red.shade600 : Colors.grey.shade800,
              shadows: const [Shadow(color: Colors.black38, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}

class _PosicaoUsuario extends StatelessWidget {
  const _PosicaoUsuario();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withValues(alpha: 0.18),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
      ),
    );
  }
}

class _MapaPainter extends CustomPainter {
  _MapaPainter({required this.semente, required this.satelite});

  final int semente;
  final bool satelite;

  @override
  void paint(Canvas canvas, Size size) {
    final aleatorio = Random(semente);

    final corRua = satelite ? const Color(0xFF8A8F86) : Colors.white;
    final corQuarteirao =
        satelite ? const Color(0xFF5E6B52) : const Color(0xFFE7E8EA);
    final corParque =
        satelite ? const Color(0xFF3F5A34) : const Color(0xFFD6E8D2);
    final corRio = satelite ? const Color(0xFF2F4A5C) : const Color(0xFFBFC4C9);

    canvas.drawRect(Offset.zero & size, Paint()..color = corRua);

    // Quarteirões: grade com pequenas variações de tamanho.
    final quarteirao = Paint()..color = corQuarteirao;
    const passo = 44.0;
    for (var x = 0.0; x < size.width; x += passo) {
      for (var y = 0.0; y < size.height; y += passo) {
        final folga = 4 + aleatorio.nextDouble() * 3;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + folga, y + folga, passo - folga * 2, passo - folga * 2),
            const Radius.circular(3),
          ),
          quarteirao,
        );
      }
    }

    // Parque.
    final parque = Rect.fromLTWH(
      size.width * (0.05 + aleatorio.nextDouble() * 0.5),
      size.height * (0.55 + aleatorio.nextDouble() * 0.25),
      size.width * 0.3,
      size.height * 0.12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(parque, const Radius.circular(10)),
      Paint()..color = corParque,
    );

    // Rio cruzando o mapa de cima para baixo.
    final rio = Path()
      ..moveTo(size.width * aleatorio.nextDouble() * 0.3, 0)
      ..cubicTo(
        size.width * (0.1 + aleatorio.nextDouble() * 0.4),
        size.height * 0.35,
        size.width * (0.2 + aleatorio.nextDouble() * 0.5),
        size.height * 0.65,
        size.width * (0.5 + aleatorio.nextDouble() * 0.4),
        size.height,
      );
    canvas.drawPath(
      rio,
      Paint()
        ..color = corRio
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22,
    );

    // Avenidas diagonais.
    final avenida = Paint()
      ..color = corRua
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(0, size.height * aleatorio.nextDouble()),
        Offset(size.width, size.height * aleatorio.nextDouble()),
        avenida,
      );
    }
    canvas.drawLine(
      Offset(size.width * aleatorio.nextDouble(), 0),
      Offset(size.width * aleatorio.nextDouble(), size.height),
      avenida,
    );
  }

  @override
  bool shouldRepaint(_MapaPainter antigo) =>
      antigo.semente != semente || antigo.satelite != satelite;
}
