import 'package:flutter/material.dart';

class PaginaGaleria extends StatefulWidget {
  const PaginaGaleria({super.key});

  @override
  State<PaginaGaleria> createState() => _PaginaGaleriaState();
}

class _PaginaGaleriaState extends State<PaginaGaleria> {
  String filtroLetra = 'A';
  final TextEditingController _searchController = TextEditingController();

  static const double kBreakpoint = 1000;

  // MOCK DE DADOS
  final List<Map<String, dynamic>> _dadosMock = [
    {
      "titulo": "A Band",
      "capitulo": "Capítulo 01",
      "imagens": ["img1", "img2", "img3", "img4"],
    },
    {
      "titulo": "Acidophil",
      "capitulo": "Capítulo 01",
      "imagens": ["img1", "img2", "img3"],
    },
    {
      "titulo": "Acidophilic (or eosinophilic)",
      "capitulo": "Capítulo 01",
      "imagens": ["img1", "img2", "img3", "img4"],
    },
    {
      "titulo": "Basophil",
      "capitulo": "Capítulo 02",
      "imagens": ["img1", "img2"],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth > kBreakpoint ? 80 : 20;

    final dadosFiltrados = _dadosMock.where((item) {
      final titulo = item["titulo"].toString();
      final iniciaComLetra = titulo.toUpperCase().startsWith(filtroLetra);
      final termoBusca = _searchController.text.toLowerCase();
      final contemBusca =
          termoBusca.isEmpty || titulo.toLowerCase().contains(termoBusca);
      return iniciaComLetra && contemBusca;
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
                    : Column(
                        children: dadosFiltrados
                            .map((item) => _buildItemGaleria(item))
                            .toList(),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES (mantidos) ---
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
          onPressed: () {},
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
      width: 50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF388E3C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              filtroLetra,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

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

  Widget _buildItemGaleria(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item["titulo"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow
                      .ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item["capitulo"],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 15),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: item['imagens'].length,
              itemBuilder: (context, index) {
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 16),
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
