import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

String linkQuiz = "Coloque o link do quiz aqui";

class OpcaoItem {
  IconData icone;
  String texto;
  String link;
  String? id;
  OpcaoItem({required this.icone, required this.texto, required this.link, this.id});
}

class _InicioPageState extends State<InicioPage> {
  bool editavel = false;
  final TextEditingController controlador = TextEditingController(
    text: "Este é um texto longo. " * 20,
  );

  // Lista de redes sociais (fallback hardcoded). Será atualizada ao carregar do banco.
  List<OpcaoItem> opcoes = [
    OpcaoItem(icone: FontAwesomeIcons.facebook, texto: "Facebook", link: ""),
    OpcaoItem(icone: FontAwesomeIcons.instagram, texto: "Instagram", link: ""),
    OpcaoItem(icone: FontAwesomeIcons.youtube, texto: "YouTube", link: ""),
    OpcaoItem(icone: FontAwesomeIcons.linkedin, texto: "LinkedIn", link: ""),
  ];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarOpcoesDoBanco();
  }

  Future<void> _carregarOpcoesDoBanco() async {
    try {
      final uri = Uri.parse('http://localhost:3000/hyperlink');
      final resp = await http.get(uri).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        setState(() {
          opcoes = data.map<OpcaoItem>((item) {
            final String nome = (item['nome'] as String?) ?? 'link';
            final String link = (item['link'] as String?) ?? '';
            final String? id = (item['_id'] as String?) ?? (item['id'] as String?);
            return OpcaoItem(
              icone: _iconePorNome(nome),
              texto: _textoPorNome(nome),
              link: link,
              id: id,
            );
          }).toList();
          carregando = false;
        });
      } else {
        setState(() => carregando = false);
      }
    } catch (e) {
      setState(() => carregando = false);
    }
  }

  Future<String?> _salvarLinkNoBanco(OpcaoItem item, String novoLink) async {
    try {
      if (item.id == null || item.id!.isEmpty) {
        return 'ID não encontrado. Execute seed.js no backend primeiro.';
      }
      final uri = Uri.parse('http://localhost:3000/hyperlink/${item.id}');
      final resp = await http.put(uri,
          body: json.encode({'nome': item.texto.toLowerCase(), 'link': novoLink}),
          headers: {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        return null; // sucesso
      } else {
        // tentar extrair mensagem de erro do backend
        try {
          final body = json.decode(resp.body);
          final msg = body['message'] ?? body['error'] ?? resp.body;
          return '${resp.statusCode}: $msg';
        } catch (e) {
          return '${resp.statusCode}: ${resp.body}';
        }
      }
    } catch (e) {
      return 'Erro: $e';
    }
  }

  IconData _iconePorNome(String nome) {
    switch (nome.toLowerCase()) {
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'linkedin':
        return FontAwesomeIcons.linkedin;
      case 'quiz':
        return FontAwesomeIcons.circleQuestion;
      default:
        return FontAwesomeIcons.link;
    }
  }

  String _textoPorNome(String nome) {
    if (nome.isEmpty) return '';
    return nome[0].toUpperCase() + nome.substring(1);
  }

  // Função para definir cor do ícone conforme a rede social
  Color corRedeSocial(IconData icone) {
    if (icone == FontAwesomeIcons.facebook)
      return const Color.fromARGB(255, 3, 74, 133);
    if (icone == FontAwesomeIcons.instagram) return Colors.pink;
    if (icone == FontAwesomeIcons.youtube) return Colors.red;
    if (icone == FontAwesomeIcons.linkedin) return Colors.blueAccent;
    return Colors.grey;
  }

  Future<String?> _mostrarDialog(
    BuildContext context,
    String valorAtual,
  ) async {
    TextEditingController c = TextEditingController(text: valorAtual);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar link", style: TextStyle(fontFamily: "Arial")),
        content: TextField(
          controller: c,
          style: const TextStyle(fontFamily: "Arial"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text(
              "Cancelar",
              style: TextStyle(fontFamily: "Arial"),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: const Text("Salvar", style: TextStyle(fontFamily: "Arial")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tela Inicial",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Arial",
          ),
        ),
        // const Text(
        //   "Por que criamos o ATLAS?",
        //   style: TextStyle(fontSize: 20, fontFamily: "Arial"),
        // ),
        // const SizedBox(height: 8),

        // // Campo de texto rolável com ícone dentro
        // Stack(
        //   children: [
        //     Container(
        //       height: 150,
        //       padding: const EdgeInsets.all(8),
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         border: Border.all(color: Colors.grey),
        //         borderRadius: BorderRadius.circular(12),
        //         boxShadow: [
        //           BoxShadow(
        //             color: Colors.grey.withOpacity(0.5),
        //             spreadRadius: 2,
        //             blurRadius: 5,
        //             offset: const Offset(0, 0),
        //           ),
        //         ],
        //       ),
        //       child: SingleChildScrollView(
        //         child: TextField(
        //           controller: controlador,
        //           enabled: editavel,
        //           maxLines: null,
        //           style: const TextStyle(fontFamily: "Arial"),
        //           decoration: const InputDecoration(border: InputBorder.none),
        //         ),
        //       ),
        //     ),
        //     Positioned(
        //       bottom: 4,
        //       right: 4,
        //       child: IconButton(
        //         icon: Icon(editavel ? Icons.check : Icons.edit),
        //         onPressed: () {
        //           setState(() {
        //             editavel = !editavel;
        //           });
        //         },
        //       ),
        //     ),
        //   ],
        // ),

        const SizedBox(height: 24),

        const Text(
          "Redes",
          style: TextStyle(fontSize: 18, fontFamily: "Arial"),
        ),
        const SizedBox(height: 8),

        // Lista de redes sociais responsiva
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opcoes.map((item) {
                  return Container(
                    width: 200,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                        FaIcon(
                          item.icone,
                          size: 30,
                          color: corRedeSocial(item.icone),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.texto,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "Arial",
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () async {
                            String? novo = await _mostrarDialog(
                              context,
                              item.link,
                            );
                            if (novo != null) {
                              // tenta salvar no banco
                              final erroMsg = await _salvarLinkNoBanco(item, novo);
                              if (erroMsg == null) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('✓ Alterações salvas no banco')),
                                  );
                                }
                                setState(() {
                                  item.link = novo;
                                });
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('✗ Falha: $erroMsg')),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        // const SizedBox(height: 24),

        // const Text("Quiz", style: TextStyle(fontSize: 18, fontFamily: "Arial")),
        // const SizedBox(height: 8),

        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     border: Border.all(color: Colors.grey),
        //     borderRadius: BorderRadius.circular(12),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.grey.withOpacity(0.5),
        //         spreadRadius: 2,
        //         blurRadius: 5,
        //         offset: const Offset(0, 0),
        //       ),
        //     ],
        //   ),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: Text(
        //           linkQuiz,
        //           style: TextStyle(
        //             fontSize: 16,
        //             fontFamily: "Arial",
        //             // Fica cinza se for o texto padrão, preto se for um link
        //             color: linkQuiz == "Coloque o link do quiz aqui"
        //                 ? Colors.grey
        //                 : Colors.black,
        //           ),
        //           overflow: TextOverflow.ellipsis,
        //         ),
        //       ),
        //       IconButton(
        //         icon: const Icon(Icons.edit, size: 20),
        //         onPressed: () async {
        //           // Reutiliza sua função _mostrarDialog existente
        //           String? novo = await _mostrarDialog(context, linkQuiz);
        //           if (novo != null) {
        //             setState(() {
        //               linkQuiz = novo;
        //             });
        //           }
        //         },
        //       ),
        //     ],
        //   ),
        // ),

        // Adicione um espaço extra no final para não grudar na borda
        const SizedBox(height: 20),
      ],
    );
  }
}
