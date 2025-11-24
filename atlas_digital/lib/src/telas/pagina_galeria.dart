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

  static const double kLargeBreakpoint = 1000;
  static const double kSmallBreakpoint = 600;

  @override
  void initState() {
    super.initState();
    carregarImagens();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth > kLargeBreakpoint ? 80 : 20;

    final bool showSideFilter = screenWidth > kLargeBreakpoint;

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

        return SingleChildScrollView(
          child: Padding(
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
                _buildSearchBar(screenWidth),

                const SizedBox(height: 40),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showSideFilter) 
                      _buildFiltroLateral(),
                      
                    if (showSideFilter)
                      const SizedBox(width: 40),
                      
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!showSideFilter) 
                            _buildFilterChips(), 
                          
                          if (!showSideFilter) 
                            const SizedBox(height: 20),
                          
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final innerWidth = constraints.maxWidth;
                              return _buildGaleriaResponsiva(innerWidth, dadosFiltrados);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGaleriaResponsiva(double innerWidth, List<Imagem> dadosFiltrados) {
    if (dadosFiltrados.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Nenhum item encontrado."),
      );
    }

    if (innerWidth <= kSmallBreakpoint) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dadosFiltrados.length,
        itemBuilder: (context, index) {
          final imagem = dadosFiltrados[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0), 
            child: _buildItemGaleria(imagem, innerWidth, isListView: true),
          );
        },
      );
    } 
    
    else {
      final int crossAxisCount = innerWidth > kLargeBreakpoint ? 5 : 3;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          childAspectRatio: 1.4,
        ),
        itemCount: dadosFiltrados.length,
        itemBuilder: (context, index) {
          final imagem = dadosFiltrados[index];
          return _buildItemGaleria(imagem, innerWidth, isListView: false);
        },
      );
    }
  }

  Widget _buildFilterChips() {
    final List<String> letras = ['TODAS'] + List.generate(26, (index) => String.fromCharCode(65 + index));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: letras.map((letra) {
          bool isSelected = letra == filtroLetra;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
              label: Text(letra),
              backgroundColor: isSelected 
                  ? const Color(0xFF388E3C) 
                  : const Color(0xFFE0E0E0),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              onPressed: () {
                setState(() {
                  filtroLetra = letra;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    final bool isSmallScreen = screenWidth <= kSmallBreakpoint; 

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
                borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 20,
              ),
            ),
          ),
        ),
        if (!isSmallScreen) ...[
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
        ]
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
              child: const Text(
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

  Widget _buildItemGaleria(Imagem imagem, double screenWidth, {required bool isListView}) {
    const Color corFundoGaleria = Color.fromARGB(255, 231, 230, 230);
    
    if (isListView) {
      return Container(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: corFundoGaleria, 
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                converterParaUrl(imagem.enderecoThumbnail),
                height: 80, 
                width: 80, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80, width: 80, color: Colors.grey[300],
                  child: const Icon(Icons.image_outlined, size: 30),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Text(
                    'Capítulo ${imagem.subtopico}',
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                  Text(
                    imagem.nomeImagem,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: _buildAcessarButton(imagem),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } 
    
    else {
      return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        padding: const EdgeInsets.all(6), 
        decoration: BoxDecoration(
          color: corFundoGaleria, 
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                converterParaUrl(imagem.enderecoThumbnail),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120, width: double.infinity, color: Colors.grey[300],
                  child: const Icon(Icons.image_outlined, size: 40),
                ),
              ),
            ),

            const SizedBox(height: 6),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Capítulo ${imagem.subtopico}',
                    style: const TextStyle(fontSize: 10, color: Colors.black),
                  ),
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
                      _buildAcessarButton(imagem),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildAcessarButton(Imagem imagem) {
    return TextButton(
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
              color: Color.fromARGB(
                255,
                170,
                14,
                170,
              ), 
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 2),
          Icon(
            Icons.arrow_right_alt_sharp,
            color: Color.fromARGB(
              255,
              170,
              14,
              170,
            ),
            size: 24,
          ),
        ],
      ),
    );
  }
}