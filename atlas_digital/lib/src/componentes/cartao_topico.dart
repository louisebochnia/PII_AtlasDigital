import 'package:flutter/material.dart';
import '../modelos/topico.dart'; 

class CartaoTopico extends StatefulWidget {
  final Topico topico;
  const CartaoTopico({super.key, required this.topico});

  @override
  State<CartaoTopico> createState() => _CartaoTopicoState();
}

class _CartaoTopicoState extends State<CartaoTopico> {
  bool mostrarResumo = false;

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
              widget.topico.titulo,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (mostrarResumo)
              Text(widget.topico.resumo, style: theme.textTheme.bodyMedium),
            TextButton(
              onPressed: () => setState(() => mostrarResumo = !mostrarResumo),
              child: Text(mostrarResumo ? 'Esconder Resumo' : 'Mostrar Resumo'),
            ),
          ],
        ),
      ),
    );
  }
}
