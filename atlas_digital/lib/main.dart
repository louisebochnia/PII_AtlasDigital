import 'package:atlas_digital/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'temas.dart';
import 'src/telas/painelAdm.dart';
import 'src/estado/estado_topicos.dart';
import 'src/estado/estado_subtopicos.dart';
import 'src/estado/estado_estatisticas.dart';
import 'src/estado/estado_imagem.dart';
import 'src/estado/estado_usuario.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  final estadoUsuario = EstadoUsuario();
  await estadoUsuario.carregarDadosSalvos();

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
      home: Consumer<EstadoUsuario>(
        builder: (context, estadoUsuario, child) {
          // Se estiver logado, vai direto para o PainelAdm
          if (estadoUsuario.estaLogado) {
            return const PainelAdm();
          }
          // Se não estiver logado, vai para o AppShell (site normal)
          return const AppShell();
        },
      ),
    );
  }
}