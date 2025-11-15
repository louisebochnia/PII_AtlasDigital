import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../componentes/rodape.dart';
import '../estado/estado_estatisticas.dart';

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Rodape(
          //   logoAsset: 'assets/logo_fmabc.png',
          //   onFaq: () {},
          //   colunas: const [
          //     FooterColumnData(
          //       titulo: 'Coluna 1',
          //       itens: [
          //         FooterItem('Sobre o Atlas'),
          //         FooterItem('Equipe'),
          //         FooterItem('Política de privacidade'),
          //         FooterItem('Termos de uso'),
          //       ],
          //     ),
          //     FooterColumnData(
          //       titulo: 'Coluna 2',
          //       itens: [
          //         FooterItem('Tutorial de uso'),
          //         FooterItem('Perguntas frequentes'),
          //         FooterItem('Contato'),
          //         FooterItem('Acessibilidade'),
          //       ],
          //     ),
          //   ],
          //   endereco: 'Sede: Av. Príncipe de Gales, 821 – Bairro Príncipe de Gales – Santo André, SP – CEP: 09060-650 (Portaria 1)  Av. Lauro Gomes, 2000 – Vila Sacadura Cabral – Santo André / SP – CEP: 09060-870 (Portaria 2) Telefone: (11) 4993-5400',
          //   site: 'www.fmabc.br',
          // ),
        ],
      ),
    );
  }
}