import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_topicos.dart';
import '../componentes/cartao_topico.dart';

class PaginaConteudo extends StatelessWidget {
  const PaginaConteudo({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoTopicos>();

    return Scaffold(
      appBar: AppBar(title: const Text('Conteúdos')),
      body: estado.topicos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: estado.topicos.length,
              itemBuilder: (context, i) {
                final topico = estado.topicos[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CartaoTopico(topico: topico),
                );
              },
            ),
    );
  }
}
