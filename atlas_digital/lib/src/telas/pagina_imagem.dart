// pages/visualizador_page.dart
import 'package:flutter/material.dart';
import '../componentes/visualizador_imagem.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

bool get isDesktopOrWeb {
  if (kIsWeb) return true;
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

class PaginaImagem extends StatelessWidget {
  final String imagemId;
  final String nomeImagem;
  final String topico;
  final String subtopico;
  final String? thumbnailUrl;

  const PaginaImagem({
    super.key,
    required this.imagemId,
    required this.nomeImagem,
    required this.topico,
    required this.subtopico,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: VisualizadorImagem(
                imagemId: imagemId,
                tilesBaseUrl: isDesktopOrWeb ? 'http://localhost:3000/tiles' : 'http://10.2.129.68:3000',
              ),
            ),
          ],
        ),
      ),
    );
  }
}