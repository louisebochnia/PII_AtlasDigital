import 'dart:io';
import 'dart:typed_data';
import 'package:atlas_digital/src/estado/estado_subtopicos.dart';
import 'package:atlas_digital/src/estado/estado_topicos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'dart:html' as html;

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  final String protocolo = 'http://';
  final String baseURL = 'localhost:3000';

  List<Map<String, dynamic>> imagensGaleria = [
    {"nome": "Célula eucarionte", "imagem": "https://exemplo.com/img1.png"},
    {"nome": "Tecido epitelial", "imagem": "https://exemplo.com/img2.png"},
  ];

  dynamic arquivoSelecionado;
  String? nomeArquivoWeb;
  String? topicoSelecionado;
  String? subtopicoSelecionado;
  final nomeController = TextEditingController(
    // text: isEditando ? imagensGaleria[index!]['nome'] : '',
  );
  final imagemController = TextEditingController(
    // text: isEditando ? imagensGaleria[index!]['imagem'] : '',
  );
  final anotacaoController = TextEditingController(
    // text: isEditando ? imagensGaleria[index!]['imagem'] : '',
  );

  bool enviando = false;

  Future<void> abrirPopupImagem({int? index}) async {
    final isEditando = index != null;

    await _carregarTopicos();

    final List<String> opcoesTopico = carregarTituloTopicos();
    final Map<String, List<String>> mapaSubtopicos = carregarTituloSubtopicos();
    
    // Variáveis para controlar o estado do diálogo
    List<String> opcoesSubtopicoAtual = [];

    showDialog(
      context: context,
      builder: (context) {
        // Detecta o tamanho da tela
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 650;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isEditando ? "Editar Imagem" : "Nova Imagem",
            style: const TextStyle(fontFamily: "Arial"),
          ),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return SizedBox(
                width: isSmallScreen ? screenWidth * 0.9 : 750,
                child: SingleChildScrollView( 
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Campo e botão para escolher imagem
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: imagemController,
                              style: const TextStyle(fontFamily: "Arial"),
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: "Selecione um arquivo ZIP que inclua o .mrxs da imagem e os .dat",
                                hintText:
                                    "Nenhum arquivo selecionado",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.image),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final uploadInput = html.FileUploadInputElement();
                                uploadInput.accept = '.zip';
                                uploadInput.click();

                                await uploadInput.onChange.first;
                                
                                final file = uploadInput.files!.first;

                                setState(() {
                                  imagemController.text = file.name;
                                });
                                arquivoSelecionado = file;

                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Arquivo selecionado: ${file.name}'),
                                        backgroundColor: Colors.green,
                                    ),
                                );
                                
                              },
                              icon: const Icon(Icons.folder_open),
                              label: isSmallScreen
                                  ? const Text("") // Só ícone em telas pequenas
                                  : const Text("Escolher"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // SEÇÃO NOME IMAGEM
                      const Text(
                        "Nome da imagem:",
                        style: TextStyle(
                          fontFamily: "Arial",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 56,
                        child: TextField(
                          controller: nomeController,
                          style: const TextStyle(fontFamily: "Arial"),
                          decoration: const InputDecoration(
                            labelText: "Nome da imagem",
                            hintText:
                                "Digite o nome da imagem que será exibido na galeria",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // SEÇÃO DIRETÓRIO
                      const Text(
                        "Diretório",
                        style: TextStyle(
                          fontFamily: "Arial",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Layout responsivo para os dropdowns
                      if (isSmallScreen)
                        // Versão para telas pequenas - vertical
                        Column(
                          children: [
                            // Dropdown Tópico
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Tópico:",
                                  style: TextStyle(
                                    fontFamily: "Arial",
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: topicoSelecionado,
                                  isExpanded:
                                      true, // Importante para telas pequenas
                                  decoration: InputDecoration(
                                    hintText: 'Selecione o tópico',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Selecione o tópico'),
                                    ),
                                    ...opcoesTopico.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (String? newValue) {
                                    setStateDialog(() {
                                      topicoSelecionado = newValue;
                                      subtopicoSelecionado = null;
                                      opcoesSubtopicoAtual =
                                          mapaSubtopicos[newValue] ?? [];
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Dropdown Subtópico
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Subtópico:",
                                  style: TextStyle(
                                    fontFamily: "Arial",
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: subtopicoSelecionado,
                                  isExpanded:
                                      true, // Importante para telas pequenas
                                  decoration: InputDecoration(
                                    hintText: topicoSelecionado == null
                                        ? 'Selecione primeiro o tópico'
                                        : 'Selecione o subtópico',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 16,
                                    ),
                                  ),
                                  items: opcoesSubtopicoAtual.isEmpty
                                      ? [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text(
                                              'Nenhuma opção disponível',
                                            ),
                                          ),
                                        ]
                                      : [
                                          const DropdownMenuItem<String>(
                                            value: null,
                                            child: Text('Selecione o subtópico'),
                                          ),
                                          ...opcoesSubtopicoAtual.map((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ],
                                  onChanged:
                                      topicoSelecionado == null ||
                                          opcoesSubtopicoAtual.isEmpty
                                      ? null
                                      : (String? newValue) {
                                          setStateDialog(() {
                                            subtopicoSelecionado = newValue;
                                          });
                                        },
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        // Versão para telas grandes - horizontal
                        Row(
                          children: [
                            // Dropdown Tópico
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Tópico:",
                                    style: TextStyle(
                                      fontFamily: "Arial",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: topicoSelecionado,
                                    decoration: InputDecoration(
                                      hintText: 'Selecione o tópico',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Selecione o tópico'),
                                      ),
                                      ...opcoesTopico.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (String? newValue) {
                                      setStateDialog(() {
                                        topicoSelecionado = newValue;
                                        subtopicoSelecionado = null;
                                        opcoesSubtopicoAtual =
                                            mapaSubtopicos[newValue] ?? [];
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Dropdown Subtópico
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Subtópico:",
                                    style: TextStyle(
                                      fontFamily: "Arial",
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: subtopicoSelecionado,
                                    decoration: InputDecoration(
                                      hintText: topicoSelecionado == null
                                          ? 'Selecione primeiro o tópico'
                                          : 'Selecione o subtópico',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    items: opcoesSubtopicoAtual.isEmpty
                                        ? [
                                            const DropdownMenuItem<String>(
                                              value: null,
                                              child: Text(
                                                'Nenhuma opção disponível',
                                              ),
                                            ),
                                          ]
                                        : [
                                            const DropdownMenuItem<String>(
                                              value: null,
                                              child: Text(
                                                'Selecione o subtópico',
                                              ),
                                            ),
                                            ...opcoesSubtopicoAtual.map((
                                              String value,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ],
                                    onChanged:
                                        topicoSelecionado == null ||
                                            opcoesSubtopicoAtual.isEmpty
                                        ? null
                                        : (String? newValue) {
                                            setStateDialog(() {
                                              subtopicoSelecionado = newValue;
                                            });
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      // SEÇÃO ANOTAÇÃO
                      const Text(
                        "Anotação",
                        style: TextStyle(
                          fontFamily: "Arial",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: isSmallScreen ? 100 : 80, 
                        child: TextField(
                          controller: anotacaoController,
                          maxLines: null, 
                          expands: true, 
                          textAlignVertical: TextAlignVertical.top, 
                          decoration: const InputDecoration(
                            hintText: "Digite as anotações e informações da imagem",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                limparFormulario();
                Navigator.pop(context);
              },
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
                final imagem = imagemController.text.trim();
                final anotacao = anotacaoController.text.trim();

                if (nome.isEmpty || imagem.isEmpty || anotacao.isEmpty || subtopicoSelecionado == null || subtopicoSelecionado!.isEmpty) {
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
                      "topico": topicoSelecionado,
                      "subtopico": subtopicoSelecionado,
                    };
                  } else {
                    salvarImagem();
                  }
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditando
                          ? "Imagem atualizada com sucesso!"
                          : '',
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

  // CÓDIGO PARA MOSTRAR OS TÓPICOS E SUBTÓPICOS NO DROPDOWN
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
  }

  List<String> carregarTituloTopicos(){
    final estadoTopicos = context.read<EstadoTopicos>();

    return estadoTopicos.topicos.map((topico) => topico.titulo).toList();
  }

  Map<String, List<String>> carregarTituloSubtopicos(){
    final estadoTopicos = context.read<EstadoTopicos>();
    final estadoSubtopicos = context.read<EstadoSubtopicos>();

    return Map.fromEntries(
      estadoTopicos.topicos.map((topico) {
        final subtopicos = estadoSubtopicos.filtrarPorTopico(topico.id);
        return MapEntry(
          topico.titulo, 
          subtopicos.map((sub) => sub.titulo).toList()
          );
      })
    );
  }

  // CÓDIGO PARA ENVIAR AS INFORMAÇÕES PARA O BACKEND
  Future<void> salvarImagem() async {
    final uri = '${protocolo}${baseURL}/images';

    setState(() => enviando = true);

    try {
      final campos = {
        'nomeImagem': nomeController.text,
        'topico': topicoSelecionado!,
        'subtopico': subtopicoSelecionado!,
        'anotacao': anotacaoController.text,
      };

      debugPrint("Arquivo selecionado: $arquivoSelecionado");

      final file = arquivoSelecionado as html.File;

      // 🔹 Usa o FormData nativo do DOM, que suporta stream de arquivo
      final formData = html.FormData();

      // Adiciona campos de texto
      campos.forEach((key, value) {
        formData.append(key, value.toString());
      });

      // Adiciona o arquivo (sem ler os bytes!)
      formData.appendBlob('imagem', file, file.name);

      // 🔹 Envia a requisição usando XMLHttpRequest (por baixo do Dio)
      final xhr = html.HttpRequest();

      xhr.open('POST', uri);
      xhr.responseType = 'json';

      // Opcional: callback de progresso (pode mostrar barra de progresso)
      xhr.upload.onProgress.listen((event) {
        if (event.lengthComputable) {
          final percent = (event.loaded! / event.total!) * 100;
          debugPrint("Progresso upload: ${percent.toStringAsFixed(2)}%");
        }
      });

      // Envia o formulário
      xhr.send(formData);

      // Aguarda término
      await xhr.onLoad.first;

      if (xhr.status == 200) {
        final resp = xhr.response;
        if (resp is Map && resp['message'] == 'Imagem salva com sucesso!') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagem adicionada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception('Erro: ${resp?['error'] ?? 'resposta inválida'}');
        }
      } else {
        throw Exception('Falha HTTP ${xhr.status}: ${xhr.statusText}');
      }

    } catch (erro) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar a imagem no banco!'), backgroundColor: Colors.red),
      );
      debugPrint('$erro');
    } finally {
      setState(() => enviando = false);
      limparFormulario();
    }
  }

  void limparFormulario() {
    setState(() {
      topicoSelecionado = null;
      subtopicoSelecionado = null;
      arquivoSelecionado = null;
    });
    anotacaoController.clear();
    nomeController.clear();
    imagemController.clear();
  }

  @override
  void dispose() {
    anotacaoController.dispose();
    nomeController.dispose();
    super.dispose();
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