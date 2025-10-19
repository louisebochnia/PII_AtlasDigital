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
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final items = const ['Início', 'Conteúdo', 'Galeria'];

    return Material(
      elevation: 0,
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // ---- LOGO ----
              Row(
                children: [
                  Image.asset(
                    'assets/logo_fmabc.png',
                    height: 36, // ajuste o tamanho da logo aqui
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              const SizedBox(width: 24),

              // ---- MENU CENTRAL ----
              Wrap(
                spacing: 28,
                children: List.generate(items.length, (i) {
                  return _NavItem(
                    label: items[i],
                    selected: selectedIndex == i,
                    onTap: () => onItemTap(i),
                  );
                }),
              ),

              const Spacer(),

              // ---- BOTÃO "Acessar ATLAS" (verde) ----
              FilledButton(
                onPressed: onAtlas,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: AppColors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Acessar ATLAS',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),

              const SizedBox(width: 12),

              // ---- BOTÃO "LOGIN" (cinza escuro) ----
              FilledButton(
                onPressed: onLogin,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandGray90,
                  foregroundColor: AppColors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
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
