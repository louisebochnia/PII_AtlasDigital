// servico_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modelos/topico.dart';
import '../modelos/subtopicos.dart';

class ServicoApi {
  static const String baseUrl = 'http://sua-api-url.com/api';

  Future<List<Topico>> getTopicos() async {
    final response = await http.get(Uri.parse('$baseUrl/topicos'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Topico.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar tópicos');
    }
  }

  Future<List<Subtopico>> getSubtopicosPorTopico(String topicoId) async {
    final response = await http.get(Uri.parse('$baseUrl/subtopicos?topicoId=$topicoId'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Subtopico.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar subtópicos');
    }
  }
}