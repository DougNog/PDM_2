import 'package:flutter_test/flutter_test.dart';
import 'package:formativa_01/utils/horario.dart';
import 'package:formativa_01/utils/validadores.dart';

void main() {
  group('estaAberto', () {
    final dezDaManha = DateTime(2026, 1, 1, 10);
    final cincoDaManha = DateTime(2026, 1, 1, 5);
    final umaDaManha = DateTime(2026, 1, 1, 1);

    test('dentro e fora do horário', () {
      expect(estaAberto('06:00 - 22:00', dezDaManha), isTrue);
      expect(estaAberto('06:00 - 22:00', cincoDaManha), isFalse);
    });

    test('horário que atravessa a meia-noite', () {
      expect(estaAberto('18:00 - 02:00', umaDaManha), isTrue);
      expect(estaAberto('18:00 - 02:00', dezDaManha), isFalse);
    });

    test('24h está sempre aberto', () {
      expect(estaAberto('24h', umaDaManha), isTrue);
    });

    test('formato desconhecido retorna null', () {
      expect(estaAberto('comercial', dezDaManha), isNull);
      expect(descricaoHorario('comercial', dezDaManha), 'comercial');
    });

    test('descricaoHorario monta o texto do wireframe', () {
      expect(
        descricaoHorario('06:00 - 22:00', dezDaManha),
        'Aberto - 06:00 - 22:00',
      );
    });
  });

  group('Validadores', () {
    test('obrigatorio', () {
      expect(Validadores.obrigatorio('  '), isNotNull);
      expect(Validadores.obrigatorio('Iron Gym'), isNull);
    });

    test('avaliacao aceita vírgula e limita entre 0 e 5', () {
      expect(Validadores.avaliacao('4,5'), isNull);
      expect(Validadores.avaliacao('6'), isNotNull);
      expect(Validadores.avaliacao('abc'), isNotNull);
    });

    test('distancia não aceita negativo', () {
      expect(Validadores.distancia('1.2'), isNull);
      expect(Validadores.distancia('-1'), isNotNull);
    });

    test('horario', () {
      expect(Validadores.horario('06:00 - 22:00'), isNull);
      expect(Validadores.horario('24h'), isNull);
      expect(Validadores.horario('6h às 22h'), isNotNull);
      expect(Validadores.horario('25:00 - 22:00'), isNotNull);
    });
  });
}
