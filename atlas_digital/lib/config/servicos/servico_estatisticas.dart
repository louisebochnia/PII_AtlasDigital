import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:atlas_digital/config/api_config.dart';

class ServicoEstatisticas {
  static const String _baseUrl = ApiConfig.baseUrl;

  //Registrar visita
  static Future<bool> registrarVisita({String? userId, String? pagina}) async {
    try {
      final url = '$_baseUrl/estatisticas/visita';
      // print('FLUTTER: Tentando conectar em: $url'); -- debug, se der ruim posso usar

      final bodyData = {
        'dataAcesso': DateTime.now().toIso8601String(),
        'userId': userId,
        'pagina': pagina ?? 'site_geral',
      };

      // print('FLUTTER: Enviando dados: $bodyData'); -- debug, se der ruim posso usar

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(bodyData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final sucesso = data['success'] == true;

        if (sucesso) {
          print('FLUTTER: Visita registrada COM SUCESSO!');
          // print('FLUTTER: Total de acessos: ${data['totalAcessos']}');
          return true;
        } else {
          // print('FLUTTER: API retornou success: false');
          return false;
        }
      } else {
        print('FLUTTER: Erro HTTP: ${response.statusCode}');
        // print('FLUTTER: Response: ${response.body}');
        return false;
      }
    } catch (e) {
      // print('FLUTTER: Erro de conexão: $e');
      // print('FLUTTER: Tipo do erro: ${e.runtimeType}');
      return false;
    }
  }

  // Buscar estatísticas (se ainda quiser)
  static Future<Map<String, dynamic>> buscarEstatisticas() async {
    try {
      final url = '$_baseUrl/estatisticas';
      // print('Buscando estatísticas em: $url'); -- debug, se der ruim posso usar

      final response = await http.get(Uri.parse(url));

      // print('Status code: ${response.statusCode}'); -- debug, se der ruim posso usar
      // print('Response body: ${response.body}'); -- debug, se der ruim posso usar

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print('Estatísticas recebidas - Total: ${data['totalAcessos']}');
          // print('Estrutura completa: ${data.keys}'); -- debug, se der ruim posso usar
          return data;
        } else {
          throw Exception('Erro na API: ${data['error']}');
        }
      } else {
        throw Exception('Falha ao carregar: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar estatísticas: $e');
      throw e;
    }
  }

  // Helper para dados dos últimos 7 dias
  static List<double> prepararDadosUltimos7Dias(
    Map<String, dynamic> acessosPorDia,
  ) {
    final List<double> dailyData = [];
    final DateTime agora = DateTime.now();
    final DateTime hoje = DateTime(agora.year, agora.month, agora.day);

    for (int i = 6; i >= 0; i--) {
      final DateTime data = hoje.subtract(Duration(days: i));
      final String dataStr = _formatarData(data);
      final dynamic acessos = acessosPorDia[dataStr] ?? 0;

      dailyData.add(
        (acessos is int) ? acessos.toDouble() : (acessos as num).toDouble(),
      );

      final bool ehHoje = data.day == hoje.day;
      print(
        '${6 - i + 1}. $dataStr = ${dailyData.last} ${ehHoje ? "← HOJE" : ""}',
      );
    }
    
    return dailyData;
  }

  static String _formatarData(DateTime data) {
    return '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  }
}
