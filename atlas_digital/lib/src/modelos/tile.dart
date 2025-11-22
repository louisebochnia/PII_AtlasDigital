import 'package:flutter/material.dart';

@immutable
class TileInfo {
  final int level;
  final int x;
  final int y;
  final String? url;

  TileInfo({
    required this.level,
    required this.x,
    required this.y,
    this.url
  });

}

@immutable
class TileLayer {
  final int level;
  final int width;
  final int height;
  final int tileSize;
  final double scale;

  TileLayer({
    required this.level,
    required this.width,
    required this.height,
    required this.tileSize,
    required this.scale
  });
  
}