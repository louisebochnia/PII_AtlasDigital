import 'package:flutter/material.dart';
import '../modelos/topico.dart';
import '../componentes/sub_componentes/item_capitulo.dart';

class CartaoTopico extends StatelessWidget {
  final Topico topico;
  const CartaoTopico({super.key, required this.topico});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topico.titulo,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(topico.descricao, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: topico.capitulos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    ItemCapitulo(capitulo: topico.capitulos[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
