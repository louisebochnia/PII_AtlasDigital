import 'package:flutter/material.dart';
import 'top_nav_bar.dart';
import 'home_page.dart';
import 'content_page.dart';
import 'gallery_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    ContentPage(),
    GalleryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavBar(
        selectedIndex: _index,
        onItemTap: (i) => setState(() => _index = i),
        onAtlas: () {
          // TODO: navegação real (rota/página do ATLAS)
          debugPrint('Acessar ATLAS');
        },
        onLogin: () {
          // TODO: abrir login/modal/rota
          debugPrint('LOGIN');
        },
      ),
      body: IndexedStack(index: _index, children: _pages),
    );
  }
}
