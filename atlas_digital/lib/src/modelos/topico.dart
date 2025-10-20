import 'package:flutter/foundation.dart';
import 'capitulo.dart';

@immutable
class Topico {
  final String id;
  final String titulo;
  final String descricao;
  final String? capaUrl;
  final List<Capitulo> capitulos;

  const Topico({
    required this.id,
    required this.titulo,
    required this.descricao,
    this.capaUrl,
    this.capitulos = const [],
  });

  Topico copyWith({
    String? id,
    String? titulo,
    String? descricao,
    String? capaUrl,
    List<Capitulo>? capitulos,
  }) =>
      Topico(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        descricao: descricao ?? this.descricao,
        capaUrl: capaUrl ?? this.capaUrl,
        capitulos: capitulos ?? this.capitulos,
      );

  /// 🔄 Conversão para o formato do backend (Node/Mongo)
  Map<String, dynamic> toJson() => {
        'topico': titulo, // backend espera "topico"
        'subtopicos': '', // se quiser, pode usar um campo fixo por enquanto
        'resumo': descricao, // backend espera "resumo"
      };

  /// 🔄 Conversão do JSON do backend para o modelo Flutter
  factory Topico.fromJson(Map<String, dynamic> json) => Topico(
        id: json['_id']?.toString() ?? '', // Mongo usa "_id"
        titulo: json['topico'] ?? json['titulo'] ?? '',
        descricao: json['resumo'] ?? json['descricao'] ?? '',
        capaUrl: json['capaUrl'] as String?,
        capitulos: (json['capitulos'] as List<dynamic>? ?? [])
            .map((e) => Capitulo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
