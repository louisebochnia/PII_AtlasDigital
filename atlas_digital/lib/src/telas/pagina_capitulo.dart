import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:atlas_digital/src/componentes/sub_componentes/popup_login.dart';
import 'package:atlas_digital/src/telas/painelAdm.dart';
import 'package:atlas_digital/src/estado/estado_navegacao.dart';
import 'package:atlas_digital/src/componentes/rodape.dart';
import 'package:atlas_digital/src/componentes/barra_de_navegacao.dart';
import 'package:atlas_digital/src/modelos/subtopicos.dart';
import 'package:atlas_digital/src/modelos/topico.dart';
import 'package:atlas_digital/src/estado/estado_usuario.dart';
import 'package:atlas_digital/src/estado/estado_subtopicos.dart';
import 'package:atlas_digital/src/estado/estado_topicos.dart';
import 'package:atlas_digital/src/estado/estado_imagem.dart';
import 'package:atlas_digital/temas.dart';
import 'package:atlas_digital/app_shell.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'pagina_imagem.dart';

bool get isDesktopOrWeb {
  if (kIsWeb) return true;
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

class TelaCapitulo extends StatefulWidget {
  final Subtopico subtopico;

  const TelaCapitulo({super.key, required this.subtopico});

  @override
  State<TelaCapitulo> createState() => _TelaCapituloState();
}

class _TelaCapituloState extends State<TelaCapitulo> {
  // Controle de expansão das descrições
  List<bool> expandido = [];

  // Controlador para o scroll horizontal
  final ScrollController controller = ScrollController();

  // Estado simples para a navbar
  int _indiceSelecionado = 1;

  // Variável para armazenar o nome do tópico
  String? _nomeTopico;

  // Variáveis para o link do quiz
  String _quizLink = 'https://kahoot.com/pt-BR';
  bool _carregandoQuizLink = false;

  // URLs das redes sociais
  String? _urlInstagram;
  String? _urlFacebook;
  String? _urlLinkedIn;
  String? _urlYouTube;

  @override
  void initState() {
    super.initState();
    expandido = List.filled(widget.subtopico.informacoes.length, false);
    _carregarNomeTopico();
    _carregarQuizLink();
    _carregarRedesSociais();
  }

  // Método para carregar o nome do tópico
  void _carregarNomeTopico() {
    final estadoTopicos = Provider.of<EstadoTopicos>(context, listen: false);

    Topico? topicoEncontrado;
    try {
      topicoEncontrado = estadoTopicos.topicos.firstWhere(
        (topico) => topico.id == widget.subtopico.topicoId,
      );
    } catch (e) {
      topicoEncontrado = null;
    }

    setState(() {
      _nomeTopico = topicoEncontrado?.titulo ?? 'Tópico';
    });
  }

  // Método para ir para área admin
  void _irParaAreaAdmin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PainelAdm()),
    );
  }

  // Método para carregar o link do quiz da API
  Future<void> _carregarQuizLink() async {
    if (_carregandoQuizLink) return;

    setState(() {
      _carregandoQuizLink = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/hyperlink'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Busca o link do Kahoot pelo nome
        if (data is List && data.isNotEmpty) {
          final kahootLink = data.firstWhere(
            (item) => item['nome'] == 'kahoot' || item['nome'] == 'quizzes',
            orElse: () => null,
          );

          if (kahootLink != null) {
            setState(() {
              _quizLink = kahootLink['link'];
            });
          }
        }
      } else {
        throw Exception('Falha ao carregar link: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar link do quiz: $e');
    } finally {
      setState(() {
        _carregandoQuizLink = false;
      });
    }
  }

  // Método para carregar redes sociais
  Future<void> _carregarRedesSociais() async {
    try {
      final uri = Uri.parse('http://localhost:3000/hyperlink');
      final resp = await http.get(uri).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        for (final item in data) {
          final nome = (item['nome'] as String?)?.toLowerCase();
          final link = item['link'] as String?;
          if (nome == 'instagram') _urlInstagram = link;
          if (nome == 'facebook') _urlFacebook = link;
          if (nome == 'linkedin') _urlLinkedIn = link;
          if (nome == 'youtube') _urlYouTube = link;
        }
        setState(() {});
      }
    } catch (e) {
      // ignore erro
    }
  }

  // Método para abrir links
  Future<void> _abrirLink(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (!await canLaunchUrl(uri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir: $urlString')),
        );
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir link: ${e.toString()}')),
      );
    }
  }

  // Método para abrir site FMABC
  void _abrirSiteFMABC() async {
    const url = 'https://www.fmabc.br';
    await _abrirLink(url);
  }

  // Método para abrir quizzes
  void _abrirQuizzes() async {
    await _abrirLink(_quizLink);
  }

  // Método para abrir o atlas (página de imagem)
  void _abrirAtlas() {
    final estadoImagem = Provider.of<EstadoImagem>(context, listen: false);
    
    // Busca a primeira imagem relacionada a este subtópico
    final imagensDoSubtopico = estadoImagem.imagensPorSubtopico(widget.subtopico.titulo);
    
    if (imagensDoSubtopico.isNotEmpty) {
      final imagem = imagensDoSubtopico.first;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaginaImagem(
            imagemId: imagem.id,
            nomeImagem: imagem.nomeImagem,
            topico: imagem.topico,
            subtopico: imagem.subtopico,
            thumbnailUrl: estadoImagem.converterParaUrl(imagem.enderecoThumbnail),
          ),
        ),
      );
    } else {
      // Se não encontrar imagem, mostra um snackbar informativo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nenhuma imagem encontrada para este capítulo'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Métodos para redes sociais
  void _abrirInstagram() async {
    final url =
        _urlInstagram ?? 'https://www.instagram.com/centrouniversitariofmabc/';
    await _abrirLink(url);
  }

  void _abrirFacebook() async {
    final url =
        _urlFacebook ?? 'https://www.facebook.com/CentroUniversitarioFMABC/';
    await _abrirLink(url);
  }

  void _abrirLinkedIn() async {
    final url = _urlLinkedIn ?? 'https://br.linkedin.com/school/fmabc/';
    await _abrirLink(url);
  }

  void _abrirYouTube() async {
    final url =
        _urlYouTube ??
        'https://www.youtube.com/channel/UCJ_wO9afToh1XyMoUcGY8qw';
    await _abrirLink(url);
  }

  void _onItemTap(int index) {
    final estadoNavegacao = Provider.of<EstadoNavegacao>(
      context,
      listen: false,
    );

    // Define o índice no estado global
    estadoNavegacao.mudarIndice(index);

    // Volta para o AppShell que vai ler o índice do EstadoNavegacao
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // Se não pode pop (é a primeira tela), vai para o AppShell
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AppShell()),
        (route) => false,
      );
    }
  }

  void _onAtlas() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // Adicione estes métodos na _TelaCapituloState
  void _irParaInicio() {
    if (Navigator.canPop(context)) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AppShell()),
        (route) => false,
      );
    }
  }

  void _irParaConteudo() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _irParaGaleria() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _onLogin() {
    final estadoUsuario = Provider.of<EstadoUsuario>(context, listen: false);

    if (estadoUsuario.estaLogado) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PainelAdm()),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return const LoginPopup();
        },
      );
    }
  }

  // Método para preencher capaUrl dos subtópicos com imagens da API
  Subtopico _preencherImagemSubtopico(
    Subtopico subtopico,
    EstadoImagem estadoImagem,
  ) {
    final imagemSubtopico = estadoImagem.primeiraImagemPorSubtopico(
      subtopico.titulo,
    );

    if (imagemSubtopico != null) {
      final thumbnailUrl = estadoImagem.converterParaUrl(
        imagemSubtopico.enderecoThumbnail,
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
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: TopNavBar(
        selectedIndex: _indiceSelecionado,
        onItemTap: _onItemTap,
        onAtlas: _onAtlas,
        onLogin: _onLogin,
      ),
      body: CustomScrollView(
        slivers: [
          // Conteúdo principal do capítulo
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 160,
                vertical: isMobile ? 20 : 40,
              ),
              child: Column(
                children: [
                  // Botão de voltar
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.red,
                        size: isMobile ? 14 : 16,
                      ),
                      label: Text(
                        'Voltar',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // TÍTULO DO TÓPICO
                  Text(
                    _nomeTopico ?? 'Carregando...',
                    style: TextStyle(
                      fontSize: isMobile ? 28 : 40,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: isMobile ? TextAlign.center : TextAlign.left,
                  ),

                  const SizedBox(height: 16),

                  // Lista de informações do subtópico
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(isMobile ? 8 : 16),
                    itemCount: widget.subtopico.informacoes.length,
                    itemBuilder: (context, index) {
                      final informacao = widget.subtopico.informacoes[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isMobile) ...[
                            Consumer<EstadoImagem>(
                              builder: (context, estadoImagem, child) {
                                final subtopicoComImagem =
                                    _preencherImagemSubtopico(
                                      widget.subtopico,
                                      estadoImagem,
                                    );

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    subtopicoComImagem.capaUrl ??
                                        'assets/placeholder.png',
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 200,
                                        color: Colors.grey[300],
                                        child: Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // TÍTULO DO SUBTÓPICO + CAPÍTULO (MOBILE)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.subtopico.titulo,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: isMobile ? 24 : 32,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Capítulo ${widget.subtopico.indice.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isMobile ? 14 : 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // BOTÕES (MOBILE)
                            Column(
                              children: [
                                const Text(
                                  'Conteúdos Relacionados',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // BOTÃO VER QUIZZES
                                if (_carregandoQuizLink)
                                  const CircularProgressIndicator()
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    child: TextButton(
                                      onPressed: _abrirQuizzes,
                                      style: TextButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          44,
                                        ),
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          100,
                                          55,
                                          255,
                                        ),
                                        foregroundColor: const Color.fromARGB(
                                          255,
                                          255,
                                          255,
                                          255,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          height: 1.2,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      child: const Text('VER QUIZZES'),
                                    ),
                                  ),
                                const SizedBox(height: 8),

                                // Botão ABRIR ATLAS
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: _abrirAtlas, // ← CORRIGIDO
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        44,
                                      ),
                                      backgroundColor: AppColors.brandGreen,
                                      foregroundColor: const Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    child: const Text('ABRIR ATLAS'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ] else ...[
                            // DESKTOP: Layout em linha
                            Consumer<EstadoImagem>(
                              builder: (context, estadoImagem, child) {
                                final subtopicoComImagem =
                                    _preencherImagemSubtopico(
                                      widget.subtopico,
                                      estadoImagem,
                                    );

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Imagem do subtópico
                                    Flexible(
                                      flex: 6,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          subtopicoComImagem.capaUrl ??
                                              'assets/placeholder.png',
                                          width: double.infinity,
                                          height: 400,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: double.infinity,
                                                  height: 400,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.image,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Flexible(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // TÍTULO DO SUBTÓPICO + CAPÍTULO
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.subtopico.titulo,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Capítulo ${widget.subtopico.indice.toString().padLeft(2, '0')}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 80),
                                          const Text(
                                            'Conteúdos Relacionados',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),

                                          // BOTÃO VER QUIZZES
                                          if (_carregandoQuizLink)
                                            const CircularProgressIndicator()
                                          else
                                            TextButton(
                                              onPressed: _abrirQuizzes,
                                              style: TextButton.styleFrom(
                                                minimumSize: const Size(
                                                  double.infinity,
                                                  44,
                                                ),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      100,
                                                      55,
                                                      255,
                                                    ),
                                                foregroundColor:
                                                    const Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                textStyle: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.2,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                              child: const Text('VER QUIZZES'),
                                            ),
                                          const SizedBox(height: 12),

                                          // Botão ABRIR ATLAS
                                          TextButton(
                                            onPressed: _abrirAtlas, // ← CORRIGIDO
                                            style: TextButton.styleFrom(
                                              minimumSize: const Size(
                                                double.infinity,
                                                44,
                                              ),
                                              backgroundColor:
                                                  AppColors.brandGreen,
                                              foregroundColor:
                                                  const Color.fromARGB(
                                                    255,
                                                    255,
                                                    255,
                                                    255,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              textStyle: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                height: 1.2,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                            child: const Text('ABRIR ATLAS'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],

                          // CONTEÚDO DA INFORMAÇÃO (igual para mobile e desktop)
                          const SizedBox(height: 16),
                          Text(
                            informacao.informacao,
                            maxLines: expandido[index] ? null : 6,
                            overflow: expandido[index]
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  expandido[index] = !expandido[index];
                                });
                              },
                              child: Text(
                                expandido[index] ? "Ler menos" : "Ler mais",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 45, 210, 255),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),

                  // Seção de subtópicos relacionados
                  Consumer3<EstadoSubtopicos, EstadoImagem, EstadoTopicos>(
                    builder:
                        (
                          context,
                          estadoSubtopicos,
                          estadoImagem,
                          estadoTopicos,
                          child,
                        ) {
                          final subtopicosRelacionados = estadoSubtopicos
                              .subtopicos
                              .where(
                                (subtopico) =>
                                    subtopico.topicoId ==
                                        widget.subtopico.topicoId &&
                                    subtopico.id != widget.subtopico.id,
                              )
                              .toList();

                          if (subtopicosRelacionados.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          // Preenche as imagens dos subtópicos relacionados
                          final subtopicosComImagens = subtopicosRelacionados
                              .map((subtopico) {
                                return _preencherImagemSubtopico(
                                  subtopico,
                                  estadoImagem,
                                );
                              })
                              .toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  12,
                                  12,
                                  0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Outros Capítulos do Mesmo Tópico',
                                        style: TextStyle(
                                          fontSize: isMobile ? 18 : 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'Capítulos: ${subtopicosComImagens.length}',
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              SizedBox(
                                height: isMobile ? 200 : 230,
                                child: Scrollbar(
                                  controller: controller,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  thickness: 6,
                                  radius: const Radius.circular(10),
                                  child: ListView.builder(
                                    controller: controller,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: subtopicosComImagens.length,
                                    itemBuilder: (context, index) {
                                      final subtopicoRelacionado =
                                          subtopicosComImagens[index];

                                      return Container(
                                        margin: EdgeInsets.fromLTRB(
                                          0,
                                          0,
                                          isMobile ? 16 : 24,
                                          8,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        width: isMobile ? 200 : 240,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                            255,
                                            231,
                                            230,
                                            230,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Imagem - AGORA PEGANDO DO BANCO
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                subtopicoRelacionado.capaUrl ??
                                                    'assets/placeholder.png',
                                                height: isMobile ? 100 : 120,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        height: isMobile
                                                            ? 100
                                                            : 120,
                                                        width: double.infinity,
                                                        color: Colors.grey[300],
                                                        child: Icon(
                                                          Icons.image,
                                                          size: isMobile
                                                              ? 30
                                                              : 40,
                                                          color: Colors.grey,
                                                        ),
                                                      );
                                                    },
                                              ),
                                            ),
                                            const SizedBox(height: 8),

                                            // Número do capítulo
                                            Text(
                                              'Capítulo ${subtopicoRelacionado.indice.toString().padLeft(2, '0')}',
                                              style: TextStyle(
                                                fontSize: isMobile ? 10 : 12,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),

                                            // Título com altura flexível
                                            Expanded(
                                              child: Text(
                                                subtopicoRelacionado.titulo,
                                                style: TextStyle(
                                                  fontSize: isMobile ? 14 : 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(height: 8),

                                            // Botão de acessar
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TelaCapitulo(
                                                            subtopico:
                                                                subtopicoRelacionado,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: isMobile
                                                        ? 8
                                                        : 12,
                                                    vertical: isMobile ? 4 : 6,
                                                  ),
                                                  minimumSize: Size.zero,
                                                  tapTargetSize:
                                                      MaterialTapTargetSize
                                                          .shrinkWrap,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Acessar',
                                                      style: TextStyle(
                                                        color:
                                                            const Color.fromARGB(
                                                              255,
                                                              170,
                                                              14,
                                                              170,
                                                            ),
                                                        fontSize: isMobile
                                                            ? 12
                                                            : 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Icon(
                                                      Icons
                                                          .arrow_right_alt_sharp,
                                                      color:
                                                          const Color.fromARGB(
                                                            255,
                                                            170,
                                                            14,
                                                            170,
                                                          ),
                                                      size: isMobile ? 16 : 20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                  ),
                ],
              ),
            ),
          ),

          // Rodapé
          SliverToBoxAdapter(
            child: Consumer2<EstadoNavegacao, EstadoUsuario>(
              builder: (context, estadoNavegacao, estadoUsuario, child) {
                return Rodape(
                  logoAsset: 'assets/logo_fmabc.png',
                  colunas: [
                    FooterColumnData(
                      titulo: 'Navegação',
                      itens: [
                        FooterItem('Início', onTap: _irParaInicio),
                        FooterItem('Conteúdo', onTap: _irParaConteudo),
                        FooterItem('Galeria', onTap: _irParaGaleria),
                      ],
                    ),
                    FooterColumnData(
                      titulo: 'Recursos',
                      itens: [
                        FooterItem('Quizzes', onTap: _abrirQuizzes),
                        if (estadoUsuario.estaLogado && isDesktopOrWeb)
                          FooterItem(
                            'Painel Administrativo',
                            onTap: () => _irParaAreaAdmin(context),
                          ),
                        FooterItem('Termos de Uso'),
                      ],
                    ),
                  ],
                  endereco:
                      'Sede: Av. Príncipe de Gales, 821 – Bairro Príncipe de Gales – Santo André, SP – CEP: 09060-650 (Portaria 1)  Av. Lauro Gomes,  2000 – Vila Sacadura Cabral – Santo André / SP   – CEP: 09060-870 (Portaria 2) Telefone: (11)  4993-5400',
                  site: 'www.fmabc.br',
                  onSiteTap: _abrirSiteFMABC,
                  onInstagramTap: _abrirInstagram,
                  onFacebookTap: _abrirFacebook,
                  onLinkedInTap: _abrirLinkedIn,
                  onYouTubeTap: _abrirYouTube,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}