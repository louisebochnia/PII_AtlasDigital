import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../modelos/imagem.dart';

class EstadoImagem extends ChangeNotifier {
  static const _chave = 'atlas_imagens_v1';

  final List<Imagem> _imagens = [];
  List<Imagem> get imagens => List.unmodifiable(_imagens);

  static final String baseUrl = 'http://localhost:3000/images';

  bool _carregando = false;
  bool get carregando => _carregando;
  String? _erro;
  String? get erro => _erro;

  final String protocolo = 'http://';
  final String baseURL = 'localhost:3000';

  String converterParaUrl(String caminhoRelativo) {
    if (caminhoRelativo.isEmpty) return '';

    // Normaliza o caminho (substitui \ por /)
    final caminhoNormalizado = caminhoRelativo.replaceAll('\\', '/');

    // Remove barras extras no início
    final caminhoLimpo = caminhoNormalizado.startsWith('/')
        ? caminhoNormalizado.substring(1)
        : caminhoNormalizado;

    return '$protocolo$baseURL/$caminhoLimpo';
  }

  // Método específico para thumbnails
  String converterThumbnailParaUrl(String enderecoThumbnail) {
    return converterParaUrl(enderecoThumbnail);
  }

  // Método para buscar a primeira imagem de um subtópico
  Imagem? primeiraImagemPorSubtopico(String subtopicoNome) {
    final imagens = imagensPorSubtopico(subtopicoNome);
    return imagens.isNotEmpty ? imagens.first : null;
  }

  // Método para buscar todas as imagens de um subtópico
  List<Imagem> imagensPorSubtopico(String subtopicoNome) {
    return _imagens
        .where(
          (imagem) => _correspondeSubtopico(imagem.subtopico, subtopicoNome),
        )
        .toList();
  }

  // Método auxiliar para fazer match flexível de nomes
  bool _correspondeSubtopico(String nomeImagem, String nomeBuscado) {
    final nome1 = nomeImagem.toLowerCase().trim();
    final nome2 = nomeBuscado.toLowerCase().trim();

    // Verifica match exato
    if (nome1 == nome2) return true;

    // Verifica se um contém o outro
    if (nome1.contains(nome2) || nome2.contains(nome1)) return true;

    // Verifica palavras em comum
    final palavras1 = nome1.split(' ');
    final palavras2 = nome2.split(' ');

    return palavras1.any((palavra) => palavras2.contains(palavra)) ||
        palavras2.any((palavra) => palavras1.contains(palavra));
  }

  // CARREGAMENTO
  Future<void> carregarImagens() async {
    _carregando = true;
    notifyListeners();

    try {
      final res = await http.get(Uri.parse(baseUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _imagens
          ..clear()
          ..addAll(data.map((e) => Imagem.fromJson(e)).toList());
        await salvarLocal();

        debugPrint('-- Imagens carregadas: ${_imagens.length}');
        debugPrint(
          '-- Exemplo de thumbnail: ${_imagens.isNotEmpty ? converterThumbnailParaUrl(_imagens.first.enderecoThumbnail) : "Nenhuma"}',
        );
      }
    } catch (e) {
      debugPrint('-- Erro ao carregar imagens da API: $e');
      await carregarLocal();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // ... (mantenha o resto dos métodos CRUD, persistência e busca existentes)
  Future<bool> atualizarImagem(String id, Imagem imagem) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(imagem.toJson()),
      );

      if (res.statusCode == 200) {
        final index = _imagens.indexWhere((img) => img.id == id);
        if (index != -1) {
          _imagens[index] = imagem;
        } else {
          await carregarImagens();
          return true;
        }

        notifyListeners();
        await salvarLocal();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao atualizar imagem: $e');
      return false;
    }
  }

  Future<bool> removerImagem(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/$id'));

      if (res.statusCode == 200 || res.statusCode == 204) {
        await carregarImagens();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao remover imagem: $e');
      return false;
    }
  }

  // PERSISTÊNCIA LOCAL
  Future<void> salvarLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_imagens.map((i) => i.toJson()).toList());
    await prefs.setString(_chave, json);
  }

  Future<void> carregarLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chave);
    if (raw != null) {
      final lista = (jsonDecode(raw) as List)
          .map((e) => Imagem.fromJson(e as Map<String, dynamic>))
          .toList();
      _imagens
        ..clear()
        ..addAll(lista);
    }
  }

  // MÉTODOS DE BUSCA
  Imagem? encontrarPorId(String id) {
    try {
      return _imagens.firstWhere((imagem) => imagem.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Imagem> get todasAsImagens {
    return List<Imagem>.from(_imagens);
  }

  List<Imagem> obterTodasImagens() {
    return List<Imagem>.from(_imagens);
  }

  List<Imagem> imagensPorTopico(String topico) {
    return _imagens.where((imagem) => imagem.topico == topico).toList();
  }

  List<String> get topicosUnicos {
    final topicos = _imagens.map((imagem) => imagem.topico).toSet();
    return topicos.where((topico) => topico.isNotEmpty).toList();
  }

  List<String> get subtopicosUnicos {
    final subtopicos = _imagens.map((imagem) => imagem.subtopico).toSet();
    return subtopicos.where((subtopico) => subtopico.isNotEmpty).toList();
  }
}
