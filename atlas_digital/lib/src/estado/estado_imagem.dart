import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../modelos/imagem.dart';

class EstadoImagem extends ChangeNotifier {
  static const _chave = 'atlas_imagens_v1';

  final List<Imagem> _imagens = [];
  List<Imagem> get imagens => List.unmodifiable(_imagens);

  // Remove baseUrl fixa
  String _getBaseUrl(String? baseUrl) => baseUrl ?? 'http://localhost:3000';

  bool _carregando = false;
  bool get carregando => _carregando;
  String? _erro;
  String? get erro => _erro;

  // Aceita baseUrl como parâmetro
  String converterParaUrl(String caminhoRelativo, {String? baseUrl}) {
    if (caminhoRelativo.isEmpty) return '';

    final String urlBase = _getBaseUrl(baseUrl);

    // Normaliza o caminho (substitui \ por /)
    final caminhoNormalizado = caminhoRelativo.replaceAll('\\', '/');

    // Remove barras extras no início
    final caminhoLimpo = caminhoNormalizado.startsWith('/')
        ? caminhoNormalizado.substring(1)
        : caminhoNormalizado;

    return '$urlBase/$caminhoLimpo';
  }

  // Aceita baseUrl como parâmetro
  String converterThumbnailParaUrl(
    String enderecoThumbnail, {
    String? baseUrl,
  }) {
    return converterParaUrl(enderecoThumbnail, baseUrl: baseUrl);
  }

  // Aceita baseUrl como parâmetro
  Future<void> carregarImagens({String? baseUrl}) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final String urlBase = _getBaseUrl(baseUrl);
      final res = await http.get(Uri.parse('$urlBase/images'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _imagens
          ..clear()
          ..addAll(data.map((e) => Imagem.fromJson(e)).toList());
        await salvarLocal();

        debugPrint('-- Imagens carregadas de $urlBase: ${_imagens.length}');
        debugPrint(
          '-- Exemplo de thumbnail: ${_imagens.isNotEmpty ? converterThumbnailParaUrl(_imagens.first.enderecoThumbnail, baseUrl: baseUrl) : "Nenhuma"}',
        );
      } else {
        _erro = 'Erro HTTP ${res.statusCode}';
        debugPrint('-- Erro ao carregar imagens: $_erro');
        await carregarLocal();
      }
    } catch (e) {
      _erro = 'Falha na conexão: $e';
      debugPrint('-- Erro ao carregar imagens da API: $e');
      await carregarLocal();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // Outros métodos também aceitam baseUrl
  Future<bool> atualizarImagem(
    String id,
    Imagem imagem, {
    String? baseUrl,
  }) async {
    try {
      final String urlBase = _getBaseUrl(baseUrl);
      final res = await http.put(
        Uri.parse('$urlBase/images/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(imagem.toJson()),
      );

      if (res.statusCode == 200) {
        final index = _imagens.indexWhere((img) => img.id == id);
        if (index != -1) {
          _imagens[index] = imagem;
        } else {
          await carregarImagens(baseUrl: baseUrl);
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

  Future<bool> removerImagem(String id, {String? baseUrl}) async {
    try {
      final String urlBase = _getBaseUrl(baseUrl);
      final res = await http.delete(Uri.parse('$urlBase/images/$id'));

      if (res.statusCode == 200 || res.statusCode == 204) {
        await carregarImagens(baseUrl: baseUrl);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao remover imagem: $e');
      return false;
    }
  }

  Imagem? primeiraImagemPorSubtopico(String subtopicoNome) {
    final imagens = imagensPorSubtopico(subtopicoNome);
    return imagens.isNotEmpty ? imagens.first : null;
  }

  List<Imagem> imagensPorSubtopico(String subtopicoNome) {
    return _imagens
        .where(
          (imagem) => _correspondeSubtopico(imagem.subtopico, subtopicoNome),
        )
        .toList();
  }

  bool _correspondeSubtopico(String nomeImagem, String nomeBuscado) {
    final nome1 = nomeImagem.toLowerCase().trim();
    final nome2 = nomeBuscado.toLowerCase().trim();

    if (nome1 == nome2) return true;
    if (nome1.contains(nome2) || nome2.contains(nome1)) return true;

    final palavras1 = nome1.split(' ');
    final palavras2 = nome2.split(' ');

    return palavras1.any((palavra) => palavras2.contains(palavra)) ||
        palavras2.any((palavra) => palavras1.contains(palavra));
  }

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

  List<Imagem> get todasAsImagens {
    return List<Imagem>.from(_imagens);
  }

  List<Imagem> obterTodasImagens() {
    return List<Imagem>.from(_imagens);
  }

  Imagem? encontrarPorId(String id) {
    try {
      return _imagens.firstWhere((imagem) => imagem.id == id);
    } catch (e) {
      return null;
    }
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
