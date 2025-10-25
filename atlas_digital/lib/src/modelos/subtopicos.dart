import 'informacao.dart';

class Subtopico {
  final String id;
  final int indice;
  final String titulo;
  final String? capaUrl;
  final List<Informacao> informacoes;

  Subtopico({
    required this.id,
    required this.indice,
    required this.titulo,
    this.capaUrl,
    this.informacoes = const [],
  });

  // Converter JSON (ex.: vindo do backend) para objeto Subtopico
  factory Subtopico.fromJson(Map<String, dynamic> json) {
    return Subtopico(
      id: json['_id'] ?? '',
      indice: json['indice'] ?? 0,
      titulo: json['titulo'] ?? '',
      capaUrl: json['capaUrl'],
      informacoes: json['informacoes'] != null
          ? List<Informacao>.from(
              json['informacoes'].map((info) => Informacao.fromJson(info)))
          : [],
    );
  }

  // Converter objeto Subtopico para JSON (ex.: enviar para backend)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'indice': indice,
      'titulo': titulo,
      'capaUrl': capaUrl,
      'informacoes': informacoes.map((info) => info.toJson()).toList(),
    };
  }
}
