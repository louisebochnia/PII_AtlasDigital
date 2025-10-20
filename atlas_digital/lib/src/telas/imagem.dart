import 'package:flutter/material.dart';

class Imagem extends StatelessWidget {
  const Imagem({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Página Inicial")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/conteudos'),
              child: const Text("Ir para Conteúdos"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/adm/conteudos'),
              child: const Text("Ir para Admin Provisório"),
            ),
          ],
        ),
      ),
    );
  }
}