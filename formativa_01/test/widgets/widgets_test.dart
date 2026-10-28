import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formativa_01/dialogs/confirm_delete.dart';
import 'package:formativa_01/models/local.dart';
import 'package:formativa_01/widgets/local_card.dart';
import 'package:formativa_01/widgets/local_form.dart';

const _local = Local(
  id: '1',
  nome: 'Academia Fitness',
  categoria: 'Academia',
  cidade: 'São Paulo',
  avaliacao: 4.8,
  distancia: 1.2,
  horario: '06:00 - 22:00',
  descricao: 'Completa',
  favorito: false,
);

Widget _app(Widget filho) => MaterialApp(home: Scaffold(body: filho));

void main() {
  testWidgets('LocalCard exibe nome, categoria, distância e avaliação',
      (tester) async {
    var abriu = false;
    await tester.pumpWidget(_app(LocalCard(
      local: _local,
      onTap: () => abriu = true,
      onEditar: () {},
      onExcluir: () {},
    )));

    expect(find.text('Academia Fitness'), findsOneWidget);
    expect(find.text('Academia · São Paulo'), findsOneWidget);
    expect(find.text('1.2 km'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);

    await tester.tap(find.text('Academia Fitness'));
    expect(abriu, isTrue);
  });

  testWidgets('LocalCard oferece editar e excluir no menu', (tester) async {
    String? acao;
    await tester.pumpWidget(_app(LocalCard(
      local: _local,
      onTap: () {},
      onEditar: () => acao = 'editar',
      onExcluir: () => acao = 'excluir',
    )));

    await tester.tap(find.byTooltip('Opções'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(acao, 'excluir');
  });

  testWidgets('LocalForm não salva com campos vazios', (tester) async {
    Local? salvo;
    await tester.pumpWidget(_app(LocalForm(onSalvar: (l) => salvo = l)));

    await tester.ensureVisible(find.byKey(const Key('botao_salvar')));
    await tester.tap(find.byKey(const Key('botao_salvar')));
    await tester.pump();

    expect(salvo, isNull);
    expect(find.text('Campo obrigatório'), findsWidgets);
  });

  testWidgets('LocalForm cadastra um local válido', (tester) async {
    Local? salvo;
    await tester.pumpWidget(_app(LocalForm(
      cidadePadrao: 'Campinas',
      onSalvar: (l) => salvo = l,
    )));

    await tester.enterText(find.byKey(const Key('campo_nome')), 'Novo Lugar');
    await tester.enterText(find.byKey(const Key('campo_avaliacao')), '4,5');
    await tester.enterText(find.byKey(const Key('campo_distancia')), '2');
    await tester.enterText(find.byKey(const Key('campo_horario')), '08:00 - 18:00');
    await tester.enterText(find.byKey(const Key('campo_descricao')), 'Teste');
    await tester.ensureVisible(find.byKey(const Key('botao_salvar')));
    await tester.tap(find.byKey(const Key('botao_salvar')));
    await tester.pump();

    expect(salvo, isNotNull);
    expect(salvo!.nome, 'Novo Lugar');
    expect(salvo!.cidade, 'Campinas');
    expect(salvo!.avaliacao, 4.5);
    expect(salvo!.favorito, isFalse);
  });

  testWidgets('LocalForm em modo edição mantém o id e o favorito',
      (tester) async {
    Local? salvo;
    await tester.pumpWidget(_app(LocalForm(
      local: _local.copyWith(favorito: true),
      onSalvar: (l) => salvo = l,
    )));

    expect(find.text('Editar local'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('campo_horario')), '07:00 - 23:00');
    await tester.ensureVisible(find.byKey(const Key('botao_salvar')));
    await tester.tap(find.byKey(const Key('botao_salvar')));
    await tester.pump();

    expect(salvo!.id, '1');
    expect(salvo!.favorito, isTrue);
    expect(salvo!.horario, '07:00 - 23:00');
  });

  testWidgets('confirmarExclusao retorna false ao cancelar e true ao confirmar',
      (tester) async {
    final resultados = <bool>[];
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async =>
              resultados.add(await confirmarExclusao(context, 'Iron Gym')),
          child: const Text('abrir'),
        ),
      ),
    ));

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir local?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(resultados, [false, true]);
  });
}
