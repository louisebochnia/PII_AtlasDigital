import 'package:flutter/material.dart';
import '../../modelos/capitulo.dart';

class ItemCapitulo extends StatelessWidget {
  final Capitulo capitulo;
  const ItemCapitulo({super.key, required this.capitulo});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(capitulo.rotaOuSlug),
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 260,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor.withOpacity(.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem/Thumb (placeholder cinza quando não houver capa):
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                image: capitulo.capaUrl != null
                    ? DecorationImage(
                        image: NetworkImage(capitulo.capaUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: capitulo.capaUrl == null
                  ? Icon(
                      Icons.image_outlined,
                      size: 36,
                      color: theme.colorScheme.onSurface.withOpacity(.5),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Capítulo ${capitulo.indice.toString().padLeft(2, '0')}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    capitulo.titulo,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          capitulo.cta,
                          style: theme.textTheme.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
