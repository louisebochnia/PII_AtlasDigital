import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:provider/provider.dart'; 
import '../../temas.dart';
import '../estado/estado_usuario.dart'; 

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
  Size get preferredSize => const Size.fromHeight(72);

  // Verifica se é desktop/web
  bool get isDesktopOrWeb {
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  @override
  Widget build(BuildContext context) {
    final estadoUsuario = Provider.of<EstadoUsuario>(context); 
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
              // LOGO
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

              // ---- MENU: Dropdown no mobile, Menu normal no desktop ----
              if (isDesktopOrWeb) 
                // MENU DESKTOP/WEB
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
                // DROPDOWN MOBILE
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _MobileDropdown(
                      items: items,
                      selectedIndex: selectedIndex,
                      onItemSelected: onItemTap,
                    ),
                  ),
                ),

              const Spacer(),
              const SizedBox(width: 12),

              //LOGIN ou ÁREA ADMINISTRATIVA
              if (!estadoUsuario.estaLogado && isDesktopOrWeb)
                FilledButton(
                  onPressed: onLogin,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 61, 61, 61),
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
                )
              else
                FilledButton(
                  onPressed: onLogin,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 61, 61, 61),
                    foregroundColor: AppColors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'ÁREA ADMINISTRATIVA',
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

// ---- COMPONENTE DROPDOWN PARA MOBILE ----
class _MobileDropdown extends StatefulWidget {
  final List<String> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _MobileDropdown({
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<_MobileDropdown> createState() => _MobileDropdownState();
}

class _MobileDropdownState extends State<_MobileDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.items[widget.selectedIndex],
      onChanged: (String? newValue) {
        if (newValue != null) {
          final index = widget.items.indexOf(newValue);
          widget.onItemSelected(index);
        }
      },
      items: widget.items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      underline: Container(), // Remove a linha padrão
      icon: Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
      isExpanded: false,
      elevation: 4,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
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