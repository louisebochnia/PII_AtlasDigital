import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_visualizador.dart';
import '../modelos/tile.dart';

class VisualizadorImagem extends StatefulWidget {
  final String imagemId;
  final String tilesBaseUrl;

  const VisualizadorImagem({
    Key? key,
    required this.imagemId,
    required this.tilesBaseUrl
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VisualidorImagemState();
}

class _VisualidorImagemState extends State<VisualizadorImagem> {
  late EstadoVisualizadorMRXS _estadoVisualizador;

  @override
  void initState() {
    super.initState();
    _estadoVisualizador = EstadoVisualizadorMRXS(
      imagemId: widget.imagemId, 
      tilesBaseUrl: widget.tilesBaseUrl
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final sucesso = await _estadoVisualizador.carregarMetadados();
      if (sucesso) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            _estadoVisualizador.centralizarVisualizacaoInicialmente();
        });
      }
    });
  }

  @override 
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _estadoVisualizador,
      child: Container(
        color: Colors.black, // Fundo preto do widget principal
        child: Consumer<EstadoVisualizadorMRXS>(
          builder: (context, estado, child) {
            if(estado.carregando) {
              return _buildLoadingState();
            }

            if(estado.erro != null) {
              return _buildErrorState(estado);
            }

            return _buildVisualizador(estado);
          },
        )
      )
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white)),
          SizedBox(height: 16),
          Text(
            'Carregando imagem...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(EstadoVisualizadorMRXS estado) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Não foi possível carregar a imagem',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              estado.erro!,
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: estado.carregarMetadados,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualizador(EstadoVisualizadorMRXS estado) {
    return Stack(
      children: [
        _buildAreaVisualizacao(estado),
        _buildOverlayControls(estado),
        _buildAnotacoes(estado),
      ],
    );
  }

  Widget _buildAreaVisualizacao(EstadoVisualizadorMRXS estado) {
    return GestureDetector(
      onScaleStart: (details) {
        estado.iniciarZoom(details.localFocalPoint);
      },
      onScaleUpdate: (details) {
        if (details.pointerCount > 1 || details.scale != 1.0) {
          final scale = details.scale;
          estado.atualizarZoomPinch(scale, details.localFocalPoint);
        } else if (details.pointerCount == 1 && details.scale == 1.0) {
          estado.arrastar(details.focalPointDelta);
        }
      },
      onScaleEnd: (details) {
        estado.finalizarZoom();
      },
      onDoubleTap: () {
        estado.aplicarZoomIn();
      },
      child: Container(
        color: Colors.white, // Fundo branco para a área de tiles
        child: _buildTiles(estado),
      ),
    );
  }

  Widget _buildTiles(EstadoVisualizadorMRXS estado) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        estado.atualizarViewportSize(viewportSize); 
        
        final tiles = estado.obterTilesVisiveis(viewportSize);

        return Stack(
          children: tiles.map((tile) => _buildTileWidget(tile, estado)).toList(),
        );
      },
    );
  }

  Widget _buildTileWidget(TileInfo tile, EstadoVisualizadorMRXS estado) {
    final layer = estado.layers.firstWhere(
      (l) => l.level == tile.level,
      orElse: () => estado.layers.first,
    );
    
    final tileSize = 256.0;
    
    final left = tile.x * tileSize - estado.posicao.dx;
    final top = tile.y * tileSize - estado.posicao.dy;

    return Positioned(
      left: left,
      top: top,
      child: SizedBox(
        width: tileSize,
        height: tileSize,
        child: _buildTileContent(tile),
      ),
    );
  }

  Widget _buildTileContent(TileInfo tile) {
    if (tile.url == null) {
      return Container(
        color: Colors.white, // Cor sólida em vez de gradiente
      );
    }

    return Image.network(
      tile.url!,
      fit: BoxFit.cover,

      filterQuality: FilterQuality.high,
      
      isAntiAlias: true,
      
      cacheHeight: 256,
      cacheWidth: 256,
      
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return Container(
          color: Colors.white,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 1.5, // Mais fino
              valueColor: AlwaysStoppedAnimation(Colors.black26),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.white,
          child: Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.black26,
              size: 32,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlayControls(EstadoVisualizadorMRXS estado) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        child: Column(
          children: [
            _buildZoomControl(estado),
            
            SizedBox(height: 16),
                      
            if (estado.zoom == 1.0) _buildInstrucoes(),
          ],
        )
      ),
    );
  }

  Widget _buildZoomControl(EstadoVisualizadorMRXS estado) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zoom: ${(estado.zoom * 100).round()}%',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (estado.zoom - estado.minZoom) / (estado.maxZoom - estado.minZoom),
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              _buildQuickActions(estado),
            ],
          ),
          SizedBox(height: 12),
          Slider(
            value: estado.zoom,
            min: estado.minZoom,
            max: estado.maxZoom,
            onChanged: estado.definirZoom,
            divisions: 11,
            label: '${(estado.zoom * 100).round()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildAnotacoes(EstadoVisualizadorMRXS estado) {
    return Positioned(
      top: 20,
      bottom: 20,
      right: 20,
      child: Container(
        width: 400,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text("Anotações"),
            
            SizedBox(height: 16),

            SizedBox(height: 8),
            
          ],
        )
      ),
    );
  }


  Widget _buildQuickActions(EstadoVisualizadorMRXS estado) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.zoom_out, color: Colors.white),
          onPressed: estado.zoom > estado.minZoom ? estado.aplicarZoomOut : null,
        ),
        IconButton(
          icon: Icon(Icons.zoom_in, color: Colors.white),
          onPressed: estado.zoom < estado.maxZoom ? estado.aplicarZoomIn : null,
        ),
        IconButton(
          icon: Icon(Icons.center_focus_strong, color: Colors.white),
          onPressed: estado.resetarVisualizacao,
        ),
      ],
    );
  }

  Widget _buildInstrucoes() {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 500),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'Como navegar:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInstrucaoItem(Icons.touch_app, 'Duplo toque', 'Ampliar'),
                _buildInstrucaoItem(Icons.pinch, 'Pinch', 'Zoom contínuo'),
                _buildInstrucaoItem(Icons.pan_tool, 'Arraste', 'Navegar'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstrucaoItem(IconData icon, String titulo, String descricao) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 4),
        Text(
          titulo,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        Text(
          descricao,
          style: TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  FilterQuality _getFilterQualityForLevel(int level) {
    if (level <= -4) { // 400% ou mais
      return FilterQuality.high;
    } else if (level <= -2) { // 200% a 399%
      return FilterQuality.medium;
    } else {
      return FilterQuality.low;
    }
  }

  @override
  void dispose() {
    _estadoVisualizador.dispose();
    super.dispose();
  }
}