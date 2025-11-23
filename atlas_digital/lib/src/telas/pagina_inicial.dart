import 'package:flutter/material.dart';

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  
  @override
  Widget build(BuildContext context) {
    // Removido o SelectionArea conforme pedido (padrão mobile: não seleciona texto)
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          _buildHeroSlider(),
          const SizedBox(height: 60),
          _buildWelcomeBanner(),
          const SizedBox(height: 60),
          _buildSobreSection(),
          const SizedBox(height: 60),
          _buildExploreSection(),
          const SizedBox(height: 60),
          _buildQuizSection(),
          const SizedBox(height: 80),
          _buildSocialSection(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // --- WIDGET AUXILIAR: SEÇÃO COM MARGEM DE 80PX ---
  // Garante fundo infinito, mas conteúdo com margem exata de 80px nas laterais
  Widget _secaoComMargem({required Widget child, Color? corFundo, DecorationImage? imagemFundo, double verticalPadding = 0}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      decoration: BoxDecoration(
        color: corFundo,
        image: imagemFundo,
      ),
      child: Padding(
        // AQUI ESTÁ A REGRA DE OURO: 80PX DE MARGEM LATERAL
        padding: const EdgeInsets.symmetric(horizontal: 160),
        child: child,
      ),
    );
  }

  // --- 1. BANNER CARROSSEL ---
  Widget _buildHeroSlider() {
    return Container(
      height: 400,
      color: Colors.grey[300],
      child: Stack(
        children: [
          const Center(child: Text("Banner Rotativo", style: TextStyle(color: Colors.grey, fontSize: 20))),
          // As setas agora ficam a 80px da borda para alinhar com o resto
          Positioned(
            left: 80, top: 0, bottom: 0,
            child: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 40, color: Colors.black54), onPressed: () {}),
          ),
          Positioned(
            right: 80, top: 0, bottom: 0,
            child: IconButton(icon: const Icon(Icons.arrow_forward_ios, size: 40, color: Colors.black54), onPressed: () {}),
          ),
        ],
      ),
    );
  }

  // --- 2. BANNER BOAS-VINDAS ---
  Widget _buildWelcomeBanner() {
    return _secaoComMargem(
      corFundo: const Color(0xFF388E3C),
      imagemFundo: const DecorationImage(
        image: AssetImage("assets/banner_texture.png"),
        fit: BoxFit.cover,
      ),
      verticalPadding: 60,
      child: Column(
        children: [
          const Text(
            "Bem Vindo(a) ao PORTAL ATLAS",
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold), // Aumentei a fonte
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000), // Texto pode ocupar mais espaço agora
            child: const Text(
              "Bem-vindo(a) ao Portal ATLAS, o espaço criado para você estudar citologia com máxima qualidade. Nesta plataforma, oferecemos não apenas imagens de altíssima definição, mas também uma experiência completa de aprendizado, unindo conteúdo visual, usabilidade intuitiva e recursos que tornam seus estudos mais eficientes.",
              style: TextStyle(color: Colors.white, fontSize: 18, height: 1.5), // Aumentei a fonte e altura
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. SEÇÃO SOBRE ---
  Widget _buildSobreSection() {
    return _secaoComMargem(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagem (Lado Esquerdo)
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 350, // Um pouco maior
                color: Colors.grey[200],
                child: Image.asset(
                  "assets/foto_equipe.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 60), // Espaço maior entre imagem e texto
          // Texto (Lado Direito)
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Por que o PORTAL ATLAS foi criado?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text(
                  "Este portal foi desenvolvido para oferecer, tanto a estudantes quanto ao público em geral, um espaço onde o aprendizado é prioridade. No ATLAS, você encontrará imagens de citologia em alta qualidade, cuidadosamente selecionadas para análise e estudo.\n\nAlém das imagens e dos pontos de atenção destacados pelos professores, o portal também disponibiliza explicações detalhadas dos conteúdos.",
                  style: TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. SEÇÃO EXPLORE (CARDS) ---
  Widget _buildExploreSection() {
    return _secaoComMargem(
      child: Column(
        children: [
          const Text("Explore o ATLAS", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          // Layout Builder para ajustar o tamanho dos cards proporcionalmente
          LayoutBuilder(
            builder: (context, constraints) {
              // Calcula largura para caber 4 cards com espaçamento, ou quebra linha
              // Aqui deixamos flexível
              return Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _buildCardNovo(Icons.biotech_rounded, "Conteúdo", "Acesse materiais didáticos completos sobre citologia e análises clínicas."),
                  _buildCardNovo(Icons.collections_rounded, "Galeria", "Explore nosso acervo de lâminas em alta definição organizadas por categorias."),
                  _buildCardNovo(Icons.help_rounded, "Quiz", "Teste seus conhecimentos com questões interativas e formulários de avaliação."),
                ],
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildCardNovo(IconData icon, String title, String description) {
    return Container(
      width: 300, // Largura fixa agradável
      height: 340, // Altura aumentada para caber o texto novo
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8)
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 70, color: const Color(0xFF388E3C)),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)
          ),
          const SizedBox(height: 15),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.4),
          )
        ],
      ),
    );
  }

  // --- 5. SEÇÃO QUIZ ---
  Widget _buildQuizSection() {
    return _secaoComMargem(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Imagem Ilustração
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 350,
              child: Image.asset(
                "assets/ilustracao_quiz.png",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.red));
                },
              ),
            ),
          ),
          const SizedBox(width: 60),
          // Texto e Botões
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("CONFIRA NOSSOS Quizzes", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text(
                  "Este portal foi desenvolvido para oferecer, tanto a estudantes quanto ao público em geral, um espaço onde o aprendizado é prioridade. Pratique o que você aprendeu com nossos exercícios.",
                  style: TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                ),
                const SizedBox(height: 40),
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6200EE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Ver Quizzes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF388E3C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("FORMULÁRIOS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. REDES SOCIAIS ---
  Widget _buildSocialSection() {
    return _secaoComMargem(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
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
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Column(
                children: [
                  const Text(
                    "Acompanhe nossas redes sociais",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 15),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      children: [
                        TextSpan(text: "Fique por dentro de todas as atualizações da "),
                        TextSpan(text: "FMABC", style: TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 30,
                    runSpacing: 20,
                    children: [
                      _socialButton(Icons.camera_alt),
                      _socialButton(Icons.close),
                      _socialButton(Icons.play_arrow),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon) {
    return Container(
      width: 80, height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(25)
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}