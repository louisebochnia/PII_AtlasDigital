import 'package:flutter/material.dart';

class ConteudoPage extends StatefulWidget {
  const ConteudoPage({super.key});

  @override
  State<ConteudoPage> createState() => _ConteudoPageState();
}

class _ConteudoPageState extends State<ConteudoPage> {
  List<Map<String, dynamic>> conteudos = [
    {
      "nome": "Administrador Secundário",
      "descricao": "Essa galeria permite a navegação rápida entre conteúdos.",
      "foto": true,
    },
    {
      "nome": "Administrador Secundário",
      "descricao": "Essa galeria permite a navegação rápida entre conteúdos.",
      "foto": true,
    },
    {
      "nome": "Administrador Secundário",
      "descricao": "Essa galeria permite a navegação rápida entre conteúdos.",
      "foto": true,
    },
  ];

  void editarConteudo(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Editar: ${conteudos[index]['nome']}")),
    );
  }

  void deletarConteudo(int index) {
    setState(() {
      conteudos.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Conteúdo removido com sucesso")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conteúdo',
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
                const SnackBar(content: Text("Novo conteúdo")),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Novo Conteúdo"),
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
            itemCount: conteudos.length,
            itemBuilder: (context, index) {
              final conteudo = conteudos[index];
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
                      flex: 2,
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

                    // Descrição
                    Expanded(
                      flex: 4,
                      child: Text(
                        conteudo['descricao'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Foto
                    Expanded(
                      flex: 1,
                      child: Icon(
                        conteudo['foto'] ? Icons.check_circle : Icons.cancel,
                        color: conteudo['foto'] ? Colors.green : Colors.red,
                        size: 28,
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
