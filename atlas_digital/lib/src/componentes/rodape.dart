import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../temas.dart';

class Rodape extends StatelessWidget {
  final VoidCallback? onTermosUso;
  final List<FooterColumnData> colunas;
  final String endereco;
  final String site;
  final String logoAsset;
  final double borderRadius;

  const Rodape({
    super.key,
    this.onTermosUso,
    required this.colunas,
    required this.endereco,
    required this.site,
    required this.logoAsset,
    this.borderRadius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth > 1000 ? 160 : 20;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 2000),
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 40, horizontalPadding, 20),
              child: LayoutBuilder(
                builder: (context, c) {
                  final isNarrow = c.maxWidth < 900;
                  final isVeryNarrow = c.maxWidth < 620;

                  final main = isNarrow
                      ? Column(
                          // O alinhamento horizontal principal é CENTER no modo estreito
                          crossAxisAlignment: CrossAxisAlignment.center, 
                          children: [
                            // 1. LOGO
                            _Topo(
                              logoAsset: logoAsset,
                              isNarrow: isNarrow,
                            ),
                            const SizedBox(height: 30),
                            
                            // 2. COLUNAS DE LINKS
                            _ColunasLinks(colunas: colunas, compact: isVeryNarrow),
                            const SizedBox(height: 30), 

                            // 3. REDES SOCIAIS
                            _RedesSociais(isNarrow: isNarrow), // Passamos o estado Narrow
                            const SizedBox(height: 20),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1 & 3. Logo e Redes (Wide View)
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Topo(
                                    logoAsset: logoAsset,
                                    isNarrow: isNarrow,
                                  ),
                                  const SizedBox(height: 20),
                                  _RedesSociais(isNarrow: isNarrow),
                                ],
                              ),
                            ),

                            const SizedBox(width: 32),

                            // 2. Colunas de Links
                            Expanded(
                              flex: 6,
                              child: _ColunasLinks(colunas: colunas),
                            ),
                          ],
                        );

                  return Column(
                    children: [
                      main,
                      const SizedBox(height: 40), 
                      const Divider(height: 1, color: Color(0x14000000)),
                      const SizedBox(height: 20),
                      _RodapeLegal(endereco: endereco, site: site),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES CORRIGIDOS ---

class _Topo extends StatelessWidget {
  final String logoAsset;
  final VoidCallback? onFaq;
  final bool showFaqRight; 
  final bool isNarrow; // USADO PARA CENTRALIZAÇÃO

  const _Topo({
    required this.logoAsset,
    this.onFaq, // Mantido apenas para compatibilidade, mas removido do uso
    this.showFaqRight = false, // Mantido para compatibilidade
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context) {
    final logo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [Image.asset(logoAsset, height: 54), const SizedBox(width: 12)],
    );

    // Se a tela for estreita, usamos Center para centralizar a logo.
    if (isNarrow) {
      return Center(child: logo);
    }

    // Se for larga, mantemos a estrutura original do Row
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: logo),
      ],
    );
  }
}

class _RedesSociais extends StatelessWidget {
  final bool isNarrow;

  const _RedesSociais({this.isNarrow = false});

  @override
  Widget build(BuildContext context) {
    final icons = <Widget>[
      _SocialIcon(icon: Icons.photo_camera_outlined, tooltip: 'Instagram'),
      _SocialIcon(icon: Icons.facebook, tooltip: 'Facebook'),
      _SocialIcon(icon: Icons.business_center_outlined, tooltip: 'LinkedIn'),
      _SocialIcon(icon: Icons.smart_display, tooltip: 'YouTube'),
    ];

    return Column(
      // Se for estreito, centraliza o título e os ícones
      crossAxisAlignment: isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start, 
      children: [
        const Text(
          'Nossas redes:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: icons,
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  const _SocialIcon({required this.icon, required this.tooltip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x33000000), width: 1.6),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Icon(icon, size: 26, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _ColunasLinks extends StatelessWidget {
  final List<FooterColumnData> colunas;
  final bool compact;

  const _ColunasLinks({required this.colunas, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final children = colunas
        .map((c) => _FooterColumn(title: c.titulo, items: c.itens))
        .toList();

    if (compact) {
      return Column(
        // FIX: Centraliza os blocos de link quando empilhados
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          for (final w in children) ...[w, const SizedBox(height: 16)],
        ],
      );
    }

    return Wrap(spacing: 32, runSpacing: 8, children: children);
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<FooterItem> items;

  const _FooterColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220),
      child: Column(
        // Mantido o START aqui, pois a centralização é feita no widget PARENT (_ColunasLinks)
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 12,
            width: 220,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.brandGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: item.onTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.icon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          item.icon,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    Text(item.label, style: textStyle),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RodapeLegal extends StatelessWidget {
  final String endereco;
  final String site;

  const _RodapeLegal({required this.endereco, required this.site});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          endereco,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: Color(0xFF1E7A3A)),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _launchSite(site),
          child: Text(
            site,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1E7A3A),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchSite(String url) async {
    String formattedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      formattedUrl = 'https://$url';
    }
    final uri = Uri.parse(formattedUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $formattedUrl';
    }
  }
}

class FooterColumnData {
  final String titulo;
  final List<FooterItem> itens;
  const FooterColumnData({required this.titulo, required this.itens});
}

class FooterItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  const FooterItem(this.label, {this.icon, this.onTap});
}