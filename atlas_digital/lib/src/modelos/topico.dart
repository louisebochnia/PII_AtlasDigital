import 'package:flutter/foundation.dart';

@immutable
class Topico {
  final String id;
  final String titulo;
  final String resumo; // Antes era 'descricao'

  const Topico({
    required this.id,
    required this.titulo,
    required this.resumo,
  });

  Topico copyWith({
    String? id,
    String? titulo,
    String? resumo,
  }) {
    return Topico(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      resumo: resumo ?? this.resumo,
    );
  }

  /// 🔄 Envia dados no formato esperado pelo backend (Node/Mongo)
  Map<String, dynamic> toJson() => {
        'topico': titulo,
        'resumo': resumo,
      };

  /// 🔄 Converte JSON do backend para o modelo Flutter
  factory Topico.fromJson(Map<String, dynamic> json) {
    return Topico(
      id: json['_id']?.toString() ?? '',
      titulo: json['topico'] ?? '',
      resumo: json['resumo'] ?? '',
    );
  }
}
