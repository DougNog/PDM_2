import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formativa_01/models/local.dart';
import 'package:formativa_01/screens/detalhes_screen.dart';
import 'package:formativa_01/screens/mapa_screen.dart';
import 'package:formativa_01/screens/resultados_screen.dart';
import 'package:formativa_01/services/dados_exemplo.dart';
import 'package:formativa_01/services/local_service.dart';
import 'package:formativa_01/utils/constantes.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

const _local = Local(
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

/// As telas usam `LocalService()`; aqui ele passa a apontar para um Firestore
/// falso, então o caminho completo banco → serviço → tela é testado.
void main() {
  late FakeFirebaseFirestore banco;
  late LocalService service;

  setUp(() {
    banco = FakeFirebaseFirestore();
    LocalService.bancoPadrao = banco;
    service = LocalService();
  });

  tearDown(() => LocalService.bancoPadrao = null);

  Future<void> abrir(WidgetTester tester, Widget tela) async {
    await tester.pumpWidget(MaterialApp(home: tela));
    await tester.pumpAndSettle();
  }

  Future<int> totalDocumentos() async =>
      (await banco.collection('locais').get()).size;

  testWidgets('Mapa conta os locais da cidade vindos do Firestore',
      (tester) async {
    await service.cadastrarExemplos();

    await abrir(tester, const MapaScreen());

    expect(find.text('5 locais em São Paulo'), findsOneWidget);
  });

  testWidgets('T01/T03 — Resultados lista os documentos da cidade',
      (tester) async {
    await service.cadastrarExemplos();

    await abrir(tester, const ResultadosScreen(cidade: 'Campinas'));

    expect(find.text('Farmácia Vida'), findsOneWidget);
    expect(find.text('Academia Fitness'), findsNothing);
  });

  testWidgets('coleção vazia: botão grava os locais de exemplo no Firestore',
      (tester) async {
    await abrir(tester, const ResultadosScreen(cidade: todasCidades));
    expect(find.text('Nenhum local cadastrado.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('botao_exemplos')));
    await tester.pumpAndSettle();

    expect(await totalDocumentos(), locaisExemplo.length);
    expect(find.text('Locais de exemplo cadastrados.'), findsOneWidget);
    expect(find.text('Academia Fitness'), findsOneWidget);
  });

  testWidgets('T08 — excluir pela lista remove o documento após confirmar',
      (tester) async {
    await service.adicionar(_local);
    await abrir(tester, const ResultadosScreen(cidade: todasCidades));

    await tester.tap(find.byTooltip('Opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(await totalDocumentos(), 0);
    expect(find.text('"Padaria Central" excluído.'), findsOneWidget);
    expect(find.text('Nenhum local cadastrado.'), findsOneWidget);
  });

  testWidgets('T09 — o coração altera o campo favorito no Firestore',
      (tester) async {
    final id = await service.adicionar(_local);
    await abrir(tester, DetalhesScreen(local: _local.copyWith(id: id)));

    await tester.tap(find.byKey(const Key('botao_favorito')));
    await tester.pumpAndSettle();

    final doc = await banco.collection('locais').doc(id).get();
    expect(doc.data()!['favorito'], isTrue);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('Adicionado aos favoritos.'), findsOneWidget);
  });

  testWidgets('T11 — erro do Firestore aparece como mensagem', (tester) async {
    final id = await service.adicionar(_local);
    whenCalling(Invocation.method(#update, null))
        .on(banco.collection('locais').doc(id))
        .thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ));
    await abrir(tester, DetalhesScreen(local: _local.copyWith(id: id)));

    await tester.tap(find.byKey(const Key('botao_favorito')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Erro ao atualizar o favorito.'), findsOneWidget);
    final doc = await banco.collection('locais').doc(id).get();
    expect(doc.data()!['favorito'], isFalse);
  });
}
