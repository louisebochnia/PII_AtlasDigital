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
    // Nomes dos dias para o eixo X
    final List<String> dias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

    // Encontrar o valor máximo para ajustar o eixo Y
    final double maxY = dailyData.isNotEmpty
        ? dailyData.reduce((a, b) => a > b ? a : b).ceilToDouble()
        : 10.0;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.surface,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Acessos nos Últimos 7 Dias",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          // Mostrar apenas valores inteiros
                          if (value == value.toInt()) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
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
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                dias[index],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
                    touchTooltipData: BarTouchTooltipData(
                      // CORREÇÃO: usar getTooltipColor em vez de tooltipBgColor
                      getTooltipColor: (group) => Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${dias[group.x.toInt()]}: ${rod.toY.toInt()} acessos',
                          const TextStyle(color: Colors.white, fontSize: 12),
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
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
