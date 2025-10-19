<<<<<<< HEAD
import 'package:atlas_digital/src/componentes/sub_componentes/painelAdm_Conteudo.dart';
=======
import 'package:atlas_digital/src/componentes/sub_componentes/painelAdm_Conteudo.dart';
import 'package:atlas_digital/src/componentes/sub_componentes/painelAdm_Galeria.dart';
>>>>>>> 7dc5a61aab8ed55a95d0ba85f31995a9bc19f904
import 'package:flutter/material.dart';

class PainelAdm extends StatefulWidget {
  const PainelAdm({super.key});

  @override
  State<PainelAdm> createState() => _PainelAdmState();
}

class _PainelAdmState extends State<PainelAdm> {
  int _selectedIndex = 0; // índice do botão selecionado

  final List<String> _menuLabels = [
    "Início",
    "Conteúdo",
    "Galeria",
    "Pessoas",
  ];

  final List<IconData> _menuIcons = [
    Icons.home,
    Icons.content_paste_outlined,
    Icons.image_outlined,
    Icons.people_alt_outlined,
  ];

  final List<Widget> _menuContents = [
    Center(child: Text("Bem-vindo à página inicial!", style: TextStyle(fontSize: 22, fontFamily: "Poppins", fontWeight: FontWeight.bold))),
    ConteudoPage(),
    GaleriaPage(),
    Center(child: Text("Lista de pessoas / usuários.", style: TextStyle(fontSize: 22, fontFamily: "Poppins", fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(40),
        child: Row(
          children: [
            // MENU LATERAL
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: const Color.fromARGB(255, 214, 206, 206),
                      width: 4,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < _menuLabels.length; i++) ...[
                      _menuButton(_menuIcons[i], _menuLabels[i], i),
                      const SizedBox(height: 12),
                    ],
                    const Spacer(),
                    _exitButton(),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 20),

            // CONTEÚDO PRINCIPAL COM ANIMAÇÃO
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_selectedIndex),
                    child: _menuContents[_selectedIndex],
                  ),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Função para gerar os botões do menu
  Widget _menuButton(IconData icon, String label, int index) {
    bool isSelected = index == _selectedIndex;

    return TextButton(
      onPressed: () {
        if (!mounted) return;
        setState(() {
          _selectedIndex = index;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSelected
              ? const BorderSide(color: Colors.green, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.green),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                fontFamily: "Poppins",
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Botão de saída vermelho
  Widget _exitButton() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 250, 17, 1),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: const [
          Icon(Icons.exit_to_app_outlined, color: Colors.white),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              "Voltar para o site",
              style: TextStyle(
                fontSize: 15,
                fontFamily: "Poppins",
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
