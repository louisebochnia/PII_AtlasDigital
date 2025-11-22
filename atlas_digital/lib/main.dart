import 'package:atlas_digital/app_shell.dart';
import 'package:atlas_digital/src/telas/pagina_capitulo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'temas.dart';
import 'src/telas/painelAdm.dart';
import 'src/estado/estado_topicos.dart';
import 'src/estado/estado_subtopicos.dart';
import 'src/estado/estado_estatisticas.dart';
import 'src/estado/estado_imagem.dart';
import 'src/estado/estado_usuario.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EstadoUsuario()),
        ChangeNotifierProvider(create: (_) => EstadoTopicos()),
        ChangeNotifierProvider(create: (_) => EstadoSubtopicos()),
        ChangeNotifierProvider(create: (_) => EstadoEstatisticas()),
        ChangeNotifierProvider(create: (_) => EstadoImagem()),
      ],
      child: const AtlasApp(),
    ),
  );
}


class AtlasApp extends StatelessWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Digital',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AppShell(),
      // home: const PainelAdm(),
      // home: const telaCapitulo(),
    );
  }
}
