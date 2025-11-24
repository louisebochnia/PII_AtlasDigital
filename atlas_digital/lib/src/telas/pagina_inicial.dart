import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atlas_digital/src/estado/estado_imagem.dart';
import 'package:url_launcher/url_launcher.dart';

const double kBreakpoint = 900;

class PaginaInicial extends StatefulWidget {
  final Function(int)? onNavegar;
  final VoidCallback? onInstagramTap;
  final VoidCallback? onFacebookTap;
  final VoidCallback? onLinkedInTap;
  final VoidCallback? onYouTubeTap;
  final VoidCallback? onQuiz;

  const PaginaInicial({
    super.key,
    this.onNavegar,
    this.onInstagramTap,
    this.onFacebookTap,
    this.onLinkedInTap,
    this.onYouTubeTap,
    this.onQuiz,
  });

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  late EstadoImagem _estadoImagem;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Future<void> _carregamentoFuture;

  @override
  void initState() {
    super.initState();
    _estadoImagem = context.read<EstadoImagem>();
    _carregamentoFuture = _carregarImagens();
  }

  Future<void> _carregarImagens() async {
    final estadoImagem = Provider.of<EstadoImagem>(context, listen: false);
    await estadoImagem.carregarImagens();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < kBreakpoint;

    final double horizontalPadding = isMobile ? 24 : 60;
    final double sectionGap = isMobile ? 60 : 100;

    return FutureBuilder<void>(
      future: _carregamentoFuture,
      builder: (context, snapshot) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              _buildHeroSlider(horizontalPadding, isMobile),

              _buildWelcomeBanner(horizontalPadding, isMobile),

              SizedBox(height: sectionGap),
              _buildSobreSection(horizontalPadding),

              SizedBox(height: sectionGap),
              _buildExploreSection(horizontalPadding, isMobile),

              SizedBox(height: sectionGap),
              _buildQuizSection(horizontalPadding),

              SizedBox(height: sectionGap),
              _buildSocialSection(horizontalPadding, isMobile),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET AUXILIAR ---
  Widget _secaoComMargem({
    required Widget child,
    required double horizontalPadding,
    Color? corFundo,
    DecorationImage? imagemFundo,
    double verticalPadding = 0,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      decoration: BoxDecoration(color: corFundo, image: imagemFundo),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: child,
          ),
        ),
      ),
    );
  }

  // --- 1. BANNER CARROSSEL ATUALIZADO ---
  Widget _buildHeroSlider(double padding, bool isMobile) {
    return Consumer<EstadoImagem>(
      builder: (context, estadoImagem, child) {
        final todasImagens = estadoImagem.todasAsImagens;
        final imagensCarrossel = todasImagens.take(5).toList();

        if (estadoImagem.carregando) {
          return Container(
            height: isMobile ? 250 : 400,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (imagensCarrossel.isEmpty) {
          return Container(
            height: isMobile ? 250 : 400,
            color: Colors.grey[300],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "Nenhuma imagem disponível",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          height: isMobile ? 250 : 400,
          color: Colors.black,
          child: Stack(
            children: [
              // CARROSSEL DE IMAGENS
              PageView.builder(
                controller: _pageController,
                itemCount: imagensCarrossel.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final imagem = imagensCarrossel[index];
                  final imageUrl = estadoImagem.converterParaUrl(
                    imagem.enderecoThumbnail,
                  );

                  return Container(
                    width: double.infinity,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // OVERLAY ESCURO PARA MELHOR VISIBILIDADE
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
              ),

              // TÍTULO DA IMAGEM ATUAL
              Positioned(
                left: padding,
                right: padding,
                bottom: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      imagensCarrossel[_currentPage].nomeImagem,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      imagensCarrossel[_currentPage].subtopico,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // INDICADORES DE PÁGINA
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(imagensCarrossel.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    );
                  }),
                ),
              ),

              // BOTÕES DE NAVEGAÇÃO
              if (imagensCarrossel.length > 1) ...[
                Positioned(
                  left: isMobile ? 10 : padding,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: isMobile ? 24 : 40,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
                Positioned(
                  right: isMobile ? 10 : padding,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: isMobile ? 24 : 40,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (_currentPage < imagensCarrossel.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // --- 2. BANNER BOAS-VINDAS (MANTIDO ORIGINAL) ---
  Widget _buildWelcomeBanner(double padding, bool isMobile) {
    return _secaoComMargem(
      horizontalPadding: padding,
      corFundo: const Color(0xFF388E3C),
      imagemFundo: const DecorationImage(
        image: AssetImage("assets/banner_texture.png"),
        fit: BoxFit.cover,
      ),
      verticalPadding: isMobile ? 40 : 60,
      child: Column(
        children: [
          Text(
            "Bem Vindo(a) ao PORTAL ATLAS",
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Text(
              "Bem-vindo(a) ao Portal ATLAS, o espaço criado para você estudar citologia com máxima qualidade. Nesta plataforma, oferecemos não apenas imagens de altíssima definição, mas também uma experiência completa de aprendizado.",
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 16 : 18,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. SEÇÃO SOBRE (MANTIDO ORIGINAL) ---
  Widget _buildSobreSection(double padding) {
    return _secaoComMargem(
      horizontalPadding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isNarrow = constraints.maxWidth < 900;

          Widget imagem = Container(
            constraints: const BoxConstraints(maxWidth: 500),
            height: 350,
            width: isNarrow ? double.infinity : 400,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.grey[200],
                child: Image.asset(
                  "assets/foto_equipe.png",
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );

          Widget texto = Column(
            crossAxisAlignment: isNarrow
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                "Por que o PORTAL ATLAS foi criado?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: isNarrow ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 20),
              Text(
                "Este portal foi desenvolvido para oferecer, tanto a estudantes quanto ao público em geral, um espaço onde o aprendizado é prioridade. No ATLAS, você encontrará imagens de citologia em alta qualidade, cuidadosamente selecionadas para análise e estudo.\n\nAlém das imagens e dos pontos de atenção destacados pelos professores, o portal também disponibiliza explicações detalhadas dos conteúdos.",
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.black87,
                ),
                textAlign: isNarrow ? TextAlign.center : TextAlign.start,
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              children: [imagem, const SizedBox(height: 40), texto],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                imagem,
                const SizedBox(width: 50),
                Expanded(child: texto),
              ],
            );
          }
        },
      ),
    );
  }

  // --- 4. SEÇÃO EXPLORE (CARDS COM ÍCONES ORIGINAIS) ---
  Widget _buildExploreSection(double padding, bool isMobile) {
    return _secaoComMargem(
      horizontalPadding: padding,
      child: Column(
        children: [
          Text(
            "Explore o ATLAS",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 50),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              // CARD 1: Conteúdo -> Redireciona para índice 1 (Aba Conteúdo)
              _buildCardNovo(
                Icons.biotech_rounded,
                "Conteúdo",
                "Acesse materiais didáticos completos.",
                isMobile,
                onTap: () => widget.onNavegar?.call(1),
              ),
              // CARD 2: Galeria -> Redireciona para índice 2 (Aba Galeria)
              _buildCardNovo(
                Icons.collections_rounded,
                "Galeria",
                "Explore nosso acervo de lâminas.",
                isMobile,
                onTap: () => widget.onNavegar?.call(2),
              ),
              // CARD 3: Quiz (Exemplo sem navegação interna por enquanto)
              _buildCardNovo(
                Icons.help_rounded,
                "Quiz",
                "Teste seus conhecimentos.",
                isMobile,
                onTap: widget.onQuiz,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardNovo(
    IconData icon,
    String title,
    String description,
    bool isMobile, {
    VoidCallback? onTap,
  }) {
    const double cardHeight = 380;

    return Container(
      width: isMobile ? double.infinity : 300,
      height: cardHeight,
      constraints: const BoxConstraints(maxWidth: 350),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ÍCONE ORIGINAL (SEM IMAGEM)
                Icon(icon, size: 150, color: const Color(0xFF388E3C)),
                const SizedBox(height: 25),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 5. SEÇÃO QUIZ (MANTIDO ORIGINAL) ---
  Widget _buildQuizSection(double padding) {
    return _secaoComMargem(
      horizontalPadding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isNarrow = constraints.maxWidth < 900;

          Widget imagem = Container(
            height: 350,
            constraints: const BoxConstraints(maxWidth: 400),
            alignment: isNarrow ? Alignment.center : Alignment.centerLeft,
            child: Image.asset(
              "assets/ilustracao_quiz.png",
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.red,
                  ),
                );
              },
            ),
          );

          Widget texto = Column(
            crossAxisAlignment: isNarrow
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Text(
                "CONFIRA NOSSOS Quizzes",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: isNarrow ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 20),
              Text(
                "Pratique o que você aprendeu com nossos exercícios e formulários de avaliação.",
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.6,
                  color: Colors.black87,
                ),
                textAlign: isNarrow ? TextAlign.center : TextAlign.start,
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: widget.onQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6200EE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 22,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Ver Quizzes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );

          if (isNarrow) {
            return Column(
              children: [imagem, const SizedBox(height: 30), texto],
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                imagem,
                const SizedBox(width: 60),
                Expanded(child: texto),
              ],
            );
          }
        },
      ),
    );
  }

  // --- 6. REDES SOCIAIS (MANTIDO ORIGINAL) ---
  Widget _buildSocialSection(double padding, bool isMobile) {
    return _secaoComMargem(
      horizontalPadding: padding,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF00C853),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: isMobile ? 30 : 40,
                ),
                child: Column(
                  children: [
                    Text(
                      "Acompanhe nossas redes sociais",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        children: [
                          TextSpan(
                            text:
                                "Fique por dentro de todas as atualizações da ",
                          ),
                          TextSpan(
                            text: "FMABC",
                            style: TextStyle(
                              color: Color(0xFF388E3C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 30,
                      runSpacing: 20,
                      children: [
                        _socialButton(
                          Icons.photo_camera_outlined,
                          'Instagram',
                          widget.onInstagramTap,
                        ),
                        _socialButton(
                          Icons.facebook,
                          'Facebook',
                          widget.onFacebookTap,
                        ),
                        _socialButton(
                          Icons.business_center_outlined,
                          'LinkedIn',
                          widget.onLinkedInTap,
                        ),
                        _socialButton(
                          Icons.smart_display,
                          'YouTube',
                          widget.onYouTubeTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, String tooltip, VoidCallback? onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          width: 80,
          height: 50,
          decoration: BoxDecoration(
            color: onTap != null
                ? const Color(0xFF388E3C)
                : Colors.grey.shade400,
            borderRadius: BorderRadius.circular(25),
            boxShadow: onTap != null
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
