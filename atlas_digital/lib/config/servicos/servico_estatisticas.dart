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

  // Helper para dados dos últimos 7 dias (opcional)
  static List<double> prepararDadosUltimos7Dias(
    Map<String, dynamic> acessosPorDia,
  ) {
    final List<double> dailyData = List.filled(7, 0.0);
    final hoje = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final data = DateTime(hoje.year, hoje.month, hoje.day - (6 - i));
      final dataStr = _formatarData(data);
      final acessos = acessosPorDia[dataStr] ?? 0;
      dailyData[i] = (acessos is int)
          ? acessos.toDouble()
          : (acessos as num).toDouble();
    }

    return dailyData;
  }

  static String _formatarData(DateTime data) {
    return '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
  }
}
