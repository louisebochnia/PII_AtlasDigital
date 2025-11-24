import 'package:flutter/material.dart';

class PointerPersonalizado {
  final String id;
  Offset position;
  final String? comentario;
  final Color cor;

  PointerPersonalizado({
    required this.id,
    required this.position,
    this.comentario,
    this.cor = Colors.red,
  });
}