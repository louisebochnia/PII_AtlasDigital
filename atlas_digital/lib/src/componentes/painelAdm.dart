import 'package:flutter/material.dart';

class PainelAdm extends StatefulWidget {
  const PainelAdm({super.key}); // ✅ construtor com key

  @override
  State<PainelAdm> createState() => _PainelAdmState(); // ✅ método obrigatório
}

class _PainelAdmState extends State<PainelAdm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
      ),
      body: const Center(
        child: Text('Bem-vindo ao Painel do Administrador!'),
      ),
    );
  }
}
