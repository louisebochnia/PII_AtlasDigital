import 'package:flutter/foundation.dart';

@immutable
class Imagem {
  final String id;
  final String nomeArquivo;
  final String nomeImagem;
  final String enderecoPastaMrxs;
  final String enderecoThumbnail;
  final String enderecoTiles;
  final String topico;
  final String subtopico;
  final String anotacao;
  final List<Hiperlink> hiperlinks;

  const Imagem({
    required this.id,
    required this.nomeArquivo,
    required this.nomeImagem,
    required this.enderecoPastaMrxs,
    required this.enderecoThumbnail,
    required this.enderecoTiles,
    required this.topico,
    required this.subtopico,
    required this.anotacao,
    this.hiperlinks = const []
  });

  Imagem copyWith({
    String? id,
    String? nomeArquivo,
    String? nomeImagem,
    String? enderecoPastaMrxs,
    String? enderecoThumbnail,
    String? enderecoTiles,
    String? topico,
    String? subtopico,
    String? anotacao,
    List<Hiperlink>?   hiperlinks
  }) {
    return Imagem(
      id: id ?? this.id,
      nomeArquivo: nomeArquivo ?? this.nomeArquivo,
      nomeImagem: nomeImagem ?? this.nomeImagem,
      enderecoPastaMrxs: enderecoPastaMrxs ?? this.enderecoPastaMrxs,
      enderecoThumbnail: enderecoThumbnail ?? this.enderecoThumbnail,
      enderecoTiles: enderecoTiles ?? this.enderecoTiles,
      topico: topico ?? this.topico,
      subtopico: subtopico ?? this.subtopico,
      anotacao: anotacao ?? this.anotacao,
      hiperlinks: hiperlinks ?? this.hiperlinks
    );
  }

  factory Imagem.fromJson(Map<String, dynamic> json) {
    final hiperlinksJson = json['hiperlinks'] as List? ?? [];
    final List<Hiperlink> hiperlinks = hiperlinksJson
        .map((item) => Hiperlink.fromJson(item))
        .toList();

    return Imagem(
      id: json['_id']?.toString() ?? '',
      nomeArquivo: json['nomeArquivo'] ?? '',
      nomeImagem: json['nomeImagem'] ?? '',
      enderecoPastaMrxs: json['enderecoPastaMrxs'] ?? '',
      enderecoThumbnail: json['enderecoThumbnail'] ?? '',
      enderecoTiles: json['enderecoTiles'] ?? '',
      topico: json['topico'] ?? '',
      subtopico: json['subtopico'] ?? '',
      anotacao: json['anotacao'] ?? '',
      hiperlinks: hiperlinks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'nomeArquivo': nomeArquivo,
      'nomeImagem': nomeImagem,
      'enderecoPastaMrxs': enderecoPastaMrxs,
      'enderecoThumbnail': enderecoThumbnail,
      'enderecoTiles': enderecoTiles,
      'topico': topico,
      'subtopico': subtopico,
      'anotacao': anotacao,
      'hiperlinks': hiperlinks.map((link) => link.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Imagem &&
        other.id == id &&
        other.nomeArquivo == nomeArquivo &&
        other.nomeImagem == nomeImagem &&
        other.enderecoPastaMrxs == enderecoPastaMrxs &&
        other.enderecoThumbnail == enderecoThumbnail &&
        other.enderecoTiles == enderecoTiles &&
        other.topico == topico &&
        other.subtopico == subtopico &&
        other.anotacao == anotacao &&
        listEquals(other.hiperlinks, hiperlinks);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nomeArquivo,
      nomeImagem,
      enderecoPastaMrxs,
      enderecoThumbnail,
      enderecoTiles,
      topico,
      subtopico,
      anotacao,
      Object.hashAll(hiperlinks),
    );
  }
}


@immutable
class Hiperlink {
  final String palavra;
  final String link;

  const Hiperlink({
    required this.palavra,
    required this.link,
  });

  factory Hiperlink.fromJson(Map<String, dynamic> json) {
    return Hiperlink(
      palavra: json['palavra'] ?? '',
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'palavra': palavra,
      'link': link,
    };
  }
}