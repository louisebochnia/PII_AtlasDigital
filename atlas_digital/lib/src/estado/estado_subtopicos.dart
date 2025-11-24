import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../modelos/subtopicos.dart';
import '../../config/api_config.dart';

class EstadoSubtopicos extends ChangeNotifier {
  static const _chave = 'atlas_subtopicos_v1';
  final List<Subtopico> _subtopicos = [];
  List<Subtopico> get subtopicos => List.unmodifiable(_subtopicos);

  // MODIFICADO: Remove _baseUrl fixa
  String _getBaseUrl(String? baseUrl) => baseUrl ?? ApiConfig.baseUrl;

  // MODIFICADO: Aceita baseUrl como parâmetro
  Future<void> carregarBanco({String? baseUrl}) async {
    try {
      final String urlBase = _getBaseUrl(baseUrl);
      final res = await http.get(Uri.parse('$urlBase/subtopicos'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _subtopicos
          ..clear()
          ..addAll(data.map((e) => Subtopico.fromJson(e)).toList());
        await salvarLocal();
        notifyListeners();
        debugPrint('Subtópicos carregados do banco com sucesso de: $urlBase');
      } else {
        debugPrint('Erro ao carregar subtópicos: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Falha ao conectar com o servidor: $e');
      // Tenta carregar do cache local em caso de erro
      await carregarLocal();
    }
  }

  // MODIFICADO: Outros métodos também aceitam baseUrl
  Future<void> adicionarSubtopico(Subtopico s, {String? baseUrl}) async {
    try {
      final String urlBase = _getBaseUrl(baseUrl);
      final body = s.toJson();

      debugPrint('Enviando para: $urlBase/subtopicos');

      final res = await http.post(
        Uri.parse('$urlBase/subtopicos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Status Code: ${res.statusCode}');

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _subtopicos.add(Subtopico.fromJson(data));
        await salvarLocal();
        notifyListeners();
        debugPrint('Subtópico adicionado com sucesso!');
      } else {
        debugPrint('Erro ao adicionar subtópico: ${res.statusCode}');
        throw Exception('Erro ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('Falha ao salvar subtópico: $e');
      rethrow;
    }
  }

  Future<void> editarSubtopico(
    String id,
    Subtopico atualizado, {
    String? baseUrl,
  }) async {
    try {
      final String urlBase = _getBaseUrl(baseUrl);
      final res = await http.put(
        Uri.parse('$urlBase/subtopicos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(atualizado.toJson()),
      );

      if (res.statusCode == 200) {
        final index = _subtopicos.indexWhere((s) => s.id == id);
        if (index != -1) {
          _subtopicos[index] = atualizado;
          await salvarLocal();
          notifyListeners();
        }
      } else {
        debugPrint('Erro ao editar subtópico: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar subtópico: $e');
    }
  }

  Future<void> removerSubtopico(String id, {String? baseUrl}) async {
    try {
      final String urlBase = _getBaseUrl(baseUrl);
      final res = await http.delete(Uri.parse('$urlBase/subtopicos/$id'));
      if (res.statusCode == 200 || res.statusCode == 204) {
        _subtopicos.removeWhere((s) => s.id == id);
        await salvarLocal();
        notifyListeners();
      } else {
        debugPrint('Erro ao remover subtópico: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao deletar subtópico: $e');
    }
  }

  // ... resto do código permanece igual
  Future<void> salvarLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_subtopicos.map((s) => s.toJson()).toList());
    await prefs.setString(_chave, json);
  }

  Future<void> carregarLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chave);
    if (raw == null) return;
    final lista = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Subtopico.fromJson(e as Map<String, dynamic>))
        .toList();
    _subtopicos
      ..clear()
      ..addAll(lista);
    notifyListeners();
  }

  Future<void> limparLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }

  List<Subtopico> filtrarPorTopico(String topicoId) {
    return _subtopicos.where((s) => s.topicoId == topicoId).toList();
  }
}
