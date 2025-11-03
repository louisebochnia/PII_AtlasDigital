class Informacao {
  final String id;
  final int indice;
  final String informacao;

  Informacao({
    required this.id,
    required this.indice,
    required this.informacao,
  });

  factory Informacao.fromJson(Map<String, dynamic> json) {
    return Informacao(
      id: json['_id'] ?? json['id'] ?? '',
      indice: json['indice'] is int ? json['indice'] : int.tryParse(json['indice']?.toString() ?? '0') ?? 0,
      informacao: json['informacao'] ?? '', // Agora usa 'informacao'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'indice': indice,
      'informacao': informacao, // Campo correto para o backend
    };
  }
}