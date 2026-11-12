import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../modelos/tile.dart';

class EstadoVisualizadorMRXS with ChangeNotifier {

  final String imagemId;
  final String tilesBaseUrl;

  // Estados
  bool _carregando = true;
  String? _erro;
  double _zoom = 1.0;
  double _minZoom = 0.8;
  double _maxZoom = 10.0;
  Offset _posicao = Offset.zero;
  List<TileLayer> _layers = [];
  bool _primeiroCarregamento = true;

  // Controle de zoom
  double _zoomBase = 1.0;
  Offset _pontoFocal = Offset.zero;
  Size _viewportSize = Size.zero; 

  EstadoVisualizadorMRXS({
    required this.imagemId,
    required this.tilesBaseUrl,
  }) {
    _initialize();
  }

  void _initialize() {
    _carregando = true;
    _erro = null;
    _zoom = 1.0;
    _minZoom = 0.8;
    _maxZoom = 8.0;
    _posicao = Offset.zero;
    _layers = [];
    _zoomBase = 1.0;
    _pontoFocal = Offset.zero;
    _viewportSize = Size.zero;
    _primeiroCarregamento = true;
  }

  // Getters
  bool get carregando => _carregando;
  String? get erro => _erro;
  double get zoom => _zoom;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;
  Offset get posicao => _posicao;
  
  Size get tamanhoImagem {
    if (_layers.isEmpty) return Size.zero;
    try {
      final baseLayer = _layers.firstWhere((layer) => layer.scale == 1.0, orElse: () => _layers.first);
      return Size(baseLayer.width.toDouble(), baseLayer.height.toDouble());
    } catch (e) {
      return Size.zero;
    }
  }

  List<TileLayer> get layers => List.unmodifiable(_layers);

  Future<bool> carregarMetadados() async {
    try {
      _carregando = true;
      _erro = null;
      _safeNotifyListeners();

      await _carregarMetadadosDaAPI();
      
      _carregando = false;
      _safeNotifyListeners();
      return true;

    } catch (e) {
      _carregando = false;
      _erro = 'Erro ao carregar metadados: ${e.toString()}';
      _safeNotifyListeners();
      return false;
    }
  }

  void _safeNotifyListeners() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  Future<void> _carregarMetadadosDaAPI() async {
    final urlCompleta = '$tilesBaseUrl/$imagemId/meta.json';
    print('--- FLUTTER: Tentando buscar metadados em: $urlCompleta');

    final response = await http.get(Uri.parse(urlCompleta));
    
    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar metadados (Código ${response.statusCode})');
    }

    final data = json.decode(response.body);
    
    _layers = [];
    for (final levelData in data['level_metas'].entries) {
      final level = int.parse(levelData.key);
      final meta = levelData.value;
      
      final double downsample = (meta['downsample'] as num).toDouble();
      
      _layers.add(TileLayer(
        level: level,
        width: meta['width'],
        height: meta['height'],
        tileSize: 256,
        scale: downsample,
      ));
    }
    
    // Ordena do nível 0 (mais detalhado) para o mais afastado
    _layers.sort((a, b) => a.scale.compareTo(b.scale));

    // O nível mais afastado (maior downsample, ex: 512) define o menor zoom possível
    final double maiorDownsample = _layers.last.scale;

    // Definimos os limites:
    // minZoom: visão geral da lâmina inteira (ex: 1 / 512)
    // maxZoom: 1.0 (exatamente 100% do pixel real da imagem, que corresponde ao nível 0)
    _minZoom = 1.0 / maiorDownsample;
    _maxZoom = 1.0; 
    
    // Começa na visão geral
    _zoom = _minZoom;
  }
  
  void iniciarZoom(Offset pontoFocal) {
    _zoomBase = _zoom;
    _pontoFocal = pontoFocal;
  }

  void atualizarZoomPinch(double scale, Offset pontoFocal) {
    final novoZoom = (_zoomBase * scale).clamp(_minZoom, _maxZoom);
    
    if (novoZoom != _zoom) {
      final zoomBase = _zoom; 
      _zoom = novoZoom;
      
      final fatorZoom = _zoom / zoomBase;
      
      final newDx = ((pontoFocal.dx + _posicao.dx) * fatorZoom) - pontoFocal.dx;
      final newDy = ((pontoFocal.dy + _posicao.dy) * fatorZoom) - pontoFocal.dy;
      
      _posicao = Offset(newDx, newDy);
      _posicao = _limitarPosicao(_posicao);
      
      _safeNotifyListeners();
    }
  }

  void finalizarZoom() {
    _zoomBase = _zoom;
  }

  void arrastar(Offset delta) {
    _posicao -= delta;
    _posicao = _limitarPosicao(_posicao);
    _safeNotifyListeners();
  }

  void aplicarZoomIn() {
    final novoZoom = min(_maxZoom, _zoom * 2.0);
    _definirZoomDiscreto(novoZoom, Offset(_viewportSize.width / 2, _viewportSize.height / 2));
  }

  void aplicarZoomOut() {
    final novoZoom = max(_minZoom, _zoom / 2.0);
    _definirZoomDiscreto(novoZoom, Offset(_viewportSize.width / 2, _viewportSize.height / 2));
  }

  void definirZoom(double novoZoom) {
    final pontoCentral = Offset(_viewportSize.width / 2, _viewportSize.height / 2);
    _definirZoomDiscreto(novoZoom, pontoCentral);
  }

  void _definirZoomDiscreto(double novoZoom, Offset pontoFocal) {
    if (novoZoom == _zoom) return;
    
    final zoomBase = _zoom; 
    _zoom = novoZoom.clamp(_minZoom, _maxZoom);
    
    final fatorZoom = _zoom / zoomBase; 
    
    final newDx = ((pontoFocal.dx + _posicao.dx) * fatorZoom) - pontoFocal.dx;
    final newDy = ((pontoFocal.dy + _posicao.dy) * fatorZoom) - pontoFocal.dy;
    
    _posicao = Offset(newDx, newDy);
    _posicao = _limitarPosicao(_posicao);

    _safeNotifyListeners();
  }

  void resetarVisualizacao() {
    _zoom = 1.0;
    _posicao = Offset.zero;
    _primeiroCarregamento = false; 
    centralizarImagem(_viewportSize);
    _safeNotifyListeners();
  }
  
  void centralizarVisualizacaoInicialmente() {
    if (_layers.isNotEmpty && _viewportSize != Size.zero && _primeiroCarregamento) {
      centralizarImagem(_viewportSize);
      _primeiroCarregamento = false;
    }
  }
  
  void centralizarImagem(Size viewportSize) {
    if (_layers.isEmpty || viewportSize.isEmpty) return;
    
    final baseLayer = _layers.firstWhere((layer) => layer.scale == 1.0, orElse: () => _layers.first);
    final baseWidth = baseLayer.width.toDouble();
    final baseHeight = baseLayer.height.toDouble();
    
    final scaledWidth = baseWidth * _zoom;
    final scaledHeight = baseHeight * _zoom;
    
    final newDx = (scaledWidth - viewportSize.width) / 2;
    final newDy = (scaledHeight - viewportSize.height) / 2;
    
    _posicao = Offset(newDx, newDy);
    
    _safeNotifyListeners();
  }

  void atualizarViewportSize(Size newSize) {
    _viewportSize = newSize;
    if (!_primeiroCarregamento) {
        _posicao = _limitarPosicao(_posicao);
    }
  }

  Offset _limitarPosicao(Offset posicao) {
    if (_layers.isEmpty || _viewportSize.isEmpty) return Offset.zero;

    final baseLayer = _layers.firstWhere((layer) => layer.scale == 1.0, orElse: () => _layers.first);
    
    final scaledWidth = baseLayer.width.toDouble() * _zoom;
    final scaledHeight = baseLayer.height.toDouble() * _zoom;
    
    final diffWidth = scaledWidth - _viewportSize.width;
    final diffHeight = scaledHeight - _viewportSize.height;

    double finalMinX, finalMaxX;
    double finalMinY, finalMaxY;
    
    if (diffWidth > 0) {
        finalMinX = 0.0;
        finalMaxX = diffWidth;
    } else {
        final halfDiffX = diffWidth / 2.0;
        finalMinX = halfDiffX; 
        finalMaxX = -halfDiffX;
    }
    
    if (diffHeight > 0) {
        finalMinY = 0.0;
        finalMaxY = diffHeight;
    } else {
        final halfDiffY = diffHeight / 2.0;
        finalMinY = halfDiffY;
        finalMaxY = -halfDiffY;
    }

    final double clampedX = posicao.dx.clamp(min(finalMinX, finalMaxX), max(finalMinX, finalMaxX));
    final double clampedY = posicao.dy.clamp(min(finalMinY, finalMaxY), max(finalMinY, finalMaxY));
    
    return Offset(clampedX, clampedY);
  }

  List<TileInfo> obterTilesVisiveis(Size viewportSize) {
    if (_layers.isEmpty) return [];

    final layer = _obterLayerAtual();
    final tileSize = layer.tileSize.toDouble();
    
    final displayTileSize = tileSize;

    final startCol = (_posicao.dx / displayTileSize).floor();
    final startRow = (_posicao.dy / displayTileSize).floor();
    
    final endCol = ((_posicao.dx + viewportSize.width) / displayTileSize).ceil();
    final endRow = ((_posicao.dy + viewportSize.height) / displayTileSize).ceil();

    final maxCols = (layer.width / tileSize).ceil();
    final maxRows = (layer.height / tileSize).ceil();

    final tiles = <TileInfo>[];

    for (var col = startCol; col < endCol; col++) {
      for (var row = startRow; row < endRow; row++) {
        
        final bool isTileValid = col >= 0 && row >= 0 && col < maxCols && row < maxRows;
        
        final String? tileUrl;
        if (isTileValid) {
          // Alinhado com a rota do Node.js: app.get('/tiles/:imageId/:level/:x/:y')
          tileUrl = '$tilesBaseUrl/tiles/$imagemId/${layer.level}/$col/$row.jpg';
        } else {
          tileUrl = null;
        }
        
        tiles.add(TileInfo(
          level: layer.level,
          x: col,
          y: row,
          url: tileUrl,
        ));
      }
    }
    return tiles;
  }

TileLayer _obterLayerAtual() {
    if (_layers.isEmpty) {
      return TileLayer(level: 0, width: 256, height: 256, tileSize: 256, scale: 1.0);
    }
    
    if (_layerAtualCache != null) {
      final fatorAtual = 1.0 / _layerAtualCache!.scale;
      if ((_zoom - fatorAtual).abs() < fatorAtual * 0.4) {
        return _layerAtualCache!;
      }
    }

    TileLayer layerEscolhida = _layers.first;
    double menorDiferenca = double.infinity;

    for (final layer in _layers) {
      final fatorZoomLayer = 1.0 / layer.scale;
      final diferenca = (_zoom - fatorZoomLayer).abs();
      if (diferenca < menorDiferenca) {
        menorDiferenca = diferenca;
        layerEscolhida = layer;
      }
    }
    
    _layerAtualCache = layerEscolhida;
    return layerEscolhida;
  }
  
  TileLayer? _layerAtualCache;
  
  double obterEscalaPython(int level) {
    try {
      final layer = _layers.firstWhere(
        (l) => l.level == level,
        orElse: () => _layers.first,
      );
      return layer.scale;
    } catch (e) {
      return 1.0;
    }
  }

  void irParaPrimeiroTile() {
    _zoom = 1.0;
    _posicao = Offset.zero;
    _primeiroCarregamento = false; 
    _safeNotifyListeners();
  }

  Offset _pointerPosicaoImagem = Offset.zero;
  bool _pointerVisivel = false;
  bool _modoColocacaoPointer = false;

  Offset get pointerPosicaoImagem => _pointerPosicaoImagem;
  bool get pointerVisivel => _pointerVisivel;
  bool get modoColocacaoPointer => _modoColocacaoPointer;

  void ativarModoColocacaoPointer() {
    _modoColocacaoPointer = true;
    _pointerVisivel = true;
    notifyListeners();
  }

  void desativarModoColocacaoPointer() {
    _modoColocacaoPointer = false;
    notifyListeners();
  }

  void colocarPointerNaImagem(Offset posicao) {
    _pointerPosicaoImagem = posicao;
    _modoColocacaoPointer = false;
    notifyListeners();
  }

  void moverPointerNaImagem(Offset novaPosicao) {
    _pointerPosicaoImagem = novaPosicao;
    notifyListeners();
  }

  void alternarPointerVisibilidade() {
    _pointerVisivel = !_pointerVisivel;
    notifyListeners();
  }

  void resetarPointer() {
    _pointerPosicaoImagem = Offset.zero;
    _pointerVisivel = false;
    _modoColocacaoPointer = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _layers.clear();
    super.dispose();
  }
}