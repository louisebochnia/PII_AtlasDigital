import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/componentes/barra_de_navegacao.dart';
import 'src/telas/pagina_inicial.dart';
import 'src/telas/pagina_conteudo.dart';
import 'src/telas/pagina_galeria.dart';
import 'src/estado/estado_estatisticas.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  bool _visitaRegistrada = false; //EVITAR REGISTRAR MÚLTIPLAS VEZES---

  final _pages = const [
    PaginaInicial(),
    PaginaConteudo(),
    GalleryPage(),
  ];

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