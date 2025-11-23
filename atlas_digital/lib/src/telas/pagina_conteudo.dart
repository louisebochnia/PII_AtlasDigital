import 'package:atlas_digital/src/estado/estado_subtopicos.dart';
import 'package:atlas_digital/src/estado/estado_topicos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/topico.dart';
import '../modelos/subtopicos.dart';
import '../componentes/sub_componentes/componenteTopicoshorizontais.dart';

// Classe para agrupar tópico com seus subtópicos (fora da classe principal)
class TopicoComSubtopicos {
  final Topico topico;
  final List<Subtopico> subtopicos;
  
  TopicoComSubtopicos({required this.topico, required this.subtopicos});
}

class PaginaConteudo extends StatefulWidget {
  const PaginaConteudo({super.key});

  @override
  State<PaginaConteudo> createState() => _PaginaConteudoState();
}

class _PaginaConteudoState extends State<PaginaConteudo> {
  late Future<void> _carregamentoFuture;

  @override
  void initState() {
    super.initState();
    _carregamentoFuture = _carregarTopicos();
  }

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

  List<Topico> carregarTopicos() {
    final estadoTopicos = context.read<EstadoTopicos>();
    return estadoTopicos.topicos.map((topico) => topico).toList();
  }

  List<TopicoComSubtopicos> carregarTopicosComSubtopicos() {
    final estadoTopicos = context.read<EstadoTopicos>();
    final estadoSubtopicos = context.read<EstadoSubtopicos>();

    return estadoTopicos.topicos.map((topico) {
      final subtopicos = estadoSubtopicos.filtrarPorTopico(topico.id);
      return TopicoComSubtopicos(
        topico: topico,
        subtopicos: subtopicos,
      );
    }).toList();
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

            // Usando os dados carregados localmente
            FutureBuilder<void>(
              future: _carregamentoFuture,
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

                final topicosComSubtopicos = carregarTopicosComSubtopicos();

                if (topicosComSubtopicos.isEmpty) {
                  return const Center(
                    child: Text("Nenhum conteúdo disponível"),
                  );
                }

                return Column(
                  children: topicosComSubtopicos.map((item) {
                    return SecaoHorizontal(
                      titulo: item.topico.titulo,
                      descricao: item.topico.resumo,
                      subtopicos: item.subtopicos,
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