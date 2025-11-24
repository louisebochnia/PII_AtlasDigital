import 'package:flutter/material.dart';
import '../../temas.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

bool get isDesktopOrWeb {
  if (kIsWeb) return true;
  return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

class Rodape extends StatelessWidget {
  final List<FooterColumnData> colunas;
  final String endereco;
  final String site;
  final String logoAsset;
  final double borderRadius;
  final Function(BuildContext)? onTermosUso;
  final VoidCallback? onSiteTap;
  final VoidCallback? onInstagramTap;
  final VoidCallback? onFacebookTap;
  final VoidCallback? onLinkedInTap;
  final VoidCallback? onYouTubeTap;
  final VoidCallback? onQuiz;

  const Rodape({
    super.key,
    required this.colunas,
    required this.endereco,
    required this.site,
    required this.logoAsset,
    this.borderRadius = 22,
    this.onTermosUso,
    this.onSiteTap,
    this.onInstagramTap,
    this.onFacebookTap,
    this.onLinkedInTap,
    this.onYouTubeTap,
    this.onQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 1100;
    final double horizontalPadding = isMobile ? 20 : 160;

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
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                40,
                horizontalPadding,
                20,
              ),
              child: LayoutBuilder(
                builder: (context, c) {
                  final isNarrow = c.maxWidth < 900;
                  final isVeryNarrow = c.maxWidth < 620;

                  final main = isNarrow
                      ? Column(
                          crossAxisAlignment: isMobile
                              ? CrossAxisAlignment.center
                              : CrossAxisAlignment.start,
                          children: [
                            _Topo(logoAsset: logoAsset, isMobile: isMobile),
                            const SizedBox(height: 20),
                            _RedesSociais(
                              isMobile: isMobile,
                              onInstagramTap: onInstagramTap,
                              onFacebookTap: onFacebookTap,
                              onLinkedInTap: onLinkedInTap,
                              onYouTubeTap: onYouTubeTap,
                            ),
                            const SizedBox(height: 20),
                            _ColunasLinks(
                              colunas: colunas,
                              compact: isVeryNarrow,
                              onTermosUso: onTermosUso,
                              isMobile: isMobile,
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Topo(logoAsset: logoAsset, isMobile: false),
                                  const SizedBox(height: 20),
                                  _RedesSociais(
                                    isMobile: false,
                                    onInstagramTap: onInstagramTap,
                                    onFacebookTap: onFacebookTap,
                                    onLinkedInTap: onLinkedInTap,
                                    onYouTubeTap: onYouTubeTap,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 6,
                              child: _ColunasLinks(
                                colunas: colunas,
                                onTermosUso: onTermosUso,
                                isMobile: false,
                              ),
                            ),
                          ],
                        );

                  return Column(
                    children: [
                      main,
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0x14000000)),
                      const SizedBox(height: 10),
                      _RodapeLegal(
                        endereco: endereco,
                        site: site,
                        isMobile: isMobile,
                        onSiteTap: onSiteTap,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ao acessar o conteúdo, você automaticamente concorda com os Termos e Condições de Uso',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (!isDesktopOrWeb) const SizedBox(height: 50),
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

class _Topo extends StatelessWidget {
  final String logoAsset;
  final bool isMobile;

  const _Topo({required this.logoAsset, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final logo = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isMobile
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Image.asset(logoAsset, height: isMobile ? 48 : 54),
        if (!isMobile) const SizedBox(width: 12),
      ],
    );

    return isMobile
        ? Center(child: logo)
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: logo)],
          );
  }
}

class _RedesSociais extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onInstagramTap;
  final VoidCallback? onFacebookTap;
  final VoidCallback? onLinkedInTap;
  final VoidCallback? onYouTubeTap;

  const _RedesSociais({
    required this.isMobile,
    this.onInstagramTap,
    this.onFacebookTap,
    this.onLinkedInTap,
    this.onYouTubeTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = <Widget>[
      _SocialIcon(
        icon: Icons.photo_camera_outlined,
        tooltip: 'Instagram',
        onTap: onInstagramTap,
      ),
      _SocialIcon(
        icon: Icons.facebook,
        tooltip: 'Facebook',
        onTap: onFacebookTap,
      ),
      _SocialIcon(
        icon: Icons.business_center_outlined,
        tooltip: 'LinkedIn',
        onTap: onLinkedInTap,
      ),
      _SocialIcon(
        icon: Icons.smart_display,
        tooltip: 'YouTube',
        onTap: onYouTubeTap,
      ),
    ];

    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          'Nossas redes:',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: icons,
        ),
      ],
    );
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
          child: Icon(
            icon,
            size: 26,
            color: onTap != null ? AppColors.textPrimary : Colors.grey,
          ),
        ),
      ),
    );
  }
}

class _ColunasLinks extends StatelessWidget {
  final List<FooterColumnData> colunas;
  final bool compact;
  final Function(BuildContext)? onTermosUso;
  final bool isMobile;

  const _ColunasLinks({
    required this.colunas,
    this.compact = false,
    this.onTermosUso,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final children = colunas
        .map(
          (c) => _FooterColumn(
            title: c.titulo,
            items: c.itens,
            onTermosUso: onTermosUso,
            isMobile: isMobile,
          ),
        )
        .toList();

    if (compact) {
      return Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          for (final w in children) ...[w, const SizedBox(height: 16)],
        ],
      );
    }

    return Wrap(
      spacing: 32,
      runSpacing: 8,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      children: children,
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<FooterItem> items;
  final Function(BuildContext)? onTermosUso;
  final bool isMobile;

  const _FooterColumn({
    required this.title,
    required this.items,
    this.onTermosUso,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isMobile ? 180 : 220,
        maxWidth: isMobile ? 250 : 220,
      ),
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (!isMobile)
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
                  mainAxisAlignment: isMobile
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
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
                    Text(
                      item.label,
                      style: textStyle,
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                    ),
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
  final bool isMobile;
  final VoidCallback? onSiteTap;

  const _RodapeLegal({
    required this.endereco,
    required this.site,
    required this.isMobile,
    this.onSiteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          endereco,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            color: const Color(0xFF1E7A3A),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onSiteTap,
          child: Text(
            site,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: const Color(0xFF1E7A3A),
              decoration: TextDecoration.underline,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
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
