import 'dart:io';
import 'dart:typed_data';
import 'package:atlas_digital/src/componentes/painelAdm.dart';
import 'package:atlas_digital/src/estado/estado_imagem.dart';
import 'package:atlas_digital/src/estado/estado_subtopicos.dart';
import 'package:atlas_digital/src/estado/estado_topicos.dart';
import 'package:atlas_digital/src/modelos/imagem.dart';
import 'package:atlas_digital/temas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

class GaleriaPage extends StatefulWidget {
  final UploadState? uploadState;

  const GaleriaPage({super.key, this.uploadState});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  final String protocolo = 'http://';
  final String baseURL = 'localhost:3000';
  html.HttpRequest? _xhrUpload;

  List<Map<String, dynamic>> imagensGaleria = [];

  @override
  void initState() {
    super.initState();
    carregarImagens();
  }

  dynamic arquivoSelecionado;
  String? nomeArquivoWeb;
  String? topicoSelecionado;
  String? subtopicoSelecionado;

  final nomeController = TextEditingController();
  final imagemController = TextEditingController();
  final anotacaoController = TextEditingController();

  bool enviando = false;

  Future<void> abrirPopupImagem({int? index}) async {
    final isEditando = index != null;

    await carregarImagens();

    await _carregarTopicos();

    final List<String> opcoesTopico = carregarTituloTopicos();
    final Map<String, List<String>> mapaSubtopicos = carregarTituloSubtopicos();

    // Variáveis para controlar o estado do diálogo
    List<String> opcoesSubtopicoAtual = [];

    if (isEditando) {
      nomeController.text = imagensGaleria[index]['nome'];
      imagemController.text = imagensGaleria[index]['nomeArquivo'];
      anotacaoController.text = imagensGaleria[index]['anotacao'];
      topicoSelecionado = imagensGaleria[index]['topico'];
      subtopicoSelecionado = imagensGaleria[index]['subtopico'];
      opcoesSubtopicoAtual = mapaSubtopicos[topicoSelecionado] ?? [];
    }

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
                      const Text(
                        "Aviso: Para salvar uma imagem é preciso enviar um arquivo ZIP, que inclua o arquivo .mrxs e uma pasta com os .dat da imagem.",
                        style: TextStyle(fontFamily: "Arial", fontSize: 16),
                      ),
                      const SizedBox(width: 14),
                      // Campo e botão para escolher imagem
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: imagemController,
                              style: const TextStyle(fontFamily: "Arial"),
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: "Arquivo Selecionado",
                                hintText: "Nenhum arquivo selecionado",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.image),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: isEditando
                                  ? null
                                  : () async {
                                      final uploadInput =
                                          html.FileUploadInputElement();
                                      uploadInput.accept = '.zip';
                                      uploadInput.click();

                                      await uploadInput.onChange.first;

                                      final file = uploadInput.files!.first;

                                      setState(() {
                                        imagemController.text = file.name;
                                      });
                                      arquivoSelecionado = file;

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Arquivo selecionado: ${file.name}',
                                          ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                            hintText:
                                "Digite as anotações e informações da imagem",
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

                if (nome.isEmpty ||
                    imagem.isEmpty ||
                    anotacao.isEmpty ||
                    subtopicoSelecionado == null ||
                    subtopicoSelecionado!.isEmpty) {
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
                    salvarEdicoes(index);
                  } else {
                    salvarImagem();
                  }
                });

                Navigator.pop(context);
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

  List<String> carregarTituloTopicos() {
    final estadoTopicos = context.read<EstadoTopicos>();

    return estadoTopicos.topicos.map((topico) => topico.titulo).toList();
  }

  Map<String, List<String>> carregarTituloSubtopicos() {
    final estadoTopicos = context.read<EstadoTopicos>();
    final estadoSubtopicos = context.read<EstadoSubtopicos>();

    return Map.fromEntries(
      estadoTopicos.topicos.map((topico) {
        final subtopicos = estadoSubtopicos.filtrarPorTopico(topico.id);
        return MapEntry(
          topico.titulo,
          subtopicos.map((sub) => sub.titulo).toList(),
        );
      }),
    );
  }

  // CÓDIGO PARA ENVIAR AS INFORMAÇÕES PARA O BACKEND
  Future<void> salvarImagem() async {
    final uri = '${protocolo}${baseURL}/images';

    final uploadState = widget.uploadState;

    setState(() {
      enviando = true;
    });

    if (uploadState != null) {
      uploadState.iniciarUpload(_cancelarUpload);
    }

    try {
      final campos = {
        'nomeImagem': nomeController.text,
        'topico': topicoSelecionado!,
        'subtopico': subtopicoSelecionado!,
        'anotacao': anotacaoController.text,
      };

      debugPrint("Arquivo selecionado: $arquivoSelecionado");

      final file = arquivoSelecionado as html.File;

      final formData = html.FormData();

      // Adiciona campos de texto
      campos.forEach((key, value) {
        formData.append(key, value.toString());
      });

      formData.appendBlob('imagem', file, file.name);

      _xhrUpload = html.HttpRequest();

      _xhrUpload!.open('POST', uri);
      _xhrUpload!.responseType = 'json';

      _xhrUpload!.upload.onProgress.listen((event) {
        if (event.lengthComputable) {
          final percent = (event.loaded! / event.total!) * 100;

          // Atualiza o progresso no estado global
          if (uploadState != null && !uploadState.uploadCancelado) {
            uploadState.atualizarProgresso(percent);
          }

          debugPrint("Progresso upload: ${percent.toStringAsFixed(2)}%");
        }
      });

      _xhrUpload!.send(formData);

      await _xhrUpload!.onLoad.first;

      if (uploadState?.uploadCancelado == true) {
        return;
      }

      if (_xhrUpload!.status == 200) {
        final resp = _xhrUpload!.response;
        if (resp is Map && resp['message'] == 'Imagem salva com sucesso!') {
          if (uploadState?.uploadCancelado != true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Imagem adicionada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
            final estadoImagem = context.read<EstadoImagem>();
            await estadoImagem.carregarImagens();
          }
        } else {
          throw Exception('Erro: ${resp?['error'] ?? 'resposta inválida'}');
        }
      } else {
        throw Exception(
          'Falha HTTP ${_xhrUpload!.status}: ${_xhrUpload!.statusText}',
        );
      }
    } catch (erro) {
      if (uploadState?.uploadCancelado != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao salvar a imagem no banco!'),
            backgroundColor: Colors.red,
          ),
        );
        debugPrint('$erro');
      }
    } finally {
      setState(() {
        enviando = false;
      });

      // Finaliza o upload no estado global
      if (uploadState != null) {
        uploadState.finalizarUpload();
      }

      if (uploadState?.uploadCancelado != true) {
        limparFormulario();
      }
    }
  }

  // Cancelar upload da imagem
  void _cancelarUpload() {
    if (_xhrUpload != null) {
      _xhrUpload!.abort();
    }

    setState(() {
      enviando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Upload cancelado'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> carregarImagens() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final estadoImagem = context.read<EstadoImagem>();
      await estadoImagem.carregarImagens();

      setState(() {
        imagensGaleria = pegarImagens();
      });
    });
  }

  List<Map<String, dynamic>> pegarImagens() {
    final estadoImagem = context.read<EstadoImagem>();

    return estadoImagem.imagens
        .map(
          (imagem) => {
            'id': imagem.id,
            'nomeArquivo': imagem.nome_arquivo,
            'nome': imagem.nome_imagem,
            'pastaMrxs': imagem.endereco_pasta_mrxs,
            'thumbnail': imagem.endereco_thumbnail,
            'tiles': imagem.endereco_tiles,
            'topico': imagem.topico,
            'subtopico': imagem.subtopico,
            'anotacao': imagem.anotacao,
            'hiperlinks': imagem.hiperlinks,
          },
        )
        .toList();
  }

  String converterParaUrl(String caminhoRelativo) {
    if (caminhoRelativo.isEmpty) return '';

    final caminhoNormalizado = caminhoRelativo.replaceAll('\\', '/');
    return '$protocolo$baseURL/$caminhoNormalizado';
  }

  Future<void> salvarEdicoes(int index) async {
    debugPrint('Entrou em salvar');

    setState(() => enviando = true);

    try {
      final estadoImagem = context.read<EstadoImagem>();

      final imagemOriginal = estadoImagem.imagens[index];

      final imagemAlterada = new Imagem(
        id: imagemOriginal.id,
        nome_arquivo: imagemOriginal.nome_arquivo,
        nome_imagem: nomeController.text,
        endereco_pasta_mrxs: imagemOriginal.endereco_pasta_mrxs,
        endereco_thumbnail: imagemOriginal.endereco_thumbnail,
        endereco_tiles: imagemOriginal.endereco_tiles,
        topico: topicoSelecionado!,
        subtopico: subtopicoSelecionado!,
        anotacao: anotacaoController.text,
        hiperlinks: imagemOriginal.hiperlinks,
      );

      final foiEditada = await estadoImagem.atualizarImagem(
        imagemAlterada.id,
        imagemAlterada,
      );

      if (foiEditada) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Os dados da imagem foram alterados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        await estadoImagem.carregarImagens();
      }
    } catch (erro) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao salvar os novos dados no banco!'),
          backgroundColor: Colors.red,
        ),
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

  // POPUP PARA DELETAR IMAGEM
  void deletarImagem(int index) async {
    final estadoImagem = context.read<EstadoImagem>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmação"),
        content: const Text("Tem certeza que deseja deletar esta imagem?"),
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
        await estadoImagem.removerImagem(estadoImagem.imagens[index].id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Imagem removida com sucesso")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao remover: $e")));
      }
    }
  }

  @override
  void dispose() {
    anotacaoController.dispose();
    nomeController.dispose();
    // Cancela qualquer upload em andamento ao sair da tela
    if (_xhrUpload != null) {
      _xhrUpload!.abort();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EstadoImagem>(
      builder: (context, estadoImagem, child) {
        final imagens = estadoImagem.imagens;
        return Scaffold(
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: imagens.isEmpty
                          ? Center(
                              // Mostrar mensagem quando não tem nenhuma imagem adicionada
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_search,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    "Nenhuma imagem adicionada",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                      fontFamily: "Arial",
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Clique em 'Nova Imagem' para adicionar a primeira imagem à galeria",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: "Arial",
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: imagens.length,
                              itemBuilder: (context, index) {
                                final imagem = imagens[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      243,
                                      242,
                                      242,
                                    ),
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
                                      Container(
                                        width: 150,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.brandGreen,
                                            width: 2.0,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8.0,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6.5,
                                          ),
                                          child: Image.network(
                                            converterParaUrl(
                                              imagem.endereco_thumbnail,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              imagem.nome_imagem,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                fontFamily: "Arial",
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "Tópico: ${imagem.topico}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Arial",
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              "Subtópico: ${imagem.subtopico}",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Arial",
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.black87,
                                            ),
                                            onPressed: () =>
                                                abrirPopupImagem(index: index),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                deletarImagem(index),
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}