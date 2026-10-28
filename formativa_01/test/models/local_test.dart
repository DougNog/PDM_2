import 'package:flutter_test/flutter_test.dart';
import 'package:formativa_01/models/local.dart';

void main() {
  group('Local', () {
    test('fromMap converte um documento completo', () {
      final local = Local.fromMap('abc', {
        'nome': 'Academia Fitness',
        'categoria': 'Academia',
        'cidade': 'São Paulo',
        'avaliacao': 4.8,
        'distancia': 1, // Firestore pode devolver int
        'horario': '06:00 - 22:00',
        'descricao': 'Completa',
        'favorito': true,
      });

      expect(local.id, 'abc');
      expect(local.nome, 'Academia Fitness');
      expect(local.distancia, 1.0);
      expect(local.favorito, isTrue);
    });

    test('fromMap usa valores padrão para campos ausentes', () {
      final local = Local.fromMap('x', {});

      expect(local.nome, '');
      expect(local.avaliacao, 0);
      expect(local.favorito, isFalse);
    });

    test('toMap não grava o id e mantém os tipos', () {
      const local = Local(
        id: 'id-ignorado',
        nome: 'Iron Gym',
        categoria: 'Academia',
        cidade: 'Jundiaí',
        avaliacao: 4.2,
        distancia: 5.2,
        horario: '06:00 - 22:00',
        descricao: 'Força',
        favorito: false,
      );

      final mapa = local.toMap();

      expect(mapa.containsKey('id'), isFalse);
      expect(mapa['avaliacao'], 4.2);
      expect(Local.fromMap('novo', mapa).nome, 'Iron Gym');
    });

    test('copyWith altera apenas o campo informado', () {
      const local = Local(
        id: '1',
        nome: 'A',
        categoria: 'Mercado',
        cidade: 'Santos',
        avaliacao: 3,
        distancia: 1,
        horario: '24h',
        descricao: '',
        favorito: false,
      );

      final favorito = local.copyWith(favorito: true);

      expect(favorito.favorito, isTrue);
      expect(favorito.nome, 'A');
      expect(favorito.id, '1');
    });
  });
}
