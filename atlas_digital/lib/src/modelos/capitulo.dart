import 'package:flutter/foundation.dart';

@immutable
class Capitulo {
  final String id;
  final int indice; // Ex: "Capítulo 01"
  final String titulo;
  final String? capaUrl; // imagem
  final String cta; // ex.: "Acessar →"
  final String rotaOuSlug; // navegação

  const Capitulo({
    required this.id,
    required this.indice,
    required this.titulo,
    this.capaUrl,
    this.cta = 'Acessar →',
    required this.rotaOuSlug,
  });

  Capitulo copyWith({
    String? id,
    int? indice,
    String? titulo,
    String? capaUrl,
    String? cta,
    String? rotaOuSlug,
  }) => Capitulo(
    id: id ?? this.id,
    indice: indice ?? this.indice,
    titulo: titulo ?? this.titulo,
    capaUrl: capaUrl ?? this.capaUrl,
    cta: cta ?? this.cta,
    rotaOuSlug: rotaOuSlug ?? this.rotaOuSlug,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'indice': indice,
    'titulo': titulo,
    'capaUrl': capaUrl,
    'cta': cta,
    'rotaOuSlug': rotaOuSlug,
  };

  factory Capitulo.fromJson(Map<String, dynamic> json) => Capitulo(
    id: json['id'] as String,
    indice: json['indice'] as int,
    titulo: json['titulo'] as String,
    capaUrl: json['capaUrl'] as String?,
    cta: (json['cta'] as String?) ?? 'Acessar →',
    rotaOuSlug: json['rotaOuSlug'] as String,
  );
}

String formatarIndicadorCapitulo(int indice) =>
    'Capítulo ${indice.toString().padLeft(2, '0')}';
