import 'package:atlas_digital/src/componentes/painelAdm.dart';
import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_shell.dart';

void main(){
  //para passar de tela em tela
  var app = const MaterialApp(
    home: PainelAdm()
  ); 
  runApp(app);
}

class AtlasApp extends StatelessWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas Digital',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),     // <- usa âncoras de cor
      home: const AppShell(),     // <- casca com navbar e páginas
    );
  }
}