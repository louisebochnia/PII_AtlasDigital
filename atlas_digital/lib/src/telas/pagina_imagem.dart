// pages/visualizador_page.dart
import 'package:flutter/material.dart';
import '../componentes/visualizador_imagem.dart';

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
            // HEADER COM INFORMAÇÕES
            _buildAppBar(context),
            
            // VISUALIZADOR (ocupa o resto da tela)
            Expanded(
              child: VisualizadorImagem(
                imagemId: imagemId,
                tilesBaseUrl: 'http://localhost:3000/tiles',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          // BOTÃO VOLTAR
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          
          SizedBox(width: 12),
          
          // HUMBNAIL PEQUENA
          if (thumbnailUrl != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  thumbnailUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: Icon(Icons.image, color: Colors.grey[500], size: 20),
                    );
                  },
                ),
              ),
            ),
          
          SizedBox(width: 12),
          
          // INFORMAÇÕES DA IMAGEM
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nomeImagem,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  '$topico • $subtopico',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
        ],
      ),
    );
  }
}