import 'package:flutter/material.dart';
import '../../temas.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  final VoidCallback onAtlas;
  final VoidCallback onLogin;

  const TopNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
    required this.onAtlas,
    required this.onLogin,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final items = const ['Início', 'Conteúdo', 'Galeria'];
    
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth > 1000 ? 160 : 20;

    return Material(
      elevation: 0,
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          // Removemos o padding fixo daqui e aplicamos dentro da estrutura centralizada
          alignment: Alignment.center, // Centraliza o bloco de conteúdo
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))), // Opcional: linha sutil abaixo da navbar
          ),
          child: ConstrainedBox(
            // Mantém o mesmo limite da PaginaInicial (1100px)
            constraints: const BoxConstraints(maxWidth: 2000),
            child: Padding(
              // Aplica a margem de 80px (ou 20px)
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  // ---- LOGO ----
                  Row(
                    children: [
                      Image.asset(
                        'assets/logo_fmabc.png',
                        height: 36,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  const SizedBox(width: 24),

                  // ---- MENU CENTRAL ----
                  // Em telas muito pequenas, talvez seja melhor esconder isso ou usar um Drawer,
                  // mas por enquanto mantemos o Wrap.
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        spacing: 28,
                        children: List.generate(items.length, (i) {
                          return _NavItem(
                            label: items[i],
                            selected: selectedIndex == i,
                            onTap: () => onItemTap(i),
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ---- BOTÃO "LOGIN" ----
                  FilledButton(
                    onPressed: onLogin,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandGray90,
                      foregroundColor: AppColors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'LOGIN',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.selected || _hover;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: .2,
              ),
            ),
            const SizedBox(height: 6),
            // Sublinhado amarelo
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              height: 3,
              width: isActive ? 28 : 0,
              decoration: BoxDecoration(
                color: widget.selected
                    ? AppColors.brandYellow
                    : AppColors.brandYellow.withOpacity(_hover ? 0.6 : 0.0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}