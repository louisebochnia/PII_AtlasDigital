import 'package:flutter/material.dart';

class AdministradoresPage extends StatefulWidget {
  const AdministradoresPage({super.key});

  @override
  State<AdministradoresPage> createState() => _AdministradoresPageState();
}

class _AdministradoresPageState extends State<AdministradoresPage> {
  List<Map<String, dynamic>> administradores = [
    {"nome": "Administrador Secundário"},
    {"nome": "Servidor Principal"},
  ];

  void abrirPopupAdministrador({int? index}) {
    final isEditando = index != null;
    final nomeController = TextEditingController(
      text: isEditando ? administradores[index]['nome'] : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditando ? "Editar Administrador" : "Novo Administrador",
            style: const TextStyle(fontFamily: "Arial"),
          ),
          content: TextField(
            controller: nomeController,
            style: const TextStyle(fontFamily: "Arial"),
            decoration: const InputDecoration(
              labelText: "Nome",
              border: OutlineInputBorder(),
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
                if (nome.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                      "Preencha o campo antes de salvar",
                      style: TextStyle(fontFamily: "Arial"),
                    )),
                  );
                  return;
                }

                setState(() {
                  if (isEditando) {
                    administradores[index] = {"nome": nome};
                  } else {
                    administradores.add({"nome": nome});
                  }
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditando
                          ? "Administrador atualizado com sucesso!"
                          : "Novo administrador adicionado!",
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

  void deletarAdministrador(int index) {
    setState(() {
      administradores.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Administrador removido com sucesso",
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
          'Administradores',
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
            onPressed: () => abrirPopupAdministrador(),
            icon: const Icon(Icons.add),
            label: const Text(
              "Novo Administrador",
              style: TextStyle(fontFamily: "Arial"),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: ListView.builder(
            itemCount: administradores.length,
            itemBuilder: (context, index) {
              final admin = administradores[index];
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
                        admin['nome'],
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
                          onPressed: () =>
                              abrirPopupAdministrador(index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deletarAdministrador(index),
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
