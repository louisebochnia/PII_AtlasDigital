import 'package:atlas_digital/src/modelos/imagem.dart';
import 'package:atlas_digital/src/telas/pagina_imagem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_imagem.dart';

class PaginaGaleria extends StatefulWidget {
  const PaginaGaleria({super.key});

  @override
  State<PaginaGaleria> createState() => _PaginaGaleriaState();
}

class _PaginaGaleriaState extends State<PaginaGaleria> {
  final String protocolo = 'http://';
  final String baseURL = 'localhost:3000';

  String filtroLetra = 'TODAS';
  final TextEditingController _searchController = TextEditingController();

  static const double kBreakpoint = 1000;

  @override
  void initState() {
    super.initState();
    carregarImagens();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth > kBreakpoint ? 80 : 20;

    return Consumer<EstadoImagem>(
      builder: (context, estadoImagem, child) {
        final dadosFiltrados = estadoImagem.imagens.where((imagem) {
          final titulo = imagem.nomeImagem.toString();
          final termoBusca = _searchController.text.toLowerCase();
          final contemBusca =
              termoBusca.isEmpty || titulo.toLowerCase().contains(termoBusca);
          
          final correspondeLetra = filtroLetra == 'TODAS' || titulo.toUpperCase().startsWith(filtroLetra);
          
          return correspondeLetra && contemBusca;
        }).toList();

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Galeria",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              const Text(
                "Barra de pesquisa",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildSearchBar(),

              const SizedBox(height: 40),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFiltroLateral(),
                  const SizedBox(width: 40),
                  Expanded(
                    child: dadosFiltrados.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("Nenhum item encontrado."),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: 1.4,
                            ),
                            itemCount: dadosFiltrados.length,
                            itemBuilder: (context, index) {
                              final imagem = dadosFiltrados[index];
                              return _buildItemGaleria(imagem);
                            },
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            decoration: InputDecoration(
              hintText: "Digite aqui",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF388E3C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          ),
          child: const Row(
            children: [
              Text("Buscar"),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFiltroLateral() {
    return SizedBox(
      width: 65,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                filtroLetra = 'TODAS';
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: filtroLetra == 'TODAS' 
                    ? const Color(0xFF388E3C) 
                    : const Color(0xFF388E3C).withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'TODAS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          ...List.generate(26, (index) {
            String letra = String.fromCharCode(65 + index);
            bool isSelected = letra == filtroLetra;

            return GestureDetector(
              onTap: () {
                setState(() {
                  filtroLetra = letra;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(vertical: 6),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF388E3C).withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  letra,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF388E3C)
                        : Colors.black54,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String converterParaUrl(String caminhoRelativo) {
    if (caminhoRelativo.isEmpty) return '';

    final caminhoNormalizado = caminhoRelativo.replaceAll('\\', '/');
    return '$protocolo$baseURL/$caminhoNormalizado';
  }

  Future<void> carregarImagens() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final estadoImagem = Provider.of<EstadoImagem>(context, listen: false);
      await estadoImagem.carregarImagens();
    });
  }

  Widget _buildItemGaleria(Imagem imagem) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      padding: const EdgeInsets.all(6), 
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 231, 230, 230),
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [ 
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem 
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              converterParaUrl(imagem.enderecoThumbnail),
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_outlined, size: 40),
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // Capítulo + título + botão 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Capítulo
              Text(
                'Capítulo ${imagem.subtopico}',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                ),
              ),

              // Título + botão
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      imagem.nomeImagem,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaginaImagem(
                            imagemId: imagem.id,
                            nomeImagem: imagem.nomeImagem,
                            topico: imagem.topico,
                            subtopico: imagem.subtopico,
                            thumbnailUrl: imagem.enderecoThumbnail,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Acessar',
                          style: TextStyle(
                            color: Color.fromARGB(255, 170, 14, 170),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.arrow_right_alt_sharp,
                          color: Color.fromARGB(255, 170, 14, 170),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}