import 'package:flutter/material.dart';

class SecaoHorizontal extends StatelessWidget {
  final String titulo;
  final String descricao;
  final List<Map<String, String>> itens;

  const SecaoHorizontal({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines:
                      1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Capítulos: 1-7',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 12, 0),
          child: Text(
            descricao,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: "Arial",
            ),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 194,
          child: Scrollbar(
            controller: controller,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 6,
            radius: const Radius.circular(10),
            child: ListView.builder(
              controller: controller,
              scrollDirection: Axis.horizontal,
              itemCount: itens.length,
              itemBuilder: (context, index) {
                final item = itens[index];

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
                        child: Image.network(
                          item['url']!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Capítulo + título + botão
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Capítulo
                          Text(
                            'Capítulo ${item['capitulo']}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                            ),
                          ),

                          // Título + botão
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['titulo']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow:
                                      TextOverflow.ellipsis, // evita estourar
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (item['rota'] != null) {
                                    Navigator.of(
                                      context,
                                    ).pushNamed(item['rota']!);
                                  } else {
                                    print(
                                      'Erro: Rota não definida para este item.',
                                    );
                                  }
                                },
                                // Mantenha o child (Texto 'Acessar' e ícone) inalterado:
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
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
