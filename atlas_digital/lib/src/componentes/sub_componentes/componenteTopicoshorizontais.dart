import 'package:flutter/material.dart';
import '../../modelos/subtopicos.dart';

class SecaoHorizontal extends StatefulWidget {
  final String titulo;
  final String descricao;
  final List<Subtopico> subtopicos;
  final Function(Subtopico)? onAcessarSubtopico;

  const SecaoHorizontal({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.subtopicos,
    this.onAcessarSubtopico,
  });

  @override
  State<SecaoHorizontal> createState() => _SecaoHorizontalState();
}

class _SecaoHorizontalState extends State<SecaoHorizontal> {
  final ScrollController _scrollController = ScrollController();

  // Chamado quando clica em "Acessar"
  void _onAcessarSubtopico(Subtopico subtopico) {
    if (widget.onAcessarSubtopico != null) {
      widget.onAcessarSubtopico!(subtopico);
    } else {
      debugPrint('Acessar subtópico: ${subtopico.titulo}');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  widget.titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Subtópicos: ${widget.subtopicos.length}',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),

        // Descrição
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
          child: Text(
            widget.descricao,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: "Arial",
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Container do carrossel COM SCROLL HORIZONTAL NORMAL
        SizedBox(
          height: 194,
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 6,
            radius: const Radius.circular(10),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.subtopicos.length,
              itemBuilder: (context, index) {
                final subtopico = widget.subtopicos[index];
                return Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 24, 8),
                  padding: const EdgeInsets.all(6),
                  width: 240,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 231, 230, 230),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagem
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          color: const Color.fromARGB(255, 200, 200, 200),
                          child:
                              subtopico.capaUrl != null &&
                                  subtopico.capaUrl!.isNotEmpty
                              ? Image.network(
                                  subtopico.capaUrl!,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.auto_stories_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Conteúdo
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subtópico ${subtopico.indice}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  subtopico.titulo,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _onAcessarSubtopico(subtopico),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Acessar',
                                      style: TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          170,
                                          14,
                                          170,
                                        ),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_right_alt_sharp,
                                      color: Color.fromARGB(255, 170, 14, 170),
                                      size: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
