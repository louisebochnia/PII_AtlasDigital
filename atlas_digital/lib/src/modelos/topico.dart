import 'package:flutter/foundation.dart';
import 'capitulo.dart';

@immutable
class Topico {
  final String id;
  final String titulo;
  final String descricao;
  final String? capaUrl; // opcional – caso queira uma imagem do tópico
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
  }) => Topico(
    id: id ?? this.id,
    titulo: titulo ?? this.titulo,
    descricao: descricao ?? this.descricao,
    capaUrl: capaUrl ?? this.capaUrl,
    capitulos: capitulos ?? this.capitulos,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descricao': descricao,
    'capaUrl': capaUrl,
    'capitulos': capitulos.map((c) => c.toJson()).toList(),
  };

  factory Topico.fromJson(Map<String, dynamic> json) => Topico(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    descricao: json['descricao'] as String,
    capaUrl: json['capaUrl'] as String?,
    capitulos: (json['capitulos'] as List<dynamic>? ?? [])
        .map((e) => Capitulo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
