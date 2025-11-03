import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class GaleriaPage extends StatefulWidget {
  const GaleriaPage({super.key});

  @override
  State<GaleriaPage> createState() => _GaleriaPageState();
}

class _GaleriaPageState extends State<GaleriaPage> {
  List<Map<String, dynamic>> imagensGaleria = [
    {"nome": "Célula eucarionte", "imagem": "https://exemplo.com/img1.png"},
    {"nome": "Tecido epitelial", "imagem": "https://exemplo.com/img2.png"},
  ];

  void abrirPopupImagem({int? index}) {
    final isEditando = index != null;
    final nomeController = TextEditingController(
      text: isEditando ? imagensGaleria[index!]['nome'] : '',
    );
    final imagemController = TextEditingController(
      text: isEditando ? imagensGaleria[index!]['imagem'] : '',
    );

    final List<String> opcoesTopico = [
      'Biologia Celular',
      'Histologia Geral',
      'Histologia Especial',
    ];

    final Map<String, List<String>> mapaSubtopicos = {
      'Biologia Celular': [
        'Célula eucarionte',
        'Especializações de membrana',
        'Núcleo celular',
      ],
      'Histologia Geral': [
        'Tecido epitelial',
        'Tecido conjuntivo propriamente dito',
        'Tecido cartilaginoso',
        'Tecido ósseo',
        'Sangue e medula óssea',
        'Tecido muscular',
        'Tecido nervoso e Sistema nervoso',
      ],
      'Histologia Especial': [
        'Sistema cardiovascular',
        'Sistema linfático',
        'Sistema respiratório',
        'Sistema digestório',
        'Sistema endócrino',
        'Sistema genital feminino',
        'Sistema genital masculino',
        'Sistema sensorial',
      ],
    };

    // Variáveis para controlar o estado do diálogo
    String? topicoSelecionado;
    String? subtopicoSelecionado;
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
                              decoration: const InputDecoration(
                                labelText: "URL ou caminho da imagem",
                                hintText:
                                    "Ex: https://site.com/imagem.png ou C:/imagens/foto.png",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(type: FileType.image);
                                if (result != null &&
                                    result.files.single.path != null) {
                                  imagemController.text =
                                      result.files.single.path!;
                                }
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
                      "topico": topicoSelecionado,
                      "subtopico": subtopicoSelecionado,
                    };
                  } else {
                    imagensGaleria.add({
                      "nome": nome,
                      "imagem": imagem,
                      "topico": topicoSelecionado,
                      "subtopico": subtopicoSelecionado,
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