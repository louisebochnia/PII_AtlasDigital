import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  String? _urlKahoot;

  // Flag para controlar se os dados foram carregados
  bool _dadosCarregados = false;
  bool _tentativaCarregamento = false;

  @override
  void initState() {
    super.initState();
    _registrarVisitaApp();
    _carregarRedesSociais();
  }

  Future<void> _carregarRedesSociais() async {
    // Evita múltiplas tentativas
    if (_tentativaCarregamento) return;
    _tentativaCarregamento = true;

    try {
      String baseUrl;

      if (kIsWeb) {
        baseUrl = 'http://localhost:3000';
        print('Plataforma: Web - usando $baseUrl');
      } else {
        print('Plataforma: Mobile - detectando host...');

        // MODIFICADO: Use APENAS o IP do seu computador
        final hosts = [
          'http://192.168.15.163:3000', // IP do seu computador - ALTERE SE PRECISAR
        ];

        String? foundHost;

        for (final host in hosts) {
          try {
            print('Testando conexão com: $host/hyperlink');
            final testUri = Uri.parse('$host/hyperlink');
            final testResp = await http
                .get(testUri)
                .timeout(const Duration(seconds: 10)); // Aumentei o timeout

            if (testResp.statusCode == 200) {
              foundHost = host;
              print('Conexão bem-sucedida com: $host');
              break;
            } else {
              print('HTTP ${testResp.statusCode} com: $host');
            }
          } catch (e) {
            print('Falha ao conectar com $host: $e');
            continue;
          }
        }

        // Se não encontrou nenhum host, TENTA NOVAMENTE em vez de usar padrão
        if (foundHost == null) {
          print(
            'Nenhum host funcionou, mas VOU TENTAR NOVAMENTE com o IP principal',
          );
          // Não chama _usarUrlsPadrao() - força a tentar carregar do banco
          baseUrl = 'http://192.168.15.163:3000'; // Tenta mesmo assim
        } else {
          baseUrl = foundHost;
        }
      }

      print('Tentando carregar dados de: $baseUrl/hyperlink');

      final uri = Uri.parse('$baseUrl/hyperlink');
      final resp = await http.get(uri).timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        print('Dados recebidos do servidor: ${data.length} itens');

        for (final item in data) {
          final nome = (item['nome'] as String?)?.toLowerCase();
          final link = item['link'] as String?;
          print('$nome: $link');

          if (nome == 'instagram') _urlInstagram = link;
          if (nome == 'facebook') _urlFacebook = link;
          if (nome == 'linkedin') _urlLinkedIn = link;
          if (nome == 'youtube') _urlYouTube = link;
          if (nome == 'kahoot') _urlKahoot = link;
        }

        setState(() {
          _dadosCarregados = true;
        });
        print('Links carregados com sucesso do banco de dados');

        // Debug: mostra os URLs carregados
        print('Instagram: $_urlInstagram');
        print('Facebook: $_urlFacebook');
        print('LinkedIn: $_urlLinkedIn');
        print('YouTube: $_urlYouTube');
        print('Kahoot: $_urlKahoot');
      } else {
        print('Erro HTTP ${resp.statusCode} ao carregar links');
        // NÃO usa URLs padrão - mantém null para forçar nova tentativa
        print('URLs do banco NÃO carregados, mas não usando padrão');
      }
    } catch (e) {
      print('Erro geral ao carregar redes sociais: $e');
      // NÃO usa URLs padrão - mantém null para forçar nova tentativa
      print('Erro, mas não usando URLs padrão');
    }
  }

  // MODIFICADO: Esta função NÃO é mais chamada automaticamente
  void _usarUrlsPadrao() {
    print('Usando URLs padrão...');
    setState(() {
      _urlInstagram = 'https://www.instagram.com/centrouniversitariofmabc/';
      _urlFacebook = 'https://www.facebook.com/CentroUniversitarioFMABC/';
      _urlLinkedIn = 'https://br.linkedin.com/school/fmabc/';
      _urlYouTube = 'https://www.youtube.com/channel/UCJ_wO9afToh1XyMoUcGY8qw';
      _urlKahoot =
          'https://kahoot.it/challenge/01222478?challenge-id=0d7865cd-feea-4485-8785-64eda4afebed_1762430282515';
      _dadosCarregados = true;
    });
  }

  // NOVA FUNÇÃO: Forçar recarregamento dos dados
  void _recarregarDados() {
    setState(() {
      _tentativaCarregamento = false;
      _dadosCarregados = false;
    });
    _carregarRedesSociais();
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

  void _navegarParaPagina(int index) {
    setState(() {
      _index = index;
      _paginaEspecial = null;
    });
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

  // MODIFICADO: SEMPRE tenta usar o URL do banco, só usa padrão se NULL
  void _abrirQuizzes() async {
    print('Clicou em Quizzes');
    print('Dados carregados: $_dadosCarregados');
    print('URL Kahoot do banco: $_urlKahoot');

    // Se não tem URL do banco, tenta recarregar
    if (_urlKahoot == null && !_dadosCarregados) {
      print('Tentando recarregar dados...');
      _recarregarDados();

      // Pequeno delay para recarregamento
      await Future.delayed(const Duration(seconds: 2));
    }

    final url = _urlKahoot; // SEMPRE usa o do banco, pode ser null

    if (url != null && url.isNotEmpty) {
      print('Abrindo URL do banco: $url');
      await _launchUrl(url);
    } else {
      print('URL do banco não disponível, NÃO abrindo link');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link não disponível no momento'),
          action: SnackBarAction(
            label: 'Recarregar',
            onPressed: _recarregarDados,
          ),
        ),
      );
    }
  }

  // MODIFICADO: Todas as funções SEMPRE usam URLs do banco
  void _abrirInstagram() async {
    print('Clicou em Instagram');
    print('URL Instagram do banco: $_urlInstagram');

    if (_urlInstagram == null && !_dadosCarregados) {
      _recarregarDados();
      await Future.delayed(const Duration(seconds: 2));
    }

    final url = _urlInstagram;

    if (url != null && url.isNotEmpty) {
      await _launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link do Instagram não disponível'),
          action: SnackBarAction(
            label: 'Recarregar',
            onPressed: _recarregarDados,
          ),
        ),
      );
    }
  }

  void _abrirFacebook() async {
    print('Clicou em Facebook');
    print('URL Facebook do banco: $_urlFacebook');

    if (_urlFacebook == null && !_dadosCarregados) {
      _recarregarDados();
      await Future.delayed(const Duration(seconds: 2));
    }

    final url = _urlFacebook;

    if (url != null && url.isNotEmpty) {
      await _launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link do Facebook não disponível'),
          action: SnackBarAction(
            label: 'Recarregar',
            onPressed: _recarregarDados,
          ),
        ),
      );
    }
  }

  void _abrirLinkedIn() async {
    print('Clicou em LinkedIn');
    print('URL LinkedIn do banco: $_urlLinkedIn');

    if (_urlLinkedIn == null && !_dadosCarregados) {
      _recarregarDados();
      await Future.delayed(const Duration(seconds: 2));
    }

    final url = _urlLinkedIn;

    if (url != null && url.isNotEmpty) {
      await _launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link do LinkedIn não disponível'),
          action: SnackBarAction(
            label: 'Recarregar',
            onPressed: _recarregarDados,
          ),
        ),
      );
    }
  }

  void _abrirYouTube() async {
    print('Clicou em YouTube');
    print('URL YouTube do banco: $_urlYouTube');

    if (_urlYouTube == null && !_dadosCarregados) {
      _recarregarDados();
      await Future.delayed(const Duration(seconds: 2));
    }

    final url = _urlYouTube;

    if (url != null && url.isNotEmpty) {
      await _launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link do YouTube não disponível'),
          action: SnackBarAction(
            label: 'Recarregar',
            onPressed: _recarregarDados,
          ),
        ),
      );
    }
  }

  // Função genérica para lançar URLs
  Future<void> _launchUrl(String urlString) async {
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

  List<Widget> _buildPages() {
    return [
      PaginaInicial(
        onNavegar: (index) => _navegarParaPagina(index),
        onInstagramTap: _abrirInstagram,
        onFacebookTap: _abrirFacebook,
        onLinkedInTap: _abrirLinkedIn,
        onYouTubeTap: _abrirYouTube,
        onQuiz: _abrirQuizzes,
      ),
      const PaginaConteudo(),
      const PaginaGaleria(),
    ];
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
    final pages = _buildPages();

    if (_paginaEspecial != null) {
      return _buildCustomScrollView(_paginaEspecial!);
    }

    return _buildCustomScrollView(pages[_index]);
  }

  Widget _buildCustomScrollView(Widget conteudo) {
    return Consumer<EstadoUsuario>(
      builder: (context, estadoUsuario, child) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: conteudo),
            SliverToBoxAdapter(
              child: Rodape(
                logoAsset: 'assets/logo_fmabc.png',
                colunas: [
                  FooterColumnData(
                    titulo: 'Coluna 1',
                    itens: [
                      FooterItem(
                        'Sobre o Atlas',
                        onTap: () => _navegarParaPagina(0),
                      ),
                      FooterItem(
                        'Conteúdo',
                        onTap: () => _navegarParaPagina(1),
                      ),
                      FooterItem('Galeria', onTap: () => _navegarParaPagina(2)),
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
                onQuiz: _abrirQuizzes,
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