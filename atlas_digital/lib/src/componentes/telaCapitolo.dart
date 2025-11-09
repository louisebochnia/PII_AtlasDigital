import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:atlas_digital/temas.dart';

class telaCapitulo extends StatefulWidget {
  const telaCapitulo({super.key});

  @override
  State<telaCapitulo> createState() => _telaCapituloState();
}

class _telaCapituloState extends State<telaCapitulo> {
  List<Map<String, dynamic>> Conteudocap = [
    {
      "titulo": "Nome do topico selecionado",
      "items": [
        {
          "tumbnailurl": "https://picsum.photos/300/200?1",
          "titucap": "Celula Eucarionte",
          "descricao":
              "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
          "LinkK": "https://www.nyan.cat/",
        },
        {
          "tumbnailurl": "https://picsum.photos/300/200?1",
          "titucap": "seila2",
          "descricao":
              "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
          "LinkK": "https://www.nyan.cat/",
        },
        {
          "tumbnailurl": "https://picsum.photos/300/200?1",
          "titucap": "seila2",
          "descricao":
              "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
          "LinkK": "https://www.nyan.cat/",
        },
        {
          "tumbnailurl": "https://picsum.photos/300/200?1",
          "titucap": "seila2",
          "descricao":
              "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
          "LinkK": "https://www.nyan.cat/",
        },
        {
          "tumbnailurl": "https://picsum.photos/300/200?1",
          "titucap": "seila2",
          "descricao":
              "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
          "LinkK": "https://www.nyan.cat/",
        },
        {
          "tumbnailurl": "https://picsum.photos/300/200?1",
          "titucap": "seila2",
          "descricao":
              "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
          "LinkK": "https://www.nyan.cat/",
        },
        {
          "tumbnailurl": "https://picsum.photos/300/200?1",
          "titucap": "seila2",
          "descricao":
              "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
          "LinkK": "https://www.nyan.cat/",
        },
        {
          "tumbnailurl": "https://picsum.photos/300/200?1",
          "titucap": "seila2",
          "descricao":
              "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
          "LinkK": "https://www.nyan.cat/",
        },
        {
          "tumbnailurl": "https://picsum.photos/300/200?1",
          "titucap": "seila2",
          "descricao":
              "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
          "LinkK": "https://www.nyan.cat/",
        },
      ],
    },
  ];

  // Controle de expansão das descrições
  List<bool> expandido = [];

  List<bool> isHoveredQuizzes = [];
  List<bool> isHoveredAtlas = [];

  @override
  void initState() {
    super.initState();
    expandido = List.filled(Conteudocap[0]['items'].length, false);
    isHoveredQuizzes = List.filled(Conteudocap[0]['items'].length, false);
    isHoveredAtlas = List.filled(Conteudocap[0]['items'].length, false);
  }

  Future<void> abrirLink(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Não foi possível abrir o link $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> capitulo = Conteudocap[0];
    final List items = capitulo['items'];

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Botão de voltar
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back, color: Colors.red, size: 16),
                label: const Text(
                  'Voltar',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Título do capítulo
            Text(
              capitulo['titulo'],
              style: const TextStyle(
                fontSize: 40,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            // Lista de itens (com altura definida via Expanded)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 6,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                item['tumbnailurl'],
                                width: double.infinity,
                                height: 400,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['titucap'],
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 100),
                                Text(
                                  'Conteúdos Relacionados',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Botão VER QUIZZES com animação
                                TextButton(
                                  onPressed: () => abrirLink(item['LinkK']),
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      44,
                                    ),
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      100,
                                      55,
                                      255,
                                    ),
                                    foregroundColor: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16, // ← Fonte um pouco menor
                                      fontWeight:
                                          FontWeight.w500, // ← Peso médio
                                      height: 1.2, // ← Altura da linha
                                      letterSpacing: 1, // ← Espaçamento mínimo
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [Text('VER QUIZZES')],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Botão ABRIR ATLAS com animação
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      44,
                                    ),
                                    backgroundColor: AppColors.brandGreen,
                                    foregroundColor: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16, // ← Fonte um pouco menor
                                      fontWeight:
                                          FontWeight.w500, // ← Peso médio
                                      height: 1.2, // ← Altura da linha
                                      letterSpacing: 1, // ← Espaçamento mínimo
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [Text('ABRIR ATLAS')],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['descricao'],
                        maxLines: expandido[index] ? null : 6,
                        overflow: expandido[index]
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16),
                      ),

                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              expandido[index] = !expandido[index];
                            });
                          },
                          
                          child: Text(
                            expandido[index] ? "Ler menos" : "Ler mais",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 45, 210, 255),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
