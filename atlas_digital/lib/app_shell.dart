import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'src/estado/estado_navegacao.dart';
import 'src/componentes/barra_de_navegacao.dart';
import 'src/componentes/rodape.dart';
import 'src/componentes/sub_componentes/popup_login.dart';
import 'src/telas/pagina_inicial.dart';
import 'src/telas/pagina_conteudo.dart';
import 'src/telas/pagina_galeria.dart';
import 'src/estado/estado_estatisticas.dart';
import 'src/estado/estado_usuario.dart';
import 'src/telas/painelAdm.dart';
import 'src/telas/pagina_termosUso.dart';

//button de login aparece só em desktop/web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

bool get isDesktopOrWeb {
  if (kIsWeb) return true;
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _visitaRegistrada = false;
  Widget? _paginaEspecial;

  // URLs das redes sociais
  String? _urlInstagram;
  String? _urlFacebook;
  String? _urlLinkedIn;
  String? _urlYouTube;

  final List<Widget> _pages = [
    const PaginaInicial(),
    const PaginaConteudo(),
    const PaginaGaleria(),
  ];

  @override
  void initState() {
    super.initState();
    _registrarVisitaApp();
    _carregarRedesSociais();
  }

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

  void _registrarVisitaApp() {
    if (!_visitaRegistrada) {
      Future.microtask(() {
        final estadoEstatisticas = Provider.of<EstadoEstatisticas>(
          context,
          listen: false,
        );
        estadoEstatisticas.registrarVisita(
          userId: 'visitante_app',
          pagina: 'app_shell',
        );
        _visitaRegistrada = true;
        print('Visita ao AppShell registrada');
      });
    }
  }

  void _navegarParaPaginaEspecial(Widget pagina) {
    setState(() {
      _paginaEspecial = pagina;
    });
  }

  void _voltarParaNavegacaoNormal() {
    setState(() {
      _paginaEspecial = null;
    });
  }

  void _irParaAreaAdmin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PainelAdm()),
    );
  }

  // Função para abrir site FMABC
  void _abrirSiteFMABC() async {
    const url = 'https://www.fmabc.br';
    await _launchUrl(url);
  }

  // Função para abrir quizzes
  void _abrirQuizzes() async {
    const url =
        'https://kahoot.it/challenge/01222478?challenge-id=0d7865cd-feea-4485-8785-64eda4afebed_1762430282515';
    await _launchUrl(url);
  }

  // Funções para redes sociais
  void _abrirInstagram() async {
    final url = _urlInstagram ?? 'https://www.instagram.com/centrouniversitariofmabc/';
    await _launchUrl(url);
  }

  void _abrirFacebook() async {
    final url = _urlFacebook ?? 'https://www.facebook.com/CentroUniversitarioFMABC/';
    await _launchUrl(url);
  }

  void _abrirLinkedIn() async {
    final url = _urlLinkedIn ?? 'https://br.linkedin.com/school/fmabc/';
    await _launchUrl(url);
  }

  void _abrirYouTube() async {
    final url = _urlYouTube ?? 'https://www.youtube.com/channel/UCJ_wO9afToh1XyMoUcGY8qw';
    await _launchUrl(url);
  }

  // Função genérica para lançar URLs
  Future<void> _launchUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);

      // Verifica se pode lançar a URL
      if (!await canLaunchUrl(uri)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível abrir: $urlString')),
        );
        return;
      }

      // Tenta abrir no modo external application
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // Se não conseguiu abrir externamente, tenta de outras formas
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir link: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Consumer<EstadoUsuario>(
          builder: (context, estadoUsuario, child) {
            return TopNavBar(
              selectedIndex: _paginaEspecial == null ? _index : 0,
              onItemTap: _paginaEspecial == null
                  ? (i) => setState(() => _index = i)
                  : (i) => _voltarParaNavegacaoNormal(),
              onAtlas: () {
                debugPrint('Acessar ATLAS');
              },
              onLogin: estadoUsuario.estaLogado
                  ? () => _irParaAreaAdmin(context)
                  : () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return const LoginPopup();
                        },
                      );
                    },
            );
          },
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Se temos uma página especial, mostra ela
    if (_paginaEspecial != null) {
      return _buildCustomScrollView(_paginaEspecial!);
    }

    // Senão, mostra a página normal baseada no índice
    return _buildCustomScrollView(_pages[_index]);
  }

  Widget _buildCustomScrollView(Widget conteudo) {
    return Consumer<EstadoUsuario>(
      builder: (context, estadoUsuario, child) {
        return CustomScrollView(
          slivers: [
            // Conteúdo principal
            SliverToBoxAdapter(child: conteudo),

            // Rodapé
            SliverToBoxAdapter(
              child: Rodape(
                logoAsset: 'assets/logo_fmabc.png',
                colunas: [
                  FooterColumnData(
                    titulo: 'Coluna 1',
                    itens: [
                      FooterItem(
                        'Sobre o Atlas',
                        onTap: () =>
                            _navegarParaPaginaEspecial(const PaginaInicial()),
                      ),
                      FooterItem(
                        'Conteúdo',
                        onTap: () =>
                            _navegarParaPaginaEspecial(const PaginaConteudo()),
                      ),
                      FooterItem(
                        'Galeria',
                        onTap: () =>
                            _navegarParaPaginaEspecial(const PaginaGaleria()),
                      ),
                    ],
                  ),
                  FooterColumnData(
                    titulo: 'Coluna 2',
                    itens: [
                      FooterItem('Quizzes', onTap: _abrirQuizzes),
                      if (estadoUsuario.estaLogado && isDesktopOrWeb)
                        FooterItem(
                          'Painel Administrativo',
                          onTap: () => _irParaAreaAdmin(context),
                        ),
                      FooterItem(
                        'Termos de Uso',
                        onTap: () =>
                            _navegarParaPaginaEspecial(const PaginaTermosUso()),
                      ),
                    ],
                  ),
                ],
                endereco:
                    'Sede: Av. Príncipe de Gales, 821 –   Bairro Príncipe de Gales – Santo André, SP –  CEP: 09060-650 (Portaria 1)  Av. Lauro Gomes,  2000 – Vila Sacadura Cabral – Santo André / SP   – CEP: 09060-870 (Portaria 2) Telefone: (11)  4993-5400',
                site: 'www.fmabc.br',
                onSiteTap: _abrirSiteFMABC,
                onInstagramTap: _abrirInstagram,
                onFacebookTap: _abrirFacebook,
                onLinkedInTap: _abrirLinkedIn,
                onYouTubeTap: _abrirYouTube,
                onTermosUso: _paginaEspecial == null
                    ? (context) {
                        _navegarParaPaginaEspecial(const PaginaTermosUso());
                      }
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}
