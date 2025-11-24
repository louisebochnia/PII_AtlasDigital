import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../componentes/sub_componentes/componenteTopicoshorizontais.dart';
import '../estado/estado_topicos.dart';
import '../estado/estado_subtopicos.dart';
import '../estado/estado_imagem.dart';
import '../modelos/topico.dart';
import '../modelos/subtopicos.dart';
import '../telas/pagina_capitulo.dart';

// Import para detecção de plataforma
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

const double kBreakpoint = 1000;

class PaginaConteudo extends StatefulWidget {
  const PaginaConteudo({super.key});

  @override
  State<PaginaConteudo> createState() => _PaginaConteudoState();
}

class _PaginaConteudoState extends State<PaginaConteudo> {
  late Future<void> _carregamentoFuture;
  String? _baseUrl;

  @override
  void initState() {
    super.initState();
    _carregamentoFuture = _detectarBaseUrlECarregarDados();
  }

  Future<String?> _detectarBaseUrl() async {
    try {
      if (kIsWeb) {
        _baseUrl = 'http://localhost:3000';
        print('Plataforma: Web - usando $_baseUrl');
        return _baseUrl;
      } else {
        print('Plataforma: Mobile - detectando host para conteúdo...');

        // MESMA LÓGICA DAS REDES SOCIAIS - USE O MESMO IP DO SEU COMPUTADOR
        final hosts = [
          'http://192.168.15.163:3000',
          'http://192.168.1.100:3000',
          'http://192.168.0.100:3000', // Outro IP comum
          'http://10.0.2.2:3000', // Android Emulator
          'http://localhost:3000', // iOS Simulator
          'http://10.2.129.68:3000'
        ];

        for (final host in hosts) {
          try {
            print('Testando conexão com: $host/topicos');
            final testUri = Uri.parse('$host/topicos');
            final testResp = await http
                .get(testUri)
                .timeout(const Duration(seconds: 5));

            if (testResp.statusCode == 200) {
              _baseUrl = host;
              print('Conexão bem-sucedida com: $host');
              return _baseUrl;
            } else {
              print('HTTP ${testResp.statusCode} com: $host');
            }
          } catch (e) {
            print('Falha ao conectar com $host: ${e.toString()}');
            continue;
          }
        }

        print('Nenhum host funcionou para conteúdo');
        return null;
      }
    } catch (e) {
      print('Erro ao detectar baseUrl: ${e.toString()}');
      return null;
    }
  }

  Future<void> _carregarDadosDoBanco() async {
    try {
      if (_baseUrl == null) {
        _baseUrl = await _detectarBaseUrl();
      }

      if (_baseUrl == null) {
        throw Exception(
          'Não foi possível conectar ao servidor. Verifique a conexão.',
        );
      }

      final estadoTopicos = Provider.of<EstadoTopicos>(context, listen: false);
      final estadoSubtopicos = Provider.of<EstadoSubtopicos>(
        context,
        listen: false,
      );
      final estadoImagem = Provider.of<EstadoImagem>(context, listen: false);

      debugPrint('-- Carregando dados do banco de $_baseUrl...');

      // USA A BASE_URL DETECTADA
      await estadoTopicos.carregarBanco(baseUrl: _baseUrl);
      await estadoSubtopicos.carregarBanco(baseUrl: _baseUrl);
      await estadoImagem.carregarImagens(baseUrl: _baseUrl);

      debugPrint('-- Dados carregados:');
      debugPrint('   - Tópicos: ${estadoTopicos.topicos.length}');
      debugPrint('   - Subtópicos: ${estadoSubtopicos.subtopicos.length}');
      debugPrint('   - Imagens: ${estadoImagem.imagens.length}');
    } catch (e) {
      debugPrint("-- Erro ao carregar dados do banco: $e");
      rethrow;
    }
  }

  Future<void> _detectarBaseUrlECarregarDados() async {
    await _detectarBaseUrl();
    await _carregarDadosDoBanco();
  }

  void _navegarParaCapitulo(Subtopico subtopico) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelaCapitulo(subtopico: subtopico),
      ),
    );
  }

  // Método para preencher capaUrl dos subtópicos com imagens da API
  List<Subtopico> _preencherImagensSubtopicos(
    List<Subtopico> subtopicos,
    EstadoImagem estadoImagem,
  ) {
    return subtopicos.map((subtopico) {
      final imagemSubtopico = estadoImagem.primeiraImagemPorSubtopico(
        subtopico.titulo,
      );

      if (imagemSubtopico != null) {
        final thumbnailUrl = estadoImagem.converterParaUrl(
          imagemSubtopico.enderecoThumbnail,
          baseUrl: _baseUrl,
        );

        // Cria um novo Subtopico com a URL da imagem
        return Subtopico(
          id: subtopico.id,
          titulo: subtopico.titulo,
          topicoId: subtopico.topicoId,
          indice: subtopico.indice,
          capaUrl: thumbnailUrl,
          informacoes: subtopico.informacoes,
        );
      }

      // Se não encontrou imagem, retorna o subtópico original
      return subtopico;
    }).toList();
  }

  // Agrupa tópicos com seus subtópicos (agora com imagens preenchidas)
  List<Map<String, dynamic>> _agruparTopicosComSubtopicos(
    List<Topico> topicos,
    List<Subtopico> todosSubtopicos,
    EstadoImagem estadoImagem,
  ) {
    return topicos.map((topico) {
      final subtopicosDoTopico = todosSubtopicos
          .where((subtopico) => subtopico.topicoId == topico.id)
          .toList();

      // Preenche as imagens dos subtópicos
      final subtopicosComImagens = subtopicosDoTopico.map((subtopico) {
        final imagemSubtopico = estadoImagem.primeiraImagemPorSubtopico(
          subtopico.titulo,
        );

        if (imagemSubtopico != null) {
          final thumbnailUrl = estadoImagem.converterParaUrl(
            imagemSubtopico.enderecoThumbnail,
            baseUrl: _baseUrl,
          );

          // Cria novo Subtopico com a imagem
          return Subtopico(
            id: subtopico.id,
            titulo: subtopico.titulo,
            topicoId: subtopico.topicoId,
            indice: subtopico.indice,
            capaUrl: thumbnailUrl,
            informacoes: subtopico.informacoes,
          );
        }

        return subtopico;
      }).toList();

      return {
        "titulo": topico.titulo,
        "descricao": topico.resumo,
        "subtopicos": subtopicosComImagens,
      };
    }).toList();
  }

  void _recarregarDados() {
    print('Recarregando dados do conteúdo...');
    setState(() {
      _carregamentoFuture = _detectarBaseUrlECarregarDados();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          const SizedBox(height: 12),
                          Text(
                            "BaseURL: ${_baseUrl ?? 'Não detectada'}",
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _recarregarDados,
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Consumer3<EstadoTopicos, EstadoSubtopicos, EstadoImagem>(
                  builder:
                      (
                        context,
                        estadoTopicos,
                        estadoSubtopicos,
                        estadoImagem,
                        child,
                      ) {
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
                          estadoImagem,
                        );

                        return Column(
                          children: secoes.map((secao) {
                            return SecaoHorizontal(
                              key: ValueKey(secao["titulo"]),
                              titulo: secao["titulo"] as String,
                              descricao: secao["descricao"] as String,
                              subtopicos:
                                  secao["subtopicos"]
                                      as List<
                                        Subtopico
                                      >, // Mantém estrutura original
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
