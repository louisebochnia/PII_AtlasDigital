import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_topicos.dart';
import '../modelos/topico.dart';
import '../modelos/capitulo.dart';

class PaginaAdmConteudosProvisorio extends StatelessWidget {
  const PaginaAdmConteudosProvisorio({super.key});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoTopicos>();

    return Scaffold(
      appBar: AppBar(title: const Text('Tópicos – Admin (Provisório)')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirDialogoTopico(context),
        label: const Text('Adicionar Tópico +'),
        icon: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: estado.topicos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final t = estado.topicos[i];
          return Card(
            child: ListTile(
              title: Text(t.titulo),
              subtitle: Text(
                t.descricao,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _abrirDialogoTopico(context, topico: t),
                  ),
                  IconButton(
                    tooltip: 'Excluir',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmarExcluirTopico(context, t.id),
                  ),
                ],
              ),
              onTap: () => _abrirDialogoCapitulos(context, t),
            ),
          );
        },
      ),
    );
  }

  Future<void> _abrirDialogoTopico(
    BuildContext context, {
    Topico? topico,
  }) async {
    final tituloCtrl = TextEditingController(text: topico?.titulo ?? '');
    final descCtrl = TextEditingController(text: topico?.descricao ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(topico == null ? 'Novo Tópico' : 'Editar Tópico'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descrição *'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final estado = context.read<EstadoTopicos>();
    if (topico == null) {
      final novo = Topico(
        id: UniqueKey().toString(),
        titulo: tituloCtrl.text.trim(),
        descricao: descCtrl.text.trim(),
        capitulos: const [],
      );
      estado.adicionarTopico(novo);
    } else {
      estado.editarTopico(
        topico.id,
        topico.copyWith(
          titulo: tituloCtrl.text.trim(),
          descricao: descCtrl.text.trim(),
        ),
      );
    }
  }

  Future<void> _abrirDialogoCapitulos(
    BuildContext context,
    Topico topico,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _DialogoCapitulos(topico: topico),
    );
  }

  void _confirmarExcluirTopico(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Tópico?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (ok == true) {
      context.read<EstadoTopicos>().removerTopico(id);
    }
  }
}

class _DialogoCapitulos extends StatelessWidget {
  final Topico topico;
  const _DialogoCapitulos({required this.topico});

  @override
  Widget build(BuildContext context) {
    final estado = context.watch<EstadoTopicos>();
    final t = estado.topicos.firstWhere((e) => e.id == topico.id);

    return AlertDialog(
      title: Text('Capítulos de "${t.titulo}"'),
      content: SizedBox(
        width: 700,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () => _abrirDialogoCapitulo(context, idTopico: t.id),
                child: const Text('Adicionar Capítulo +'),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: t.capitulos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final c = t.capitulos[i];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(c.indice.toString().padLeft(2, '0')),
                    ),
                    title: Text(c.titulo),
                    subtitle: Text(c.rotaOuSlug),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _abrirDialogoCapitulo(
                            context,
                            idTopico: t.id,
                            capitulo: c,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Excluir',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => context
                              .read<EstadoTopicos>()
                              .removerCapitulo(t.id, c.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Future<void> _abrirDialogoCapitulo(
    BuildContext context, {
    required String idTopico,
    Capitulo? capitulo,
  }) async {
    final idxCtrl = TextEditingController(
      text: capitulo?.indice.toString() ?? '',
    );
    final tituloCtrl = TextEditingController(text: capitulo?.titulo ?? '');
    final rotaCtrl = TextEditingController(text: capitulo?.rotaOuSlug ?? '');
    final capaCtrl = TextEditingController(text: capitulo?.capaUrl ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(capitulo == null ? 'Novo Capítulo' : 'Editar Capítulo'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idxCtrl,
                decoration: const InputDecoration(
                  labelText: 'Índice (número) *',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: rotaCtrl,
                decoration: const InputDecoration(labelText: 'Rota/Slug *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capaCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL da Capa (opcional)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final estado = context.read<EstadoTopicos>();
    final cap = Capitulo(
      id: capitulo?.id ?? UniqueKey().toString(),
      indice: int.tryParse(idxCtrl.text.trim()) ?? 1,
      titulo: tituloCtrl.text.trim(),
      rotaOuSlug: rotaCtrl.text.trim(),
      capaUrl: capaCtrl.text.trim().isEmpty ? null : capaCtrl.text.trim(),
    );

    if (capitulo == null) {
      estado.adicionarCapitulo(idTopico, cap);
    } else {
      estado.editarCapitulo(idTopico, capitulo.id, cap);
    }
  }
}
