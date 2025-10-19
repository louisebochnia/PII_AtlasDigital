import 'package:flutter/material.dart';
import 'src/componentes/barra_de_navegacao.dart';
import 'src/telas/pagina_inicial.dart';
import 'src/telas/pagina_conteudo.dart';
import 'src/telas/pagina_galeria.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    PaginaInicial(),
    PaginaConteudo(),
    GalleryPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(
        selectedIndex: _index,
        onItemTap: (i) => setState(() => _index = i),
        onAtlas: () {
          debugPrint('Acessar ATLAS');
        },
        onLogin: () {
          debugPrint('LOGIN');
        },
      ),
      body: IndexedStack(index: _index, children: _pages),
    );
  }
}
