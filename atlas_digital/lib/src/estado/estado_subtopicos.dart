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

  static final String _baseUrl = '${ApiConfig.baseUrl}/subtopicos';

  // ---------------------------------------------------------------------------
  // Adicionar Subtópico
  // ---------------------------------------------------------------------------
  Future<void> adicionarSubtopico(Subtopico s) async {
    try {
      final body = s.toJson();

      // DEBUG DETALHADO
      debugPrint('=== DADOS DO SUBTÓPICO ===');
      debugPrint('ID: ${s.id}');
      debugPrint('Índice: ${s.indice} (tipo: ${s.indice.runtimeType})');
      debugPrint('Título: ${s.titulo}');
      debugPrint('TopicoId: ${s.topicoId}');
      debugPrint('CapaUrl: ${s.capaUrl}');
      debugPrint('Informações: ${s.informacoes.length}');
      debugPrint('JSON a ser enviado: ${jsonEncode(body)}');
      debugPrint('URL: $_baseUrl');

      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Status Code: ${res.statusCode}');
      debugPrint('Resposta do servidor: ${res.body}');

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

  // ---------------------------------------------------------------------------
  // Editar Subtópico
  // ---------------------------------------------------------------------------
  Future<void> editarSubtopico(String id, Subtopico atualizado) async {
    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/$id'),
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

  // ---------------------------------------------------------------------------
  // Remover Subtópico
  // ---------------------------------------------------------------------------
  Future<void> removerSubtopico(String id) async {
    try {
      final res = await http.delete(Uri.parse('$_baseUrl/$id'));
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

  // ---------------------------------------------------------------------------
  // Carregar do backend
  // ---------------------------------------------------------------------------
  Future<void> carregarBanco() async {
    try {
      final res = await http.get(Uri.parse(_baseUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _subtopicos
          ..clear()
          ..addAll(data.map((e) => Subtopico.fromJson(e)).toList());
        await salvarLocal();
        notifyListeners();
        debugPrint('Subtópicos carregados do banco com sucesso.');
      } else {
        debugPrint('Erro ao carregar subtópicos: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Falha ao conectar com o servidor: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Persistência local - Para testes
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Filtrar por topicoId
  // ---------------------------------------------------------------------------
  List<Subtopico> filtrarPorTopico(String topicoId) {
    return _subtopicos.where((s) => s.topicoId == topicoId).toList();
  }
}
