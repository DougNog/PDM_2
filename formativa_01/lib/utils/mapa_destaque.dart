import 'package:flutter/foundation.dart';

import '../models/local.dart';

/// Local que a tela de mapa deve destacar.
///
/// O botão "Ver no mapa" da tela de detalhes preenche este valor e volta para
/// a tela inicial, que escuta as mudanças e centraliza o marcador.
final ValueNotifier<Local?> localDestacado = ValueNotifier<Local?>(null);

/// Gera um número estável a partir de um texto (o hashCode de String pode
/// variar entre execuções).
int sementeDe(String texto) {
  var hash = 17;
  for (final codigo in texto.codeUnits) {
    hash = (hash * 31 + codigo) & 0x7fffffff;
  }
  return hash;
}

/// Posição relativa (0 a 1) do marcador de um local no mapa ilustrado.
/// Como depende só do ID, o marcador fica sempre no mesmo lugar.
({double x, double y}) posicaoNoMapa(String id) {
  final hash = sementeDe(id);
  final x = 0.10 + (hash % 1000) / 1000 * 0.80;
  final y = 0.12 + ((hash ~/ 1000) % 1000) / 1000 * 0.76;
  return (x: x, y: y);
}
