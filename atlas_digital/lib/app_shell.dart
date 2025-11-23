import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  final List<Widget> _pages = [
    const PaginaInicial(),
    const telaConteudo(),
    const PaginaGaleria(),
  ];

  @override
  void initState() {
    super.initState();
    _registrarVisitaApp();
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
    return CustomScrollView(
      slivers: [
        // Conteúdo principal
        SliverToBoxAdapter(child: conteudo),

        // Rodapé
        SliverToBoxAdapter(
          child: Rodape(
            logoAsset: 'assets/logo_fmabc.png',
            colunas: const [
              FooterColumnData(
                titulo: 'Coluna 1',
                itens: [
                  FooterItem('Sobre o Atlas'),
                  FooterItem('Equipe'),
                  FooterItem('Política de privacidade'),
                  FooterItem('Termos de uso'),
                ],
              ),
              FooterColumnData(
                titulo: 'Coluna 2',
                itens: [
                  FooterItem('Tutorial de uso'),
                  FooterItem('Perguntas frequentes'),
                  FooterItem('Contato'),
                  FooterItem('Acessibilidade'),
                ],
              ),
            ],
            endereco:
                'Sede: Av. Príncipe de Gales, 821 –   Bairro Príncipe de Gales – Santo André, SP –  CEP: 09060-650 (Portaria 1)  Av. Lauro Gomes,  2000 – Vila Sacadura Cabral – Santo André / SP   – CEP: 09060-870 (Portaria 2) Telefone: (11)  4993-5400',
            site: 'www.fmabc.br',
            onTermosUso: _paginaEspecial == null
                ? () {
                    _navegarParaPaginaEspecial(const PaginaTermosUso());
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
