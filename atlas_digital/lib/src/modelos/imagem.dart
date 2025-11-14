import 'package:flutter/foundation.dart';

@immutable
class Imagem {
  final String id;
  final String nome_arquivo;
  final String nome_imagem;
  final String endereco_pasta_mrxs;
  final String endereco_thumbnail;
  final String endereco_tiles;
  final String topico;
  final String subtopico;
  final String anotacao;
  final List<Hiperlink> hiperlinks;

  const Imagem({
    required this.id,
    required this.nome_arquivo,
    required this.nome_imagem,
    required this.endereco_pasta_mrxs,
    required this.endereco_thumbnail,
    required this.endereco_tiles,
    required this.topico,
    required this.subtopico,
    required this.anotacao,
    this.hiperlinks = const []
  });

  Imagem copyWith({
    String? id,
    String? nome_arquivo,
    String? nome_imagem,
    String? endereco_pasta_mrxs,
    String? endereco_thumbnail,
    String? endereco_tiles,
    String? topico,
    String? subtopico,
    String? anotacao,
    List<Hiperlink>?   hiperlinks
  }) {
    return Imagem(
      id: id ?? this.id,
      nome_arquivo: nome_arquivo ?? this.nome_arquivo,
      nome_imagem: nome_imagem ?? this.nome_imagem,
      endereco_pasta_mrxs: endereco_pasta_mrxs ?? this.endereco_pasta_mrxs,
      endereco_thumbnail: endereco_thumbnail ?? this.endereco_thumbnail,
      endereco_tiles: endereco_tiles ?? this.endereco_tiles,
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
      nome_arquivo: json['nomeArquivo'] ?? '',
      nome_imagem: json['nomeImagem'] ?? '',
      endereco_pasta_mrxs: json['enderecoPastaMrxs'] ?? '',
      endereco_thumbnail: json['enderecoThumbnail'] ?? '',
      endereco_tiles: json['enderecoTiles'] ?? '',
      topico: json['topico'] ?? '',
      subtopico: json['subtopico'] ?? '',
      anotacao: json['anotacao'] ?? '',
      hiperlinks: hiperlinks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'nomeArquivo': nome_arquivo,
      'nomeImagem': nome_imagem,
      'enderecoPastaMrxs': endereco_pasta_mrxs,
      'enderecoThumbnail': endereco_thumbnail,
      'enderecoTiles': endereco_tiles,
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
        other.nome_arquivo == nome_arquivo &&
        other.nome_imagem == nome_imagem &&
        other.endereco_pasta_mrxs == endereco_pasta_mrxs &&
        other.endereco_thumbnail == endereco_thumbnail &&
        other.endereco_tiles == endereco_tiles &&
        other.topico == topico &&
        other.subtopico == subtopico &&
        other.anotacao == anotacao &&
        listEquals(other.hiperlinks, hiperlinks);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nome_arquivo,
      nome_imagem,
      endereco_pasta_mrxs,
      endereco_thumbnail,
      endereco_tiles,
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