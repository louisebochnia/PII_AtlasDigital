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
      "topico": "20",
    },
    {
      "nome": "Administrador Secundário",
      "descricao": "Essa galeria permite a navegação rápida entre conteúdos.",
      "topico": "21",
    },
    {
      "nome": "Administrador Secundário",
      "descricao": "Essa galeria permite a navegação rápida entre conteúdos.",
      "topico": "24",
    },
  ];

  void abrirPopupConteudo({int? index}) {
    final isEditando = index != null;
    final nomeController = TextEditingController(
      text: isEditando ? conteudos[index]['nome'] : '',
    );
    final descricaoController = TextEditingController(
      text: isEditando ? conteudos[index]['descricao'] : '',
    );
    final topicoController = TextEditingController(
      text: isEditando ? conteudos[index]['topico'] : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditando ? "Editar Conteúdo" : "Novo Conteúdo",
            style: const TextStyle(fontFamily: "Arial"),
          ),
          content: SizedBox(
            width: 750,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: "Nome",
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: "Arial"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: "Descrição",
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontFamily: "Arial"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: topicoController,
                  decoration: const InputDecoration(
                    labelText: "Tópico",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontFamily: "Arial"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(fontFamily: "Arial"),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final nome = nomeController.text.trim();
                final descricao = descricaoController.text.trim();
                final topico = topicoController.text.trim();

                if (nome.isEmpty || descricao.isEmpty || topico.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                      "Preencha todos os campos antes de salvar",
                      style: TextStyle(fontFamily: "Arial"),
                    )),
                  );
                  return;
                }

                setState(() {
                  if (isEditando) {
                    conteudos[index!] = {
                      "nome": nome,
                      "descricao": descricao,
                      "topico": topico,
                    };
                  } else {
                    conteudos.add({
                      "nome": nome,
                      "descricao": descricao,
                      "topico": topico,
                    });
                  }
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditando
                          ? "Conteúdo atualizado com sucesso!"
                          : "Novo conteúdo adicionado!",
                      style: const TextStyle(fontFamily: "Arial"),
                    ),
                  ),
                );
              },
              child: const Text(
                "Salvar",
                style: TextStyle(fontFamily: "Arial"),
              ),
            ),
          ],
        );
      },
    );
  }

  void deletarConteudo(int index) {
    setState(() {
      conteudos.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Conteúdo removido com sucesso",
          style: TextStyle(fontFamily: "Arial"),
        ),
      ),
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
            fontFamily: "Arial",
          ),
        ),
        const SizedBox(height: 20),

        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: () => abrirPopupConteudo(),
            icon: const Icon(Icons.add),
            label: const Text(
              "Novo Conteúdo",
              style: TextStyle(fontFamily: "Arial"),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: ListView.builder(
            itemCount: conteudos.length,
            itemBuilder: (context, index) {
              final conteudo = conteudos[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 243, 242, 242),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        conteudo['nome'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: "Arial",
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: Text(
                        conteudo['descricao'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: "Arial",
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Text(
                        conteudo['topico'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: "Arial",
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black87),
                          onPressed: () => abrirPopupConteudo(index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deletarConteudo(index),
                        ),
                      ],
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
