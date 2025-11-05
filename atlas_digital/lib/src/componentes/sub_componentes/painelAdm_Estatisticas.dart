import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:atlas_digital/temas.dart';

class EstatisticasPage extends StatefulWidget {
  const EstatisticasPage({super.key});

  @override
  State<EstatisticasPage> createState() => _EstatisticasPageState();
}

class _EstatisticasPageState extends State<EstatisticasPage> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStatistics();
  }

  Future<Map<String, dynamic>> _fetchStatistics() async {
    await Future.delayed(const Duration(seconds: 2));

    return {
      'totalUsers': 1482,
      'dailyUsage': [150.0, 210.0, 180.0, 250.0, 220.0, 300.0, 190.0],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estatísticas"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.brandGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erro ao carregar estatísticas: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData) {
            final int totalUsers = snapshot.data!['totalUsers'];
            final List<double> dailyData =
                List<double>.from(snapshot.data!['dailyUsage']);

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildTotalUsersCard(totalUsers),
                const SizedBox(height: 24),
                _buildUsersChart(dailyData),
              ],
            );
          }

          return const Center(child: Text("Nenhum dado encontrado."));
        },
      ),
    );
  }

  Widget _buildTotalUsersCard(int userCount) {
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
              "Total de Usuários",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              userCount.toString(),
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

  Widget _buildUsersChart(List<double> dailyData) {
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
              "Usuários nos Últimos 7 Dias",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: _getBottomTitles,
                        reservedSize: 22,
                      ),
                    ),
                  ),
                  barGroups: dailyData.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: AppColors.brandGreen,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
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

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: AppColors.textMuted, fontSize: 12);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'D 1';
        break;
      case 1:
        text = 'D 2';
        break;
      case 2:
        text = 'D 3';
        break;
      case 3:
        text = 'D 4';
        break;
      case 4:
        text = 'D 5';
        break;
      case 5:
        text = 'D 6';
        break;
      case 6:
        text = 'D 7';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
  }
}