import 'package:flutter/material.dart';
import '../../modelos/subtopicos.dart';

class SecaoHorizontal extends StatelessWidget {
  final String titulo;
  final String descricao;
  final List<Subtopico> subtopicos;

  const SecaoHorizontal({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.subtopicos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                _calcularRangeCapitulos(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),

          // Descrição
          Text(
            descricao,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 16),

          // Carrossel com altura FIXA
          SizedBox(
            height: 220,
            child: _buildCarrossel(),
          ),
        ],
      ),
    );
  }

  Widget _buildCarrossel() {
    if (subtopicos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.collections, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Nenhum subtópico disponível',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: subtopicos.length,
      itemBuilder: (context, index) {
        return _buildCardItem(subtopicos[index]);
      },
    );
  }

  Widget _buildCardItem(Subtopico subtopico) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagem com altura fixa
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image: subtopico.capaUrl != null && subtopico.capaUrl!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(subtopico.capaUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: subtopico.capaUrl == null || subtopico.capaUrl!.isEmpty
                    ? Icon(Icons.image, color: Colors.grey[400], size: 40)
                    : null,
              ),
              
              const SizedBox(height: 8),
              
              // Capítulo
              Text(
                'Cap. ${subtopico.indice}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Título
              Text(
                subtopico.titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calcularRangeCapitulos() {
    if (subtopicos.isEmpty) return 'Capítulos: 0';
    
    final indices = subtopicos.map((e) => e.indice).toList();
    indices.sort();
    
    final primeiro = indices.first;
    final ultimo = indices.last;
    
    return primeiro == ultimo 
        ? 'Cap. $primeiro'
        : 'Cap. $primeiro-$ultimo';
  }
}