import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formativa_01/models/local.dart';
import 'package:formativa_01/services/dados_exemplo.dart';
import 'package:formativa_01/services/local_service.dart';
import 'package:formativa_01/utils/constantes.dart';

const _novo = Local(
  id: '',
  nome: 'Padaria Central',
  categoria: 'Mercado',
  cidade: 'Santos',
  avaliacao: 4.0,
  distancia: 0.8,
  horario: '06:00 - 20:00',
  descricao: 'Pães e cafés.',
  favorito: false,
);

/// Os testes usam um Firestore falso, em memória, com a mesma API do real.
void main() {
  late FakeFirebaseFirestore banco;
  late LocalService service;

  Future<Map<String, dynamic>?> documento(String id) async {
    final doc = await banco.collection('locais').doc(id).get();
    return doc.data();
  }

  setUp(() {
    banco = FakeFirebaseFirestore();
    service = LocalService.comBanco(banco);
  });

  test('coleção vazia: a lista começa vazia', () async {
    expect(await service.listarLocais().first, isEmpty);
  });

  test('cadastrarExemplos grava todos os locais na coleção locais', () async {
    await service.cadastrarExemplos();

    final docs = await banco.collection('locais').get();
    expect(docs.size, locaisExemplo.length);
    expect(docs.size, greaterThanOrEqualTo(10), reason: 'checklist');
  });

  test('T01 — lê os documentos do Firestore, ordenados por nome', () async {
    await service.cadastrarExemplos();

    final locais = await service.listarLocais().first;

    expect(locais, hasLength(locaisExemplo.length));
    expect(locais.first.nome, 'Academia Fitness');
    expect(locais.map((l) => l.id).toSet(), hasLength(locais.length));
  });

  test('lê documentos criados direto no Firestore (ex.: pelo Console)',
      () async {
    await banco.collection('locais').doc('manual').set({
      'nome': 'Criado no Console',
      'categoria': 'Academia',
      'cidade': 'Campinas',
      'avaliacao': 5,
      'distancia': 2,
    });

    final local = (await service.listarLocais().first).single;

    expect(local.id, 'manual');
    expect(local.avaliacao, 5.0);
    expect(local.horario, '');
    expect(local.favorito, isFalse);
  });

  test('cada cidade tem pelo menos 5 locais de exemplo (5 marcadores)', () {
    for (final cidade in cidades) {
      final daCidade = locaisExemplo.where((l) => l.cidade == cidade);
      expect(daCidade, hasLength(greaterThanOrEqualTo(5)), reason: cidade);
    }
  });

  test('T05 — cadastrar cria um documento com ID automático', () async {
    final id = await service.adicionar(_novo);

    expect(id, isNotEmpty);
    expect(await documento(id), _novo.toMap());
    final locais = await service.listarLocais().first;
    expect(locais.single.id, id);
  });

  test('a lista é atualizada automaticamente após uma alteração', () async {
    await service.cadastrarExemplos();
    final emissoes = service.listarLocais().map((l) => l.length);
    final esperado = expectLater(
      emissoes,
      emitsInOrder([locaisExemplo.length, locaisExemplo.length + 1]),
    );

    await Future<void>.delayed(Duration.zero);
    await service.adicionar(_novo);
    await esperado;
  });

  test('T07 — editar altera o documento no Firestore', () async {
    final id = await service.adicionar(_novo);
    final original = (await service.observarLocal(id).first)!;

    await service.atualizar(original.copyWith(horario: '07:00 - 21:00'));

    expect((await documento(id))!['horario'], '07:00 - 21:00');
    expect((await service.observarLocal(id).first)!.horario, '07:00 - 21:00');
  });

  test('T08 — excluir remove o documento', () async {
    final id = await service.adicionar(_novo);

    await service.excluir(id);

    expect(await documento(id), isNull);
    expect(await service.observarLocal(id).first, isNull);
    expect(await service.listarLocais().first, isEmpty);
  });

  test('T09 — favoritar altera só o campo favorito', () async {
    final id = await service.adicionar(_novo);

    await service.alterarFavorito(id, true);
    expect(await documento(id), {..._novo.toMap(), 'favorito': true});

    await service.alterarFavorito(id, false);
    expect((await service.observarLocal(id).first)!.favorito, isFalse);
  });

  test('T11 — editar ou favoritar um documento inexistente gera erro',
      () async {
    expect(
      service.alterarFavorito('nao-existe', true),
      throwsA(isA<FirebaseException>()),
    );
    expect(
      service.atualizar(_novo.copyWith(id: 'nao-existe')),
      throwsA(isA<FirebaseException>()),
    );
  });
}
