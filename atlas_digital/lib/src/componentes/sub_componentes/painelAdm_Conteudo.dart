import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../estado/estado_topicos.dart';
import '../../estado/estado_subtopicos.dart';
import '../../modelos/topico.dart';
import '../../modelos/informacao.dart';
import '../../modelos/subtopicos.dart';

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

  // POPUP DOS SUBTÓPICOS ---------------------------------------------------------------------------------------------
  void abrirPopupSubtopico(String topicoId, {Subtopico? subtopicoExistente}) {
    final isEditando = subtopicoExistente != null;

    // Controladores
    final indiceController = TextEditingController(
      text: subtopicoExistente?.indice.toString() ?? '',
    );
    final tituloController = TextEditingController(
      text: subtopicoExistente?.titulo ?? '',
    );
    final List<TextEditingController> informacoesControllers = [];

    // Preencher informações existentes se estiver editando
    if (isEditando) {
      for (var informacao in subtopicoExistente!.informacoes) {
        informacoesControllers.add(
          TextEditingController(text: informacao.informacao),
        );
      }
    }

    File? imagemSelecionada;

    Future<void> selecionarImagem(StateSetter setStateDialog) async {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (resultado != null && resultado.files.single.path != null) {
        setStateDialog(() {
          imagemSelecionada = File(resultado.files.single.path!);
        });
      }
    }

    Future<String?> uploadImagem(File imagem) async {
      try {
        final uri = Uri.parse('http://localhost:3000/images');
        final request = http.MultipartRequest('POST', uri);
        request.files.add(
          await http.MultipartFile.fromPath('imagem', imagem.path),
        );
        request.fields['topico'] = 'subtopico';
        request.fields['anotacao'] = 'capa';

        final response = await request.send();
        if (response.statusCode == 200) {
          final resBody = await response.stream.bytesToString();
          final data = jsonDecode(resBody);
          return data['enderecoImagem'];
        } else {
          debugPrint('Erro ao enviar imagem: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        debugPrint('Erro no upload: $e');
        return null;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 60,
          ),
          child: Container(
            width: 750,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditando ? "Editar Subtópico" : "Novo Subtópico",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: indiceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Índice (Número)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: tituloController,
                    decoration: InputDecoration(
                      labelText: "Título do Subtópico",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // COMENTEI a parte de imagem por enquanto, não tava indo
                  /*
                  ElevatedButton.icon(
                    onPressed: () => selecionarImagem(setStateDialog),
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text(
                      "Selecionar Imagem",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (imagemSelecionada != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(imagemSelecionada!, height: 120),
                    ),
                  */

                  const SizedBox(height: 20),
                  const Text(
                    "Informações:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  Column(
                    children: List.generate(
                      informacoesControllers.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: informacoesControllers[index],
                                decoration: InputDecoration(
                                  labelText: "Informação ${index + 1}",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setStateDialog(
                                () => informacoesControllers.removeAt(index),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () => setStateDialog(
                        () => informacoesControllers.add(TextEditingController()),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        "Adicionar Informação",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final indiceText = indiceController.text.trim();
                          final titulo = tituloController.text.trim();

                          // Validações básicas
                          if (indiceText.isEmpty || titulo.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Preencha o índice e o título."),
                              ),
                            );
                            return;
                          }

                          // Converter para número e validar
                          final indiceNumero = int.tryParse(indiceText);
                          if (indiceNumero == null || indiceNumero < 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "O índice deve ser um número válido maior que 0.",
                                ),
                              ),
                            );
                            return;
                          }

                          // Monta lista de Informacao
                          final listaInformacoes = informacoesControllers
                              .asMap()
                              .entries
                              .map(
                                (entry) => Informacao(
                                  id: '', // backend gera
                                  indice: entry.key,
                                  informacao: entry.value.text.trim(),
                                ),
                              )
                              .where((i) => i.informacao.isNotEmpty)
                              .toList();

                          final estado = context.read<EstadoSubtopicos>();
                          
                          if (isEditando) {
                            // EDITAR subtópico existente
                            
                            final subtopicoAtualizado = Subtopico(
                              id: subtopicoExistente!.id,
                              indice: indiceNumero,
                              titulo: titulo,
                              topicoId: topicoId,
                              informacoes: listaInformacoes,
                            );

                            try {
                              await estado.editarSubtopico(
                                subtopicoExistente.id!,
                                subtopicoAtualizado,
                              );
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erro ao editar: $e")),
                              );
                            }
                          } else {
                            // CRIAR novo subtópico
                            final novoSubtopico = Subtopico(
                              id: '',
                              indice: indiceNumero,
                              titulo: titulo,
                              topicoId: topicoId,
                              informacoes: listaInformacoes,
                            );

                            try {
                              await estado.adicionarSubtopico(novoSubtopico);
                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Erro ao salvar: $e")),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isEditando ? "Atualizar Subtópico" : "Salvar Subtópico",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------- DELETAR SUBTÓPICO -------------------
  void deletarSubtopico(String id) async {
    final estado = context.read<EstadoSubtopicos>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmação"),
        content: const Text("Tem certeza que deseja deletar este subtópico?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Deletar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await estado.removerSubtopico(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Subtópico removido com sucesso")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao remover: $e")),
        );
      }
    }
  }

  // ------------------- CARREGAR DADOS -------------------
  Future<void> _carregarTopicos() async {
    final estadoTopicos = context.read<EstadoTopicos>();
    final estadoSubtopicos = context.read<EstadoSubtopicos>();

    try {
      await estadoTopicos.carregarBanco();
      await estadoSubtopicos.carregarBanco();

      if (estadoTopicos.topicos.isEmpty) {
        await estadoTopicos.carregarLocal();
        estadoTopicos.carregarMockSeVazio();
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
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

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmação"),
        content: const Text("Tem certeza que deseja deletar este tópico?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Deletar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await estado.removerTopico(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Conteúdo removido com sucesso")),
      );
    }
  }

  // ------------------- WIDGET SUBTÓPICO -------------------
  Widget _buildSubtopico(Subtopico subtopico) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${subtopico.indice}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subtopico.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => abrirPopupSubtopico(
                  subtopico.topicoId,
                  subtopicoExistente: subtopico,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: () => deletarSubtopico(subtopico.id!),
              ),
            ],
          ),
          
          // Exibir informações do subtópico
          if (subtopico.informacoes.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...subtopico.informacoes.map((info) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                info.informacao,
                style: const TextStyle(fontSize: 12),
              ),
            )),
          ],
        ],
      ),
    );
  }

  // ------------------- INTERFACE PRINCIPAL -------------------
  @override
  Widget build(BuildContext context) {
    final estadoTopicos = context.watch<EstadoTopicos>();
    final estadoSubtopicos = context.watch<EstadoSubtopicos>();

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
            itemCount: estadoTopicos.topicos.length,
            itemBuilder: (context, index) {
              final conteudo = estadoTopicos.topicos[index];
              final subtopicosDoTopico = estadoSubtopicos.filtrarPorTopico(conteudo.id);
              
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha principal do tópico
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conteudo.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Arial",
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color.fromARGB(255, 22, 22, 22),
                          ),
                          onPressed: () => abrirPopupConteudo(id: conteudo.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deletarConteudo(conteudo.id),
                        ),
                      ],
                    ),

                    if (conteudo.resumo.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 10),
                        child: Text(
                          conteudo.resumo,
                          style: const TextStyle(
                            fontFamily: "Arial",
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                    // SUBTÓPICOS DO TÓPICO
                    if (subtopicosDoTopico.isNotEmpty) ...[
                      const Text(
                        "Subtópicos:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: subtopicosDoTopico
                            .map(_buildSubtopico)
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Botão para adicionar subtópico
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                        onPressed: () => abrirPopupSubtopico(conteudo.id),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Adicionar Subtópico",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadowColor: Colors.greenAccent.withOpacity(0.4),
                          elevation: 3,
                        ),
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