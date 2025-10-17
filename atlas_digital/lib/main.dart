import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_shell.dart';

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
      theme: buildAppTheme(),     // <- usa âncoras de cor
      home: const AppShell(),     // <- casca com navbar e páginas
    );
  }
}