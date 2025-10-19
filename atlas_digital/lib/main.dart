import 'package:flutter/material.dart';
import 'temas.dart';
import 'app_shell.dart';
import 'src/componentes/painelAdm.dart';

void main() {
  runApp(const AtlasApp());
}

class AtlasApp extends StatelessWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Digital',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),

      // Ponto de entrada:
      // home: const AppShell(),  // (navbar + páginas principais)
      home: const PainelAdm(),   // (abre direto o painel)
    );
  }
}