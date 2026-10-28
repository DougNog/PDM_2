/// Interpreta horários no formato "HH:MM - HH:MM" ou "24h".
///
/// Retorna `null` quando o texto não segue nenhum desses formatos.
bool? estaAberto(String horario, DateTime agora) {
  final texto = horario.trim().toLowerCase();
  if (texto == '24h' || texto == '24 horas') return true;

  final partes = RegExp(r'^(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})$')
      .firstMatch(texto);
  if (partes == null) return null;

  int minutos(int grupoHora) =>
      int.parse(partes.group(grupoHora)!) * 60 +
      int.parse(partes.group(grupoHora + 1)!);

  final abertura = minutos(1);
  final fechamento = minutos(3);
  final atual = agora.hour * 60 + agora.minute;

  if (abertura <= fechamento) {
    return atual >= abertura && atual < fechamento;
  }
  // Horário que atravessa a meia-noite, ex.: "18:00 - 02:00".
  return atual >= abertura || atual < fechamento;
}

String descricaoHorario(String horario, DateTime agora) {
  final aberto = estaAberto(horario, agora);
  if (aberto == null) return horario;
  return '${aberto ? 'Aberto' : 'Fechado'} - $horario';
}
