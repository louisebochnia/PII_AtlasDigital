import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/sub_componentes/componenteTopicoshorizontais.dart';
import '../estado/estado_topicos.dart';
import '../estado/estado_subtopicos.dart';
import '../modelos/topico.dart';
import '../modelos/subtopicos.dart';
import '../telas/pagina_capitulo.dart';

// O ponto de quebra deve ser definido consistentemente com a TopNavBar
const double kBreakpoint = 1000;

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
    _carregamentoFuture = _carregarDadosDoBanco();
  }

  Future<void> _carregarDadosDoBanco() async {
    try {
      final estadoTopicos = Provider.of<EstadoTopicos>(context, listen: false);
      final estadoSubtopicos = Provider.of<EstadoSubtopicos>(
        context,
        listen: false,
      );

      debugPrint('-- Carregando dados do banco...');

      await estadoTopicos.carregarBanco();
      await estadoSubtopicos.carregarBanco();

      debugPrint('-- Dados carregados:');
      debugPrint('   - Tópicos: ${estadoTopicos.topicos.length}');
      debugPrint('   - Subtópicos: ${estadoSubtopicos.subtopicos.length}');
    } catch (e) {
      debugPrint("-- Erro ao carregar dados do banco: $e");
      rethrow;
    }
  }

  // Método para navegar para a página do capítulo 
  void _navegarParaCapitulo(Subtopico subtopico) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCapitulo(subtopico: subtopico), 
      ),
    );
  }

  // Agrupa tópicos com seus subtópicos
  List<Map<String, dynamic>> _agruparTopicosComSubtopicos(
    List<Topico> topicos,
    List<Subtopico> todosSubtopicos,
  ) {
    return topicos.map((topico) {
      final subtopicosDoTopico = todosSubtopicos
          .where((subtopico) => subtopico.topicoId == topico.id)
          .toList();

      return {
        "titulo": topico.titulo,
        "descricao": topico.resumo,
        "subtopicos": subtopicosDoTopico,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // 1. LÓGICA RESPONSIVA DE MARGEM
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth > kBreakpoint ? 80 : 20;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conteúdo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),

            // FutureBuilder que carrega as seções com dados reais
            FutureBuilder<void>(
              future: _carregamentoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 20),
                          Text('Carregando conteúdo do banco de dados...'),
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Erro ao carregar conteúdo",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Detalhes: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _carregamentoFuture = _carregarDadosDoBanco();
                              });
                            },
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Consumer2<EstadoTopicos, EstadoSubtopicos>(
                  builder: (context, estadoTopicos, estadoSubtopicos, child) {
                    final topicos = estadoTopicos.topicos;
                    final todosSubtopicos = estadoSubtopicos.subtopicos;

                    if (topicos.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Nenhum conteúdo disponível",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final secoes = _agruparTopicosComSubtopicos(
                      topicos,
                      todosSubtopicos,
                    );

                    return Column(
                      children: secoes.map((secao) {
                        return SecaoHorizontal(
                          key: ValueKey(secao["titulo"]),
                          titulo: secao["titulo"] as String,
                          descricao: secao["descricao"] as String,
                          subtopicos: secao["subtopicos"] as List<Subtopico>,
                          onAcessarSubtopico: _navegarParaCapitulo,
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}