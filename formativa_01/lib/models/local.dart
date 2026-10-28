/// Representa um local (estabelecimento) cadastrado no aplicativo.
class Local {
  final String id;
  final String nome;
  final String categoria;
  final String cidade;
  final double avaliacao;
  final double distancia;
  final String horario;
  final String descricao;
  final bool favorito;

  const Local({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.cidade,
    required this.avaliacao,
    required this.distancia,
    required this.horario,
    required this.descricao,
    required this.favorito,
  });

  factory Local.fromMap(String id, Map<String, dynamic> data) {
    return Local(
      id: id,
      nome: data['nome'] as String? ?? '',
      categoria: data['categoria'] as String? ?? '',
      cidade: data['cidade'] as String? ?? '',
      avaliacao: (data['avaliacao'] as num? ?? 0).toDouble(),
      distancia: (data['distancia'] as num? ?? 0).toDouble(),
      horario: data['horario'] as String? ?? '',
      descricao: data['descricao'] as String? ?? '',
      favorito: data['favorito'] as bool? ?? false,
    );
  }

  /// O `id` fica fora do mapa: ele identifica o registro, não é um dado dele.
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
      'cidade': cidade,
      'avaliacao': avaliacao,
      'distancia': distancia,
      'horario': horario,
      'descricao': descricao,
      'favorito': favorito,
    };
  }

  Local copyWith({
    String? id,
    String? nome,
    String? categoria,
    String? cidade,
    double? avaliacao,
    double? distancia,
    String? horario,
    String? descricao,
    bool? favorito,
  }) {
    return Local(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      categoria: categoria ?? this.categoria,
      cidade: cidade ?? this.cidade,
      avaliacao: avaliacao ?? this.avaliacao,
      distancia: distancia ?? this.distancia,
      horario: horario ?? this.horario,
      descricao: descricao ?? this.descricao,
      favorito: favorito ?? this.favorito,
    );
  }
}
