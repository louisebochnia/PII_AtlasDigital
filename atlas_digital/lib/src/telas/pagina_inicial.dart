// lib/src/telas/pagina_inicial.dart
import 'package:flutter/material.dart';
import '../componentes/rodape.dart';

class PaginaInicial extends StatelessWidget {
  const PaginaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),

          Rodape(
            logoAsset: 'assets/logo_fmabc.png',
            onFaq: () {
              // exemplo: abre rota do FAQ
              // Navigator.pushNamed(context, '/faq');
            },
            colunas: const [
              FooterColumnData(
                titulo: 'Coluna 1',
                itens: [
                  FooterItem('Sobre o Atlas'),
                  FooterItem('Equipe'),
                  FooterItem('Política de privacidade'),
                  FooterItem('Termos de uso'),
                ],
              ),
              FooterColumnData(
                titulo: 'Coluna 2',
                itens: [
                  FooterItem('Tutorial de uso'),
                  FooterItem('Perguntas frequentes'),
                  FooterItem('Contato'),
                  FooterItem('Acessibilidade'),
                ],
              ),
            ],
            endereco:
                'Sede: Av. Príncipe de Gales, 821 – Bairro Príncipe de Gales – Santo André, SP – CEP: 09060-650 (Portaria 1)  Av. Lauro Gomes, 2000 – Vila Sacadura Cabral – Santo André / SP – CEP: 09060-870 (Portaria 2) Telefone: (11) 4993-5400',
            site: 'www.fmabc.br',
          ),
        ],
      ),
    );
  }
}
