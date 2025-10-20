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
  // ------------------- POPUP DE CAPÍTULOS -------------------
  void abrirPopupCapitulos({String? nomeExistente, Function(String)? onSalvar}) {
    final controller = TextEditingController(text: nomeExistente ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          nomeExistente != null ? "Editar Capítulo" : "Novo Capítulo",
          style: const TextStyle(fontFamily: "Arial"),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Nome",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(fontFamily: "Arial")),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final nome = controller.text.trim();
              if (nome.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Preencha o campo antes de salvar")),
                );
                return;
              }
              if (onSalvar != null) onSalvar(nome);
              Navigator.pop(context);
            },
            child: const Text("Salvar", style: TextStyle(fontFamily: "Arial")),
          ),
        ],
      ),
    );
  }

  // ------------------- POPUP DE CONTEÚDO -------------------
  void abrirPopupConteudo({String? id}) {
    final estado = context.read<EstadoTopicos>();
    final isEditando = id != null;
    final topicoExistente = isEditando ? estado.topicos.firstWhere((t) => t.id == id) : null;

    final tituloController = TextEditingController(text: topicoExistente?.titulo ?? '');
    final descricaoController = TextEditingController(text: topicoExistente?.descricao ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Container(
          width: 850,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditando ? "Editar Conteúdo" : "Novo Conteúdo",
                    style: const TextStyle(
                        fontFamily: "Arial", fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Campo de descrição
              TextField(
                controller: descricaoController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Descrição do conteúdo...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                style: const TextStyle(fontFamily: "Arial"),
              ),
              const SizedBox(height: 20),

              // Botão adicionar capítulo (apenas como exemplo)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => abrirPopupCapitulos(
                      onSalvar: (nome) {
                        // Aqui você adicionaria o capítulo à lista
                      },
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Adicionar Capítulo", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Lista de conteúdos
              Expanded(
                child: ListView.builder(
                  itemCount: estado.topicos.length,
                  itemBuilder: (context, index) {
                    final conteudo = estado.topicos[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 243, 242, 242),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              conteudo.titulo,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontFamily: "Arial"),
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
          ),
        ),
      ),
    );
  }

  // ------------------- DELETAR CONTEÚDO -------------------
  void deletarConteudo(String id) {
    final estado = context.read<EstadoTopicos>();
    estado.removerTopico(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Conteúdo removido com sucesso")),
    );
  }

  // ------------------- INTERFACE PRINCIPAL -------------------
  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoTopicos>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Conteúdo',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: () => abrirPopupConteudo(),
          icon: const Icon(Icons.add),
          label: const Text("Novo Conteúdo"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: ListView.builder(
            itemCount: estado.topicos.length,
            itemBuilder: (context, index) {
              final conteudo = estado.topicos[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 243, 242, 242),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        conteudo.titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontFamily: "Arial"),
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
