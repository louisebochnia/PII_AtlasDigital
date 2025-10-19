import 'package:flutter/material.dart';

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  List<Map<String, dynamic>> imagensGaleria = [
    {
      "nome": "Administrador Secundário",
      "tamanho": "1.19GB",
    },
    {
      "nome": "Administrador Secundário",
      "tamanho": "1.19GB",
    },
    {
      "nome": "Administrador Secundário",
      "tamanho": "1.19GB",
    },
  ];

  void editarConteudo(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Editar: ${imagensGaleria[index]['nome']}")),
    );
  }

  void deletarConteudo(int index) {
    setState(() {
      imagensGaleria.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Imagem removido com sucesso")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Galeria',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
        const SizedBox(height: 20),

        // Botão "Novo Conteúdo"
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Nova Imagem")),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Nova Imagem"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ListView com itens estilizados
        Expanded(
          child: ListView.builder(
            itemCount: imagensGaleria.length,
            itemBuilder: (context, index) {
              final conteudo = imagensGaleria[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 243, 242, 242),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Nome
                    Expanded(
                      flex: 4,
                      child: Text(
                        conteudo['nome'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Tamanho
                    Expanded(
                      flex: 4,
                      child: Text(
                        conteudo['tamanho'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Opções
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black87),
                            onPressed: () => editarConteudo(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deletarConteudo(index),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
