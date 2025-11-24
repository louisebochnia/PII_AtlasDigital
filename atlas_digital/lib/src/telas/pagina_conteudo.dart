import 'package:flutter/material.dart';
import '../componentes/sub_componentes/componenteTopicoshorizontais.dart';

// O ponto de quebra deve ser definido consistentemente com a TopNavBar
const double kBreakpoint = 1000;

class PaginaConteudo extends StatefulWidget {
  const PaginaConteudo({super.key});

  @override
  State<PaginaConteudo> createState() => _PaginaConteudoState();
}

class _PaginaConteudoState extends State<PaginaConteudo> {
  // Simula buscar dados de um banco (poderia ser uma API real)
  Future<List<Map<String, dynamic>>> buscarDadosDoBanco() async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // simula o tempo da requisição

    return [
      {
        "titulo": "Lugares Recomendados",
        "descricao":
            "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
        "itens": [
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
        ],
      },
      {
        "titulo": "Comidas Populares",
        "descricao":
            "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
        "itens": [
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
          {
            "url": "https://picsum.photos/300/200?1",
            "titulo": "Montanha",
            "capitulo": "01",
          },
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // 1. LÓGICA RESPONSIVA DE MARGEM
    final double screenWidth = MediaQuery.of(context).size.width;
    // 80px para telas largas, 20px para telas estreitas
    final double horizontalPadding = screenWidth > kBreakpoint ? 80 : 20; 

    return SingleChildScrollView(
      // 2. APLICAÇÃO DA MARGEM RESPONSIVA
      child: Padding(
        // Substituí o Container e o margin por Padding
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conteúdo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),

            // FutureBuilder que carrega as seções
            FutureBuilder<List<Map<String, dynamic>>>(
              future: buscarDadosDoBanco(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 50),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Erro ao carregar dados: ${snapshot.error}"),
                  );
                }

                final secoes = snapshot.data ?? [];

                return Column(
                  children: secoes.map((secao) {
                    return SecaoHorizontal(
                      titulo: secao["titulo"],
                      descricao: secao["descricao"],
                      itens: List<Map<String, String>>.from(secao["itens"]),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}