import 'package:flutter/material.dart';
import '../modelos/topico.dart';
import '../modelos/subtopicos.dart';
import '../servicos/ServConteudo.dart'; // Você precisará criar isso
import '../componentes/sub_componentes/componenteTopicoshorizontais.dart';

class PaginaConteudo extends StatefulWidget {
  const PaginaConteudo({super.key});

  @override
  State<PaginaConteudo> createState() => _PaginaConteudoState();
}

class _PaginaConteudoState extends State<PaginaConteudo> {
  late Future<List<Topico>> _topicosFuture;
  final ServicoApi _servicoApi = ServicoApi();

  @override
  void initState() {
    super.initState();
    _topicosFuture = _servicoApi.getTopicos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Topico>>(
      future: _topicosFuture,
      builder: (context, snapshot) {
        // Widgets SEM Expanded, SEM Flexible, SEM Spacer
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCarregando();
        }

        if (snapshot.hasError) {
          return _buildErro(snapshot.error.toString());
        }

        final topicos = snapshot.data ?? [];
        
        if (topicos.isEmpty) {
          return _buildVazio();
        }

        return _buildConteudo(topicos);
      },
    );
  }

  Widget _buildCarregando() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Cabecalho(),
        SizedBox(height: 100),
        CircularProgressIndicator(),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildErro(String erro) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Cabecalho(),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Erro: $erro', textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _topicosFuture = _servicoApi.getTopicos();
                  });
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildVazio() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Cabecalho(),
        SizedBox(height: 100),
        Text('Nenhum conteúdo disponível'),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildConteudo(List<Topico> topicos) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Cabecalho(),
        ...topicos.map((topico) => _buildSecaoTopico(topico)).toList(),
      ],
    );
  }

  Widget _buildSecaoTopico(Topico topico) {
    return FutureBuilder<List<Subtopico>>(
      future: _servicoApi.getSubtopicosPorTopico(topico.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('Erro ao carregar subtópicos: ${snapshot.error}'),
          );
        }

        final subtopicos = snapshot.data ?? [];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: SecaoHorizontal(
            titulo: topico.titulo,
            descricao: topico.resumo,
            subtopicos: subtopicos,
          ),
        );
      },
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conteúdo',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Esta galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo.',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}