import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/componentes/barra_de_navegacao.dart';
import 'src/telas/pagina_inicial.dart';
import 'src/componentes/telaConteudo.dart';
import 'src/telas/pagina_galeria.dart';
import 'src/estado/estado_estatisticas.dart';
import 'src/componentes/sub_componentes/popup_login.dart';
import 'src/componentes/rodape.dart';
import 'src/telas/pagina_termosUso.dart';

//button de login aparece só em desktop/web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';

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
  bool _visitaRegistrada = false; //EVITAR REGISTRAR MÚLTIPLAS VEZES---
  Widget?
  _paginaEspecial; // Para controlar páginas como Termos de Uso e de Direito de Imagem

  final _pages = const [PaginaInicial(), telaConteudo(), GalleryPage()];

  @override
  void initState() {
    super.initState();
    _registrarVisitaApp();
  }

  void _registrarVisitaApp() {
    if (!_visitaRegistrada) {
      // USA Future.microtask PARA EVITAR ERROS DE CONTEXTO-------------
      Future.microtask(() {
        final estadoEstatisticas = Provider.of<EstadoEstatisticas>(
          context,
          listen: false,
        );
        estadoEstatisticas.registrarVisita(
          userId: 'visitante_app', // SISTEMA DE USUÁRIO ---------------
          pagina: 'app_shell',
        );
        _visitaRegistrada = true;
        print('Visita ao AppShell registrada');
      });
    }
  }

  // Função para navegar para páginas especiais (como Termos de Uso)
  void _navegarParaPaginaEspecial(Widget pagina) {
    setState(() {
      _paginaEspecial = pagina;
    });
  }

  // Função para voltar para a navegação normal
  void _voltarParaNavegacaoNormal() {
    setState(() {
      _paginaEspecial = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(
        selectedIndex: _paginaEspecial == null ? _index : 0,
        onItemTap: _paginaEspecial == null
            ? (i) => setState(() => _index = i)
            : (i) =>
                  _voltarParaNavegacaoNormal(), // Volta ao clicar em qualquer item
        onAtlas: () {
          debugPrint('Acessar ATLAS');
        },
        onLogin: () {
          debugPrint('LOGIN');
        },
      ),
      body: CustomScrollView(
        slivers: [
          // Conteúdo principal - mostra página especial ou páginas normais
          SliverFillRemaining(
            hasScrollBody: false,
            child:
                _paginaEspecial ??
                IndexedStack(index: _index, children: _pages),
          ),

          // Rodapé - SEMPRE visível, mesmo na página especial
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
                  ? (context) {
                      _navegarParaPaginaEspecial(const PaginaTermosUso());
                    }
                  : null, // Desativa o clique se já estiver na página especial
            ),
          ),
        ],
      ),
    );
  }
}