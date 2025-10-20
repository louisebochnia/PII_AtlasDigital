import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // <-- Import para escolher arquivo

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  List<Map<String, dynamic>> imagensGaleria = [
    {"nome": "Administrador Secundário", "imagem": "https://exemplo.com/img1.png"},
    {"nome": "Servidor Principal", "imagem": "https://exemplo.com/img2.png"},
  ];

  void abrirPopupImagem({int? index}) {
    final isEditando = index != null;
    final nomeController = TextEditingController(
      text: isEditando ? imagensGaleria[index]['nome'] : '',
    );
    final imagemController = TextEditingController(
      text: isEditando ? imagensGaleria[index]['imagem'] : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditando ? "Editar Imagem" : "Nova Imagem",
            style: const TextStyle(fontFamily: "Arial"),
          ),
          content: SizedBox(
            width: 750,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  style: const TextStyle(fontFamily: "Arial"),
                  decoration: const InputDecoration(
                    labelText: "Nome da imagem",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),

                // Campo e botão para escolher imagem
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: imagemController,
                        style: const TextStyle(fontFamily: "Arial"),
                        decoration: const InputDecoration(
                          labelText: "URL ou caminho da imagem",
                          hintText: "Ex: https://site.com/imagem.png ou C:/imagens/foto.png",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                        );
                        if (result != null && result.files.single.path != null) {
                          imagemController.text = result.files.single.path!;
                        }
                      },
                      icon: const Icon(Icons.folder_open),
                      label: const Text("Escolher"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
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
                final imagem = imagemController.text.trim();

                if (nome.isEmpty || imagem.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Preencha todos os campos antes de salvar",
                        style: TextStyle(fontFamily: "Arial"),
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  if (isEditando) {
                    imagensGaleria[index!] = {
                      "nome": nome,
                      "imagem": imagem,
                    };
                  } else {
                    imagensGaleria.add({
                      "nome": nome,
                      "imagem": imagem,
                    });
                  }
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditando
                          ? "Imagem atualizada com sucesso!"
                          : "Nova imagem adicionada!",
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
      imagensGaleria.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Imagem removida com sucesso",
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
          'Galeria',
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
            onPressed: () => abrirPopupImagem(),
            icon: const Icon(Icons.add),
            label: const Text(
              "Nova Imagem",
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
            itemCount: imagensGaleria.length,
            itemBuilder: (context, index) {
              final conteudo = imagensGaleria[index];
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
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black87),
                          onPressed: () => abrirPopupImagem(index: index),
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
