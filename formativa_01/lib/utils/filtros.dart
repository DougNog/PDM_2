import '../models/local.dart';
import 'constantes.dart';

/// Remove acentos e coloca em minúsculas, para que "jundiai" encontre "Jundiaí".
String normalizar(String texto) {
  const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const semAcento = 'aaaaaeeeeiiiiooooouuuucn';
  final minusculo = texto.toLowerCase().trim();
  final buffer = StringBuffer();
  for (final caractere in minusculo.split('')) {
    final indice = comAcento.indexOf(caractere);
    buffer.write(indice >= 0 ? semAcento[indice] : caractere);
  }
  return buffer.toString();
}

/// Aplica pesquisa e filtros sobre a lista recebida do serviço.
List<Local> filtrarLocais(
  List<Local> locais, {
  String texto = '',
  String cidade = todasCidades,
  String categoria = todasCategorias,
  bool somenteFavoritos = false,
}) {
  final termo = normalizar(texto);

  return locais.where((local) {
    final correspondeCidade = cidade == todasCidades || local.cidade == cidade;

    final correspondeCategoria =
        categoria == todasCategorias || local.categoria == categoria;

    final correspondeTexto = termo.isEmpty ||
        normalizar(local.nome).contains(termo) ||
        normalizar(local.categoria).contains(termo);

    final correspondeFavorito = !somenteFavoritos || local.favorito;

    return correspondeCidade &&
        correspondeCategoria &&
        correspondeTexto &&
        correspondeFavorito;
  }).toList();
}
