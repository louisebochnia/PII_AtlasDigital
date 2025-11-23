import 'package:flutter/material.dart';
import '../modelos/topico.dart';
import '../modelos/subtopicos.dart';
import '../servicos/ServConteudo.dart'; // Você precisará criar isso
import '../componentes/sub_componentes/componenteTopicoshorizontais.dart';

class PaginaConteudo extends StatefulWidget {
  const PaginaConteudo({super.key});

  @override
  State<PaginaConteudo> createState() => _PaginaConteudoState();
}

class _PaginaConteudoState extends State<PaginaConteudo> {
  late Future<List<Topico>> _topicosFuture;
  final ServicoApi _servicoApi = ServicoApi();

  @override
  void initState() {
    super.initState();
    _topicosFuture = _buscarTopicosComSubtopicos();
  }

  Future<List<Topico>> _buscarTopicosComSubtopicos() async {
    try {
      // Buscar todos os tópicos
      final topicos = await _servicoApi.getTopicos();

      // Para cada tópico, buscar seus subtópicos
      for (final topico in topicos) {
        final subtopicos = await _servicoApi.getSubtopicosPorTopico(topico.id);
        // Você pode querer armazenar em algum lugar ou modificar seu modelo
      }

      return topicos;
    } catch (e) {
      throw Exception('Falha ao carregar tópicos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conteúdo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // Usando seus modelos de dados reais
            FutureBuilder<List<Topico>>(
              future: _topicosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar conteúdo: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final topicos = snapshot.data ?? [];

                if (topicos.isEmpty) {
                  return const Center(
                    child: Text("Nenhum conteúdo disponível"),
                  );
                }

                return Column(
                  children: topicos.map((topico) {
                    return FutureBuilder<List<Subtopico>>(
                      future: _servicoApi.getSubtopicosPorTopico(topico.id),
                      builder: (context, subtopicoSnapshot) {
                        final subtopicos = subtopicoSnapshot.data ?? [];

                        return SecaoHorizontal(
                          titulo: topico.titulo,
                          descricao: topico.resumo,
                          subtopicos: subtopicos,
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
