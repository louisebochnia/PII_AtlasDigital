import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class OpcaoItem {
  IconData icone;
  String texto;
  OpcaoItem({required this.icone, required this.texto});
}

class _InicioPageState extends State<InicioPage> {
  bool editavel = false;
  final TextEditingController controlador = TextEditingController(
      text: "Este é um texto longo. " * 20);

  // Lista de redes sociais
  List<OpcaoItem> opcoes = [
    OpcaoItem(icone: FontAwesomeIcons.facebook, texto: "Facebook"),
    OpcaoItem(icone: FontAwesomeIcons.instagram, texto: "Instagram"),
    OpcaoItem(icone: FontAwesomeIcons.youtube, texto: "YouTube"),
    OpcaoItem(icone: FontAwesomeIcons.linkedin, texto: "LinkedIn"),
    OpcaoItem(icone: FontAwesomeIcons.twitter, texto: "Twitter"),
  ];

  // Função para definir cor do ícone conforme a rede social
  Color corRedeSocial(IconData icone) {
    if (icone == FontAwesomeIcons.facebook) return const Color.fromARGB(255, 3, 74, 133);
    if (icone == FontAwesomeIcons.instagram) return Colors.pink;
    if (icone == FontAwesomeIcons.youtube) return Colors.red;
    if (icone == FontAwesomeIcons.linkedin) return Colors.blueAccent;
    if (icone == FontAwesomeIcons.twitter) return Colors.lightBlue;
    return Colors.grey;
  }

  Future<String?> _mostrarDialog(BuildContext context, String valorAtual) async {
    TextEditingController c = TextEditingController(text: valorAtual);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar texto", style: TextStyle(fontFamily: "Arial")),
        content: TextField(controller: c, style: const TextStyle(fontFamily: "Arial")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text("Cancelar", style: TextStyle(fontFamily: "Arial")),
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
        const Text(
          "Por que criamos o ATLAS?",
          style: TextStyle(fontSize: 20, fontFamily: "Arial"),
        ),
        const SizedBox(height: 8),

        // Campo de texto rolável com ícone dentro
        Stack(
          children: [
            Container(
              height: 150,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
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
              child: SingleChildScrollView(
                child: TextField(
                  controller: controlador,
                  enabled: editavel,
                  maxLines: null,
                  style: const TextStyle(fontFamily: "Arial"),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: IconButton(
                icon: Icon(editavel ? Icons.check : Icons.edit),
                onPressed: () {
                  setState(() {
                    editavel = !editavel;
                  });
                },
              ),
            ),
          ],
        ),

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
                        FaIcon(item.icone, size: 30, color: corRedeSocial(item.icone)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.texto,
                            style: const TextStyle(fontSize: 16, fontFamily: "Arial"),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () async {
                            String? novo = await _mostrarDialog(context, item.texto);
                            if (novo != null) {
                              setState(() {
                                item.texto = novo;
                              });
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
      ],
    );
  }
}
