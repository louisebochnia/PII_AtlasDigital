import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:provider/provider.dart'; 
import '../../temas.dart';
import '../estado/estado_usuario.dart'; 

// Ponto de quebra para mobile/tablet
const double kBreakpoint = 1000;

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTap;
  final VoidCallback onAtlas;
  final VoidCallback? onLogin;

  const TopNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTap,
    required this.onAtlas,
    this.onLogin,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  bool get isDesktopOrWeb {
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  @override
  Widget build(BuildContext context) {
    final estadoUsuario = Provider.of<EstadoUsuario>(context); 
    final items = const ['Início', 'Conteúdo', 'Galeria'];
    
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > kBreakpoint;
    final double horizontalPadding = isWideScreen ? 80 : 20;

    return Material(
      elevation: 0,
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: preferredSize.height,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 2000), 
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                children: [
                  // 1. LOGO
                  GestureDetector(
                    onTap: onAtlas,
                    child: Row(
                      children: [
                        Image.asset('assets/logo_fmabc.png', height: 36),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // 2. MENU PRINCIPAL (Desktop)
                  if (isWideScreen) 
                    Wrap(
                      spacing: 28,
                      children: List.generate(items.length, (i) {
                        return _NavItem(
                          label: items[i],
                          selected: selectedIndex == i,
                          onTap: () => onItemTap(i),
                        );
                      }),
                    )
                  else 
                    // 2b. Ocupa espaço para empurrar o Login/Hamburger
                    const Spacer(),

                  const Spacer(), // Empurra os elementos de controle para a direita

                  // 3. BOTÕES DE CONTROLE (Responsivo)
                  if (isWideScreen) 
                    // DESKTOP: Apenas o botão de Login/Admin, Menu visível
                    _LoginAdminButton(estadoUsuario: estadoUsuario, onLogin: onLogin, isMobile: false)
                  else
                    // MOBILE: [Login/Admin Button, 20px Gap, Hamburger Menu]
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LoginAdminButton(estadoUsuario: estadoUsuario, onLogin: onLogin, isMobile: true), // Botão visível
                        const SizedBox(width: 20), // GAP de 20px
                        _MobileMenuButton( // Hamburger na extrema direita
                          items: items,
                          selectedIndex: selectedIndex,
                          onItemSelected: onItemTap,
                        ),
                      ],
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

// --- WIDGET AUXILIAR: BOTÃO LOGIN/ADMIN (Consolidado) ---
class _LoginAdminButton extends StatelessWidget {
  final EstadoUsuario estadoUsuario;
  final VoidCallback? onLogin;
  final bool isMobile;

  const _LoginAdminButton({required this.estadoUsuario, this.onLogin, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final label = estadoUsuario.estaLogado ? 'ÁREA ADMINISTRATIVA' : 'LOGIN';
    
    return FilledButton(
      onPressed: onLogin,
      style: FilledButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 61, 61, 61),
        foregroundColor: AppColors.white,
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: 18,
          // Ajusta o padding para ser mais amigável ou seguir o padrão
          vertical: isMobile ? 10 : 14, 
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

// --- WIDGET AUXILIAR: BOTÃO HAMBÚRGUER MOBILE/TABLET ---
class _MobileMenuButton extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _MobileMenuButton({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: Icon(
        Icons.menu,
        color: AppColors.textPrimary,
        size: 30,
      ),
      onSelected: (int index) {
        onItemSelected(index);
      },
      itemBuilder: (BuildContext context) {
        return List.generate(items.length, (i) {
          final isSelected = selectedIndex == i;
          return PopupMenuItem<int>(
            value: i,
            child: Text(
              items[i],
              style: TextStyle(
                color: isSelected ? AppColors.brandGreen : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        });
      },
    );
  }
}

// ---- COMPONENTE ORIGINAL DO ITEM DE MENU (para desktop) ----
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