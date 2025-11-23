import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../modelos/tile.dart';

class EstadoVisualizadorMRXS with ChangeNotifier {
  final String imagemId;
  final String tilesBaseUrl;

  // Estados
  bool _carregando = true;
  String? _erro;
  double _zoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 10.0;
  Offset _posicao = Offset.zero;
  List<TileLayer> _layers = [];

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
    _minZoom = 1.0;
    _maxZoom = 10.0;
    _posicao = Offset.zero;
    _layers = [];
    _zoomBase = 1.0;
    _pontoFocal = Offset.zero;
    _viewportSize = Size.zero;
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
      final baseLayer = _layers.firstWhere((layer) => layer.level == 0);
      return Size(baseLayer.width.toDouble(), baseLayer.height.toDouble());
    } catch (e) {
      return Size.zero;
    }
  }

  List<TileLayer> get layers => List.unmodifiable(_layers);

  Future<void> carregarMetadados() async {
    try {
      _carregando = true;
      _erro = null;
      _safeNotifyListeners();

      await _carregarMetadados();
      
      _carregando = false;
      _safeNotifyListeners();

    } catch (e) {
      _carregando = false;
      _erro = 'Erro ao carregar metadados: ${e.toString()}';
      _safeNotifyListeners();
    }
  }

  // Método seguro para notificar listeners
  void _safeNotifyListeners() {
    if (hasListeners) {
      notifyListeners();
    }
  }

  Future<void> _carregarMetadados() async {
    try {
      // Simulação de carregamento
      await Future.delayed(Duration(milliseconds: 500));
      
      _layers = [
        TileLayer(
          level: 0,
          width: 10000,
          height: 8000,
          tileSize: 256,
          scale: 1.0,
        ),
        TileLayer(
          level: 1,
          width: 5000,
          height: 4000,
          tileSize: 256,
          scale: 2.0,
        ),
        TileLayer(
          level: 2,
          width: 2500,
          height: 2000,
          tileSize: 256,
          scale: 4.0,
        ),
        TileLayer(
          level: 3,
          width: 1250,
          height: 1000,
          tileSize: 256,
          scale: 8.0,
        ),
      ];

      // Configura zoom máximo baseado na layer com maior scale
      _maxZoom = _layers.map((layer) => layer.scale).reduce(max);

    } catch (e) {
      throw Exception('Falha ao carregar metadados da API: ${e.toString()}');
    }
  }

  // Métodos de zoom e navegação
  void iniciarZoom(Offset pontoFocal) {
    _zoomBase = _zoom;
    _pontoFocal = pontoFocal;
  }

  void atualizarZoomPinch(double scale, Offset pontoFocal) {
    final novoZoom = (_zoomBase * scale).clamp(_minZoom, _maxZoom);
    
    if (novoZoom != _zoom) {
      _zoom = novoZoom;
      
      // Ajusta a posição baseada no ponto focal
      final fatorZoom = _zoom / _zoomBase;
      final dx = (pontoFocal.dx - _posicao.dx) * (1 - fatorZoom);
      final dy = (pontoFocal.dy - _posicao.dy) * (1 - fatorZoom);
      
      _posicao += Offset(dx, dy);
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
    _definirZoomComAnimacao(novoZoom);
  }

  void aplicarZoomOut() {
    final novoZoom = max(_minZoom, _zoom / 2.0);
    _definirZoomComAnimacao(novoZoom);
  }

  void definirZoom(double novoZoom) {
    _zoom = novoZoom.clamp(_minZoom, _maxZoom);
    _posicao = _limitarPosicao(_posicao);
    _safeNotifyListeners();
  }

  void _definirZoomComAnimacao(double novoZoom) {
    _zoom = novoZoom.clamp(_minZoom, _maxZoom);
    _posicao = _limitarPosicao(_posicao);
    _safeNotifyListeners();
  }

  void resetarVisualizacao() {
    _zoom = 1.0;
    _posicao = Offset.zero;
    _safeNotifyListeners();
  }

  void atualizarViewportSize(Size newSize) {
    _viewportSize = newSize;
    _posicao = _limitarPosicao(_posicao);
  }

  Offset _limitarPosicao(Offset posicao) {
    if (_layers.isEmpty || _viewportSize.isEmpty) return Offset.zero;

    final layer = _obterLayerAtual();
    final scaledWidth = layer.width / layer.scale;
    final scaledHeight = layer.height / layer.scale;
    
    final maxX = max(0.0, scaledWidth - _viewportSize.width);
    final maxY = max(0.0, scaledHeight - _viewportSize.height);

    return Offset(
      posicao.dx.clamp(0.0, maxX),
      posicao.dy.clamp(0.0, maxY),
    );
  }

  // Métodos para tiles
  List<TileInfo> obterTilesVisiveis(Size viewportSize) {
    if (_layers.isEmpty) return [];

    final layer = _obterLayerAtual();
    final tileSize = layer.tileSize.toDouble();
    final scalePython = layer.scale;

    // Tamanho escalado do tile na tela
    final scaledTileSize = tileSize / scalePython;

    // Calcula quais tiles estão visíveis no viewport
    final startCol = (_posicao.dx / scaledTileSize).floor();
    final startRow = (_posicao.dy / scaledTileSize).floor();
    
    final endCol = ((_posicao.dx + viewportSize.width) / scaledTileSize).ceil();
    final endRow = ((_posicao.dy + viewportSize.height) / scaledTileSize).ceil();

    final tiles = <TileInfo>[];

    for (var col = startCol; col < endCol; col++) {
      for (var row = startRow; row < endRow; row++) {
        // Verifica se o tile está dentro dos limites da layer
        if (_isTileValid(layer, col, row)) {
          final tileUrl = '$tilesBaseUrl/$imagemId/${layer.level}/$col/$row.jpg';
          
          tiles.add(TileInfo(
            level: layer.level,
            x: col,
            y: row,
            url: tileUrl,
          ));
        }
      }
    }

    return tiles;
  }

  bool _isTileValid(TileLayer layer, int col, int row) {
    if (col < 0 || row < 0) return false;
    
    final maxCol = (layer.width / layer.tileSize).ceil();
    final maxRow = (layer.height / layer.tileSize).ceil();
    
    return col < maxCol && row < maxRow;
  }

  TileLayer _obterLayerAtual() {
    if (_layers.isEmpty) {
      return TileLayer(
        level: 0,
        width: 256,
        height: 256,
        tileSize: 256,
        scale: 1.0,
      );
    }

    // Encontra a layer mais apropriada para o zoom atual
    TileLayer layerEscolhida = _layers.first;
    
    for (final layer in _layers) {
      if (_zoom >= layer.scale) {
        layerEscolhida = layer;
      } else {
        break;
      }
    }
    
    return layerEscolhida;
  }

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

  // Métodos para debug e informações
  Map<String, dynamic> toDebugMap() {
    return {
      'carregando': _carregando,
      'erro': _erro,
      'zoom': _zoom,
      'posicao': {'dx': _posicao.dx, 'dy': _posicao.dy},
      'layers_count': _layers.length,
      'viewport_size': {'width': _viewportSize.width, 'height': _viewportSize.height},
      'tamanho_imagem': {'width': tamanhoImagem.width, 'height': tamanhoImagem.height},
    };
  }

  String get debugInfo {
    final layer = _obterLayerAtual();
    return '''
Estado Visualizador:
- Carregando: $_carregando
- Zoom: ${_zoom.toStringAsFixed(2)}x
- Posição: (${_posicao.dx.toStringAsFixed(1)}, ${_posicao.dy.toStringAsFixed(1)})
- Layer Atual: ${layer.level} (scale: ${layer.scale})
- Tiles Layers: ${_layers.length}
- Viewport: ${_viewportSize.width.toStringAsFixed(0)}x${_viewportSize.height.toStringAsFixed(0)}
- Imagem: ${tamanhoImagem.width.toStringAsFixed(0)}x${tamanhoImagem.height.toStringAsFixed(0)}
''';
  }

  @override
  void dispose() {
    _layers.clear();
    super.dispose();
  }
}