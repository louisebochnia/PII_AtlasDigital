import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../estado/estado_topicos.dart';
import '../../modelos/topico.dart';

class ConteudoPage extends StatefulWidget {
  const ConteudoPage({super.key});

  @override
  State<ConteudoPage> createState() => _ConteudoPageState();
}

class _ConteudoPageState extends State<ConteudoPage> {
  // ------------------- POPUP DE ADIÇÃO / EDIÇÃO -------------------
  void abrirPopupConteudo({String? id}) {
    final estado = context.read<EstadoTopicos>();
    final isEditando = id != null;

    final topicoExistente = isEditando
        ? estado.topicos.firstWhere((t) => t.id == id)
        : null;

    final nomeController = TextEditingController(
      text: topicoExistente?.titulo ?? '',
    );
    final descricaoController = TextEditingController(
      text: topicoExistente?.descricao ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final nome = nomeController.text.trim();
                final descricao = descricaoController.text.trim();

                if (nome.isEmpty || descricao.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Preencha todos os campos antes de salvar"),
                    ),
                  );
                  return;
                }

                if (isEditando) {
                  // Atualizar
                  estado.editarTopico(
                    id,
                    Topico(
                      id: id,
                      titulo: nome,
                      descricao: descricao,
                      capitulos: estado.topicos
                          .firstWhere((t) => t.id == id)
                          .capitulos, // mantém os capítulos já existentes
                    ),
                  );
                } else {
                  // Adicionar
                  estado.adicionarTopico(
                    Topico(
                      id: DateTime.now().toIso8601String(),
                      titulo: nome,
                      descricao: descricao,
                      capitulos: const [],
                    ),
                  );
                }

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

  // ------------------- DELETAR CONTEÚDO -------------------
  void deletarConteudo(String id) {
    final estado = context.read<EstadoTopicos>();
    estado.removerTopico(id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Conteúdo removido com sucesso",
          style: TextStyle(fontFamily: "Arial"),
        ),
      ),
    );
  }

  // ------------------- INTERFACE -------------------
  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoTopicos>();

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

        // Botão "Novo Conteúdo"
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

        // Lista dinâmica
        Expanded(
          child: ListView.builder(
            itemCount: estado.topicos.length,
            itemBuilder: (context, index) {
              final conteudo = estado.topicos[index];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
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
                        conteudo.titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => abrirPopupConteudo(id: conteudo.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deletarConteudo(conteudo.id),
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
