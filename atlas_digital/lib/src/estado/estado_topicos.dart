import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../modelos/topico.dart';
import '../../config/api_config.dart';

class EstadoTopicos extends ChangeNotifier {
  static const _chave = 'atlas_topicos_v1';

  final List<Topico> _topicos = [];
  List<Topico> get topicos => List.unmodifiable(_topicos);

  static final String _baseUrl = '${ApiConfig.baseUrl}/topicos';

  // ---------------------------------------------------------------------------
  // MOCK local — usado apenas se o banco estiver vazio ou offline
  // ---------------------------------------------------------------------------
  void carregarMockSeVazio() {
    if (_topicos.isNotEmpty) return;
    _topicos.addAll([
      const Topico(
        id: 't1',
        titulo: 'Conteúdo de Teste',
        resumo: 'Resumo de teste',
      ),
    ]);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // CARREGAR DO BACKEND
  // ---------------------------------------------------------------------------
  Future<void> adicionarTopico(Topico t) async {
  try {
    final res = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(t.toJson()),
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      await carregarBanco();
    } else {
      debugPrint('Erro ao adicionar tópico: ${res.statusCode}');
    }
  } catch (e) {
    debugPrint('Falha ao salvar tópico: $e');
  }
}

Future<void> editarTopico(String id, Topico novo) async {
  try {
    final res = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(novo.toJson()),
    );

    if (res.statusCode == 200) {
      await carregarBanco();
    } else {
      debugPrint('Erro ao editar tópico: ${res.statusCode}');
    }
  } catch (e) {
    debugPrint('Erro ao atualizar tópico: $e');
  }
}

Future<void> removerTopico(String id) async {
  try {
    final res = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (res.statusCode == 200 || res.statusCode == 204) {
      await carregarBanco();
    } else {
      debugPrint('Erro ao remover tópico: ${res.statusCode}');
    }
  } catch (e) {
    debugPrint('Erro ao deletar tópico: $e');
  }
}

Future<void> carregarBanco() async {
  try {
    final res = await http.get(Uri.parse(_baseUrl));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;

      _topicos
        ..clear()
        ..addAll(data.map((e) => Topico.fromJson(e)).toList());

      await salvarLocal();

      notifyListeners();
      debugPrint('Tópicos carregados do banco com sucesso.');
    } else {
      debugPrint('Erro ao carregar tópicos do banco: ${res.statusCode}');
    }
  } catch (e) {
    debugPrint('Falha ao conectar com o servidor: $e');
  }
}



  // ---------------------------------------------------------------------------
  // Persistência local (cache offline)
  // ---------------------------------------------------------------------------
  Future<void> salvarLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_topicos.map((t) => t.toJson()).toList());
    await prefs.setString(_chave, json);
  }

  Future<void> carregarLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_chave);
    if (raw == null) return;
    final lista = (jsonDecode(raw) as List<dynamic>)
        .map((e) => Topico.fromJson(e as Map<String, dynamic>))
        .toList();
    _topicos
      ..clear()
      ..addAll(lista);
    notifyListeners();
  }

  Future<void> limparLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chave);
  }
}
