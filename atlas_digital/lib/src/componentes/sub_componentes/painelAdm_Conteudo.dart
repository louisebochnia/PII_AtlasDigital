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
  // ------------------- CARREGAR CONTEUDDOS -----------------
  bool _carregado = false;

  @override
  void initState() {
    super.initState();
    _carregarTopicos();
  }

  Future<void> _carregarTopicos() async {
    final estado = context.read<EstadoTopicos>();

    try {
      await estado.carregarBanco();

      if (estado.topicos.isEmpty) {
        await estado.carregarLocal();
        estado.carregarMockSeVazio();
      }
    } catch (e) {
      debugPrint("Erro ao carregar tópicos: $e");
    }

    setState(() {
      _carregado = true;
    });
  }

  // ------------------- POPUP DE CONTEÚDO -------------------
  void abrirPopupConteudo({String? id}) {
    final estado = context.read<EstadoTopicos>();
    final isEditando = id != null;
    final topicoExistente = isEditando
        ? estado.topicos.firstWhere((t) => t.id == id)
        : null;

    final tituloController = TextEditingController(
      text: topicoExistente?.titulo ?? '',
    );
    final resumoController = TextEditingController(
      text: topicoExistente?.resumo ?? '',
    );

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
                      fontFamily: "Arial",
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Campo de título
              TextField(
                controller: tituloController,
                decoration: InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(fontFamily: "Arial"),
              ),
              const SizedBox(height: 10),

              // Campo de resumo
              TextField(
                controller: resumoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Resumo",
                  hintText: "Digite o resumo do conteúdo...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(fontFamily: "Arial"),
              ),
              const SizedBox(height: 20),

              // Botão salvar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final titulo = tituloController.text.trim();
                      final resumo = resumoController.text.trim();

                      if (titulo.isEmpty || resumo.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Preencha todos os campos antes de salvar",
                            ),
                          ),
                        );
                        return;
                      }

                      if (isEditando) {
                        final topicoAtualizado = Topico(
                          id: topicoExistente!.id,
                          titulo: titulo,
                          resumo: resumo,
                        );

                        await estado.editarTopico(
                          topicoExistente.id,
                          topicoAtualizado,
                        );
                      } else {
                        final novoTopico = Topico(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          titulo: titulo,
                          resumo: resumo,
                        );

                        await estado.adicionarTopico(novoTopico);
                      }

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Salvar",
                      style: TextStyle(
                        fontFamily: "Arial",
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------- DELETAR CONTEÚDO -------------------
  void deletarConteudo(String id) async {
    final estado = context.read<EstadoTopicos>();

    // Mostra o diálogo de confirmação
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmação"),
        content: const Text("Tem certeza que deseja deletar este tópico?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // cancelar
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // confirmar
            child: const Text("Deletar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // Se o usuário confirmou
    if (confirmar == true) {
      await estado.removerTopico(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Conteúdo removido com sucesso")),
      );
    }
  }

  // ------------------- INTERFACE PRINCIPAL -------------------
  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoTopicos>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conteúdo',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        ElevatedButton.icon(
          onPressed: () => abrirPopupConteudo(),
          icon: const Icon(Icons.add),
          label: const Text(
            "Novo Conteúdo",
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
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
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        conteudo.titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: "Arial",
                        ),
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
