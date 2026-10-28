import 'package:flutter_test/flutter_test.dart';
import 'package:formativa_01/models/local.dart';
import 'package:formativa_01/utils/constantes.dart';
import 'package:formativa_01/utils/filtros.dart';

Local _local(String nome, String categoria, String cidade, {bool favorito = false}) {
  return Local(
    id: nome,
    nome: nome,
    categoria: categoria,
    cidade: cidade,
    avaliacao: 4,
    distancia: 1,
    horario: '24h',
    descricao: '',
    favorito: favorito,
  );
}

void main() {
  final locais = [
    _local('Academia Fitness', 'Academia', 'São Paulo'),
    _local('Smart Fit', 'Academia', 'São Paulo', favorito: true),
    _local('Proforma Academia', 'Academia', 'Campinas'),
    _local('Farmácia Vida', 'Farmácia', 'Campinas', favorito: true),
    _local('Iron Gym', 'Academia', 'Jundiaí'),
  ];

  List<String> nomes(List<Local> lista) => lista.map((l) => l.nome).toList();

  test('sem filtros retorna todos', () {
    expect(filtrarLocais(locais), hasLength(5));
  });

  test('T02 — pesquisa "Academia" encontra pelo nome e pela categoria', () {
    final resultado = filtrarLocais(locais, texto: 'Academia');
    expect(nomes(resultado), [
      'Academia Fitness',
      'Smart Fit',
      'Proforma Academia',
      'Iron Gym',
    ]);
  });

  test('pesquisa ignora maiúsculas e acentos', () {
    expect(nomes(filtrarLocais(locais, texto: 'FARMACIA')), ['Farmácia Vida']);
  });

  test('T03 — filtro por cidade Campinas', () {
    expect(
      nomes(filtrarLocais(locais, cidade: 'Campinas')),
      ['Proforma Academia', 'Farmácia Vida'],
    );
  });

  test('T04 — filtro por categoria combinado com cidade', () {
    final resultado = filtrarLocais(
      locais,
      cidade: 'Campinas',
      categoria: 'Farmácia',
    );
    expect(nomes(resultado), ['Farmácia Vida']);
  });

  test('filtro de favoritos', () {
    expect(
      nomes(filtrarLocais(locais, somenteFavoritos: true)),
      ['Smart Fit', 'Farmácia Vida'],
    );
  });

  test('valores "Todas"/"Todos" desativam o filtro', () {
    final resultado = filtrarLocais(
      locais,
      cidade: todasCidades,
      categoria: todasCategorias,
    );
    expect(resultado, hasLength(5));
  });

  test('pesquisa sem correspondência retorna lista vazia', () {
    expect(filtrarLocais(locais, texto: 'pizzaria'), isEmpty);
  });
}
