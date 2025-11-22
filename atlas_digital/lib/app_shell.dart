import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// IMPORTS DOS SEUS COMPONENTES
import 'src/componentes/barra_de_navegacao.dart';
import 'src/componentes/rodape.dart';
import 'src/componentes/sub_componentes/popup_login.dart';

// IMPORTS DAS TELAS
import 'src/telas/pagina_inicial.dart';
import 'src/telas/pagina_conteudo.dart';
import 'src/telas/pagina_galeria.dart';

// ESTADOS
import 'src/estado/estado_estatisticas.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _visitaRegistrada = false;

  final _pages = const [PaginaInicial(), telaConteudo(), PaginaGaleria()];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AQUI ESTÁ A CONEXÃO ---
      appBar: TopNavBar(
        selectedIndex: _index,
        onItemTap: (i) => setState(() => _index = i),
        onAtlas: () {
          debugPrint('Acessar ATLAS');
        },
        // QUANDO CLICAR NO BOTÃO LOGIN DA NAVBAR:
        onLogin: () {
          showDialog(
            context: context,
            barrierDismissible: true, // Permite fechar clicando fora
            builder: (BuildContext context) {
              // Chama o seu componente de Popup
              return const LoginPopup(); 
            },
          );
        },
      ),
      body: CustomScrollView(
        slivers: [
          // Conteúdo principal da página atual
          SliverToBoxAdapter(
            child: IndexedStack(index: _index, children: _pages),
          ),

          // Rodapé
          SliverToBoxAdapter(
            child: Rodape(
              logoAsset: 'assets/logo_fmabc.png',
              onFaq: () {
                debugPrint('FAQ clicado');
              },
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
                  'Sede: Av. Príncipe de Gales, 821 – Bairro Príncipe de Gales – Santo André, SP – CEP: 09060-650 (Portaria 1)  Av. Lauro Gomes, 2000 – Vila Sacadura Cabral – Santo André / SP – CEP: 09060-870 (Portaria 2) Telefone: (11) 4993-5400',
              site: 'www.fmabc.br',
            ),
          ),
        ],
      ),
    );
  }
}