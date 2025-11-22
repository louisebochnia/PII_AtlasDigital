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


  // CARREGAMENTO
  Future<void> carregarImagens() async {
    _carregando = true;

    notifyListeners();

    try {
      final res = await http.get(Uri.parse(baseUrl));
      if(res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _imagens
          ..clear()
          ..addAll(data.map((e) => Imagem.fromJson(e)).toList());
        await salvarLocal();
      } 
    } catch (e) {
      await carregarLocal();
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // CRUD
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

  List<Imagem> imagensPorTopico(String topico) {
    return _imagens.where((imagem) => imagem.topico == topico).toList();
  }

  List<Imagem> imagensPorSubtopico(String subtopico) {
    return _imagens.where((imagem) => imagem.subtopico == subtopico).toList();
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