import 'package:atlas_digital/app_shell.dart';
import 'package:atlas_digital/temas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_visualizador.dart';
import '../estado/estado_imagem.dart';
import '../modelos/imagem.dart';
import '../modelos/tile.dart';
import '../telas/pagina_galeria.dart';

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
  final String protocolo = 'http://';
  final String baseURL = 'localhost:3000';

  late EstadoVisualizadorMRXS _estadoVisualizador;
  late EstadoImagem _estadoImagem;
  late Imagem? imagem;

  final Map<String, Widget> _tileCache = {};
  final Map<String, TileInfo> _currentTiles = {};

  @override
  void initState() {
    super.initState();
    _estadoVisualizador = EstadoVisualizadorMRXS(
      imagemId: widget.imagemId, 
      tilesBaseUrl: widget.tilesBaseUrl
    );

    _estadoImagem = context.read<EstadoImagem>();

    imagem = _estadoImagem.encontrarPorId(widget.imagemId);
    
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
        color: Colors.black, 
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 768;

        return Stack(
          children: [
            _buildAreaVisualizacao(estado),
            _buildOverlayControls(estado, isSmallScreen),
            if (!isSmallScreen) 
              _buildAnotacoesDesktop(estado),
            if (isSmallScreen)
              _buildAnotacoesMobile(estado),
          ],
        );
      },
    );
  }

  Widget _buildOverlayControls(EstadoVisualizadorMRXS estado, bool isSmallScreen) {
    if (isSmallScreen) {
      return Positioned(
        top: 20,
        left: 20,
        right: 20,
        child: _buildZoomControlMobile(estado),
      );
    } else {
      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Column(
          children: [
            _buildZoomControl(estado),
            SizedBox(height: 16),
            if (estado.zoom == 1.0) _buildInstrucoes(),
          ],
        ),
      );
    }
  }

  Widget _buildZoomControlMobile(EstadoVisualizadorMRXS estado) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandGray90.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Zoom: ${(estado.zoom * 100).round()}%',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              _buildQuickActionsCompact(estado),
            ],
          ),
          SizedBox(height: 8),
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

  Widget _buildQuickActionsCompact(EstadoVisualizadorMRXS estado) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.zoom_out, color: Colors.white, size: 20),
          onPressed: estado.zoom > estado.minZoom ? estado.aplicarZoomOut : null,
          padding: EdgeInsets.all(4),
        ),
        IconButton(
          icon: Icon(Icons.center_focus_strong, color: Colors.white, size: 20),
          onPressed: estado.resetarVisualizacao,
          padding: EdgeInsets.all(4),
        ),
        IconButton(
          icon: Icon(Icons.zoom_in, color: Colors.white, size: 20),
          onPressed: estado.zoom < estado.maxZoom ? estado.aplicarZoomIn : null,
          padding: EdgeInsets.all(4),
        ),
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
        color: Colors.white,
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

        _updateTileCache(tiles, estado);

        return Stack(
          children: _buildCachedTiles(estado),
        );
      },
    );
  }

  void _updateTileCache(List<TileInfo> newTiles, EstadoVisualizadorMRXS estado) {
    final newTileMap = <String, TileInfo>{};
    
    for (final tile in newTiles) {
      final key = _getTileKey(tile);
      newTileMap[key] = tile;
    }

    final keysToRemove = <String>[];
    for (final key in _currentTiles.keys) {
      if (!newTileMap.containsKey(key)) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      _currentTiles.remove(key);
    }

    _currentTiles.addAll(newTileMap);
  }

  List<Widget> _buildCachedTiles(EstadoVisualizadorMRXS estado) {
    final widgets = <Widget>[];
    
    for (final tile in _currentTiles.values) {
      final key = _getTileKey(tile);
      
      if (_tileCache.containsKey(key)) {
        widgets.add(_buildCachedTileWidget(tile, estado, _tileCache[key]!));
      } else {
        final widget = _buildTileContent(tile);
        _tileCache[key] = widget;
        widgets.add(_buildCachedTileWidget(tile, estado, widget));
      }
    }
    
    return widgets;
  }

  Widget _buildCachedTileWidget(TileInfo tile, EstadoVisualizadorMRXS estado, Widget cachedWidget) {
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
        child: cachedWidget,
      ),
    );
  }

  String _getTileKey(TileInfo tile) {
    return '${tile.level}_${tile.x}_${tile.y}';
  }

  Widget _buildTileContent(TileInfo tile) {
    if (tile.url == null) {
      return Container(
        color: Colors.white, 
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
              strokeWidth: 1.5, 
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

  Widget _buildZoomControl(EstadoVisualizadorMRXS estado) {
    return Container(
      width: 400,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandGray90.withOpacity(0.8),
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

  Widget _buildAnotacoesDesktop(EstadoVisualizadorMRXS estado) {
    return Positioned(
      top: 20,
      bottom: 20,
      right: 20,
      child: _ContainerRedimensionavel(
        larguraInicial: 400,
        larguraMinima: 250,
        larguraMaxima: 500,
        child: _buildConteudoAnotacoes(estado),
      ),
    );
  }

  Widget _buildAnotacoesMobile(EstadoVisualizadorMRXS estado) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4, 
        ),
        child: _buildConteudoAnotacoes(estado),
      ),
    );
  }

  Widget _buildConteudoAnotacoes(EstadoVisualizadorMRXS estado) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 75,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.brandGreen,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.5),
                  child: Image.network(
                    converterParaUrl(imagem!.enderecoThumbnail),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      imagem!.nomeImagem,
                      style: const TextStyle(
                        fontFamily: "Arial",
                        fontSize: 26,
                        fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    Text(
                      '${imagem!.topico} • ${imagem!.subtopico}',
                      style: const TextStyle(
                        fontFamily: "Arial",
                        color: AppColors.textMuted
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(
            color: AppColors.brandGray90,
            height: 12,
            thickness: 0.5,
          ),
          SizedBox(height: 10),
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              thickness: 3,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Anotações",
                      style: const TextStyle(
                        fontFamily: "Arial",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      imagem!.anotacao,
                      style: const TextStyle(
                        fontFamily: "Arial",
                        fontSize: 16,
                      )
                    ),
                    SizedBox(height: 12),
                    // Text(
                    //   "Hiperlinks",
                    //   style: const TextStyle(
                    //     fontFamily: "Arial",
                    //     fontSize: 22,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // SizedBox(height: 8),
                    // Text(
                    //   "Lorem ipsum dolor sit amet, consectetur adipiscing elit...",
                    //   style: const TextStyle(
                    //     fontFamily: "Arial",
                    //     fontSize: 16,
                    //   )
                    // ),
                  ],
                )
              ),
            ),
          ),
          SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AppShell()),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 220, 20, 20),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.exit_to_app, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Voltar para o site",
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: "Arial",
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        ],
      )
    );
  }

  Widget _buildInstrucoes() {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: Duration(milliseconds: 500),
      child: Container(
        width: 400,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.brandGray90.withOpacity(0.8),
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
    if (level <= -4) { 
      return FilterQuality.high;
    } else if (level <= -2) { 
      return FilterQuality.medium;
    } else {
      return FilterQuality.low;
    }
  }

  String converterParaUrl(String caminhoRelativo) {
    if (caminhoRelativo.isEmpty) return '';

    final caminhoNormalizado = caminhoRelativo.replaceAll('\\', '/');
    return '$protocolo$baseURL/$caminhoNormalizado';
  }

  @override
  void dispose() {
    _estadoVisualizador.dispose();
    _tileCache.clear();
    _currentTiles.clear();
    super.dispose();
  }
}

class _ContainerRedimensionavel extends StatefulWidget {
  final Widget child;
  final double larguraInicial;
  final double larguraMinima;
  final double larguraMaxima;

  const _ContainerRedimensionavel({
    required this.child,
    required this.larguraInicial,
    this.larguraMinima = 200,
    this.larguraMaxima = 600,
  });

  @override
  _ContainerRedimensionavelState createState() => _ContainerRedimensionavelState();
}

class _ContainerRedimensionavelState extends State<_ContainerRedimensionavel> {
  double _largura = 400;
  bool _estaArrastando = false;

  @override
  void initState() {
    super.initState();
    _largura = widget.larguraInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: _largura,
          child: widget.child,
        ),
        
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeLeftRight,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details) {
                setState(() {
                  _estaArrastando = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _largura -= details.delta.dx;
                  if (_largura < widget.larguraMinima) {
                    _largura = widget.larguraMinima;
                  } else if (_largura > widget.larguraMaxima) {
                    _largura = widget.larguraMaxima;
                  }
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _estaArrastando = false;
                });
              },
              child: Container(
                width: 8,
                color: _estaArrastando 
                  ? AppColors.brandGreen.withOpacity(0.5)
                  : Colors.transparent,
                child: Center(
                  child: Container(
                    width: 2,
                    height: 40,
                    color: AppColors.brandGreen,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}