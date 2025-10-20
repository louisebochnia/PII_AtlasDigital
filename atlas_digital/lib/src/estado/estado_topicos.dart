import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../modelos/topico.dart';
import '../modelos/capitulo.dart';
import '../../config/api_config.dart';

class EstadoTopicos extends ChangeNotifier {
  static const _chave = 'atlas_topicos_v1';

  final List<Topico> _topicos = [];
  List<Topico> get topicos => List.unmodifiable(_topicos);

  // URL base da sua API (ajuste conforme seu backend)
  static final String _baseUrl = '${ApiConfig.baseUrl}/topicos';


  // ---------------------------------------------------------------------------
  // MOCK local — usado apenas se o banco estiver vazio ou offline
  // ---------------------------------------------------------------------------
  void carregarMockSeVazio() {
    if (_topicos.isNotEmpty) return;
    _topicos.addAll([
      Topico(
        id: 't1',
        titulo: 'Conteúdo de Teste',
        descricao: 'Descrição de teste',
        capitulos: const [],
      ),
    ]);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // CARREGAR DO BACKEND
  // ---------------------------------------------------------------------------
  Future<void> carregarDoBanco() async {
    try {
      final res = await http.get(Uri.parse(_baseUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _topicos
          ..clear()
          ..addAll(data.map((e) => Topico.fromJson(e)).toList());
        notifyListeners();
      } else {
        debugPrint('Erro ao buscar tópicos: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao conectar com o servidor: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // CRUD Tópico (sincronizado com API)
  // ---------------------------------------------------------------------------
  Future<void> adicionarTopico(Topico t) async {
    try {
      final res = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(t.toJson()),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        _topicos.add(t);
        notifyListeners();
      } else {
        debugPrint('Erro ao adicionar tópico no servidor: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Falha ao salvar tópico: $e');
    }
  }

  Future<void> editarTopico(String id, Topico novo) async {
    final i = _topicos.indexWhere((e) => e.id == id);
    if (i == -1) return;

    try {
      final res = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(novo.toJson()),
      );

      if (res.statusCode == 200) {
        _topicos[i] = novo;
        notifyListeners();
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
        _topicos.removeWhere((e) => e.id == id);
        notifyListeners();
      } else {
        debugPrint('Erro ao remover tópico: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro ao deletar tópico: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // CRUD Capítulo (mantém local — backend ainda não implementa capítulos)
  // ---------------------------------------------------------------------------
  void adicionarCapitulo(String idTopico, Capitulo c) {
    final i = _topicos.indexWhere((e) => e.id == idTopico);
    if (i == -1) return;
    final lista = [..._topicos[i].capitulos, c];
    _topicos[i] = _topicos[i].copyWith(capitulos: lista);
    notifyListeners();
  }

  void editarCapitulo(String idTopico, String idCapitulo, Capitulo novo) {
    final i = _topicos.indexWhere((e) => e.id == idTopico);
    if (i == -1) return;
    final caps = [..._topicos[i].capitulos];
    final j = caps.indexWhere((e) => e.id == idCapitulo);
    if (j != -1) {
      caps[j] = novo;
      _topicos[i] = _topicos[i].copyWith(capitulos: caps);
      notifyListeners();
    }
  }

  void removerCapitulo(String idTopico, String idCapitulo) {
    final i = _topicos.indexWhere((e) => e.id == idTopico);
    if (i == -1) return;
    final caps = _topicos[i].capitulos.where((e) => e.id != idCapitulo).toList();
    _topicos[i] = _topicos[i].copyWith(capitulos: caps);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Persistência local (opcional – cache offline)
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
