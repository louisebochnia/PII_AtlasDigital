import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/topico.dart';
import '../modelos/capitulo.dart';

class EstadoTopicos extends ChangeNotifier {
  static const _chave = 'atlas_topicos_v1';

  final List<Topico> _topicos = [];
  List<Topico> get topicos => List.unmodifiable(_topicos);

  // ---- MOQUE inicial para visualizar na página pública ----
  void carregarMockSeVazio() {
    if (_topicos.isNotEmpty) return;
    _topicos.addAll([
      Topico(
        id: 't1',
        titulo: 'Tecidos e Órgãos',
        descricao:
            'Essa galeria permite a navegação rápida pelas lâminas de microscópio em cada capítulo. Embora as lâminas não tenham descrições, você ainda pode identificar características individuais usando a lista suspensa no canto superior direito da imagem.',
        capitulos: const [
          Capitulo(id: 'c1', indice: 1, titulo: 'A Célula', capaUrl: null, rotaOuSlug: '/galeria/celula'),
          Capitulo(id: 'c2', indice: 2, titulo: 'Epitélio', capaUrl: null, rotaOuSlug: '/galeria/epitelio'),
          Capitulo(id: 'c3', indice: 3, titulo: 'Tecido Conjuntivo', capaUrl: null, rotaOuSlug: '/galeria/tecido-conjuntivo'),
        ],
      ),
      Topico(
        id: 't2',
        titulo: 'Sistemas Orgânicos',
        descricao:
            'Conjunto de lâminas organizadas por sistemas fisiológicos para estudo integrado e correlação clínica.',
        capitulos: const [
          Capitulo(id: 'c4', indice: 1, titulo: 'Músculo', rotaOuSlug: '/galeria/musculo'),
          Capitulo(id: 'c5', indice: 2, titulo: 'Cartilagem e Osso', rotaOuSlug: '/galeria/cartilagem-osso'),
        ],
      ),
    ]);
    notifyListeners();
  }

  // ---------------- CRUD Tópico ----------------
  void adicionarTopico(Topico t) {
    _topicos.add(t);
    notifyListeners();
  }

  void editarTopico(String id, Topico novo) {
    final i = _topicos.indexWhere((e) => e.id == id);
    if (i != -1) {
      _topicos[i] = novo;
      notifyListeners();
    }
  }

  void removerTopico(String id) {
    _topicos.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // ---------------- CRUD Capítulo ----------------
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

  // -------- Persistência local (opcional – ligada por chamada explícita) --------
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
