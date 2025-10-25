class Informacao {
  final String id;
  final int indice;
  final String conteudo;
  final String? tipo; // opcional, pode ser "texto", "imagem", etc.

  Informacao({
    required this.id,
    required this.indice,
    required this.conteudo,
    this.tipo,
  });

  // Converter JSON para objeto Informacao
  factory Informacao.fromJson(Map<String, dynamic> json) {
    return Informacao(
      id: json['_id'] ?? '',
      indice: json['indice'] ?? 0,
      conteudo: json['conteudo'] ?? '',
      tipo: json['tipo'],
    );
  }

  // Converter objeto Informacao para JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'indice': indice,
      'conteudo': conteudo,
      'tipo': tipo,
    };
  }
}
