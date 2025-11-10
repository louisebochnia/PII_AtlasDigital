import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:atlas_digital/temas.dart';
import 'package:atlas_digital/src/estado/estado_estatisticas.dart';
import 'package:atlas_digital/config/servicos/servico_estatisticas.dart';

class EstatisticasPage extends StatefulWidget {
  const EstatisticasPage({super.key});

  @override
  State<EstatisticasPage> createState() => _EstatisticasPageState();
}

class _EstatisticasPageState extends State<EstatisticasPage> {
  @override
  void initState() {
    super.initState();
    _carregarEstatisticas();
  }

  void _carregarEstatisticas() {
    final estadoEstatisticas = Provider.of<EstadoEstatisticas>(
      context,
      listen: false,
    );
    estadoEstatisticas.carregarEstatisticas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estatísticas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarEstatisticas,
          ),
        ],
      ),
      body: Consumer<EstadoEstatisticas>(
        builder: (context, estadoEstatisticas, child) {
          if (estadoEstatisticas.carregando) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandGreen),
            );
          }

          if (estadoEstatisticas.erro != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Erro ao carregar estatísticas: ${estadoEstatisticas.erro}",
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _carregarEstatisticas,
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          if (estadoEstatisticas.estatisticas == null) {
            return const Center(child: Text("Nenhum dado encontrado."));
          }

          final estatisticas = estadoEstatisticas.estatisticas!;
          final int totalAcessos = estatisticas['totalAcessos'] ?? 0;
          final List<double> dailyData =
              ServicoEstatisticas.prepararDadosUltimos7Dias(
                estatisticas['acessosPorDia'] ?? {},
              );

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTotalAcessosCard(totalAcessos),
              const SizedBox(height: 24),
              _buildAcessosChart(dailyData),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalAcessosCard(int totalAcessos) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total de Acessos",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Text(
              totalAcessos.toString(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcessosChart(List<double> dailyData) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    //fica estranho, mas mudei pra apagar o retangulo
    final bool isVerySmallScreen = screenWidth < 800 || screenHeight < 800;
    final bool isSmallScreen = screenWidth < 400;
    final bool isMediumScreen = screenWidth < 600;

    final List<String> dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final double maxY = dailyData.isNotEmpty
        ? dailyData.reduce((a, b) => a > b ? a : b).ceilToDouble()
        : 10.0;

    final List<double> yAxisValues = _calculateYAxisValues(maxY);

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
        height: isSmallScreen ? 220 : (isMediumScreen ? 260 : 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Acessos nos Últimos 7 Dias",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textMuted,
                fontSize: isSmallScreen ? 14 : (isMediumScreen ? 16 : 18),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final barWidth = _calculateBarWidth(
                    availableWidth,
                    isSmallScreen,
                  );

                  return BarChart(
                    BarChartData(
                      minY: 0,
                      maxY: maxY,
                      alignment: BarChartAlignment.spaceAround,
                      gridData: FlGridData(
                        show: !isVerySmallScreen,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      borderData: FlBorderData(
                        show: !isVerySmallScreen,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: isVerySmallScreen
                                ? 25
                                : (isSmallScreen ? 30 : 40),
                            interval:
                                1,
                            getTitlesWidget: (value, meta) {
                              if (yAxisValues.contains(value)) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Text(
                                    value.toInt().toString(),
                                    style: TextStyle(
                                      fontSize: isVerySmallScreen
                                          ? 9
                                          : (isSmallScreen ? 10 : 12),
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < dias.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    dias[index],
                                    style: TextStyle(
                                      fontSize: isVerySmallScreen
                                          ? 9
                                          : (isSmallScreen ? 10 : 12),
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        enabled:
                            screenWidth >
                            1000, // Só ativa em telas muito grandes
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.black87,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.toInt()} acessos',
                              TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            );
                          },
                        ),
                      ),
                      barGroups: dailyData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value,
                              color: AppColors.brandGreen,
                              width: barWidth,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                          showingTooltipIndicators: screenWidth > 1000
                              ? [0]
                              : [],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FUNÇÃO CALCULAR EIXO Y DINAMICAMENTE --------------------------------------------------------------------
  List<double> _calculateYAxisValues(double maxY) {
    final List<double> values = [];

    if (maxY <= 5) {
      // Para valores muito pequenos
      for (double i = 0; i <= maxY; i += 1) {
        values.add(i);
      }
    } else if (maxY <= 10) {
      // Para valores pequenos
      for (double i = 0; i <= maxY; i += 2) {
        values.add(i);
      }
    } else if (maxY <= 20) {
      // Para valores médios
      for (double i = 0; i <= maxY; i += 5) {
        values.add(i);
      }
    } else if (maxY <= 50) {
      // Para valores maiores
      for (double i = 0; i <= maxY; i += 10) {
        values.add(i);
      }
    } else {
      // Para valores muito grandes
      for (double i = 0; i <= maxY; i += 25) {
        values.add(i);
      }
    }

    // Garante que o valor máximo sempre apareça
    if (values.isEmpty || values.last < maxY) {
      values.add(maxY);
    }

    return values;
  }

  double _calculateBarWidth(double availableWidth, bool isSmallScreen) {
    final double baseWidth = availableWidth / 7;
    final double minWidth = isSmallScreen ? 6 : 8;
    final double maxWidth = isSmallScreen ? 12 : 20;
    final double calculatedWidth = baseWidth * 0.7;

    return calculatedWidth.clamp(minWidth, maxWidth);
  }
}
