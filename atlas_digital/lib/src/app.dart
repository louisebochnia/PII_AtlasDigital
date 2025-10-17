import 'package:atlas_digital/src/telas/imagem.dart';
import 'package:flutter/material.dart';
import 'package:atlas_digital/src/telas/imagem.dart';

class App extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Imagem',
      home: Scaffold(
        body: Imagem()
      )
    );
  }
}