/// Validações do formulário de local. Retornam a mensagem de erro ou `null`.
class Validadores {
  static double? lerDecimal(String? valor) {
    return double.tryParse((valor ?? '').trim().replaceAll(',', '.'));
  }

  static String? obrigatorio(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Campo obrigatório';
    return null;
  }

  static String? avaliacao(String? valor) {
    final numero = lerDecimal(valor);
    if (numero == null) return 'Informe um número';
    if (numero < 0 || numero > 5) return 'Use um valor entre 0 e 5';
    return null;
  }

  static String? distancia(String? valor) {
    final numero = lerDecimal(valor);
    if (numero == null) return 'Informe um número';
    if (numero < 0) return 'A distância não pode ser negativa';
    return null;
  }

  static String? horario(String? valor) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return 'Campo obrigatório';
    if (texto.toLowerCase() == '24h') return null;
    final formato = RegExp(r'^([01]\d|2[0-3]):[0-5]\d - ([01]\d|2[0-3]):[0-5]\d$');
    if (!formato.hasMatch(texto)) return 'Use o formato 06:00 - 22:00 ou 24h';
    return null;
  }
}
