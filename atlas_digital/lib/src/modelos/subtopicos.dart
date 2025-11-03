import 'informacao.dart';

class Subtopico {
  final String? id;
  final int indice; 
  final String titulo;
  final String? capaUrl;
  final String topicoId;
  final List<Informacao> informacoes;

  Subtopico({
    this.id,
    required this.indice,
    required this.titulo,
    required this.topicoId,
    this.capaUrl,
    this.informacoes = const [],
  });

  factory Subtopico.fromJson(Map<String, dynamic> json) {
    return Subtopico(
      id: json['_id'] ?? json['id'],
      indice: json['indice'] is int ? json['indice'] : int.tryParse(json['indice']?.toString() ?? '1') ?? 1,
      titulo: json['titulo'] ?? '',
      capaUrl: json['capaUrl'],
      topicoId: json['topicoId'] ?? '',
      informacoes: json['informacoes'] != null
          ? List<Informacao>.from(
              json['informacoes'].map((info) => Informacao.fromJson(info)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'indice': indice, // Número
      'titulo': titulo,
      'topicoId': topicoId,
    };
    
    if (capaUrl != null && capaUrl!.isNotEmpty) {
      map['capaUrl'] = capaUrl;
    }
    
    if (informacoes.isNotEmpty) {
      map['informacoes'] = informacoes.map((info) => info.toJson()).toList();
    }
    
    return map;
  }
}