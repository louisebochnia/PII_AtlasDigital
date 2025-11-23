import 'package:flutter/foundation.dart';
import 'package:atlas_digital/config/servicos/servico_estatisticas.dart';

class EstadoEstatisticas with ChangeNotifier {
  Map<String, dynamic>? _estatisticas;
  bool _carregando = false;
  String? _erro;
  bool _disposed = false;

  Map<String, dynamic>? get estatisticas => _estatisticas;
  bool get carregando => _carregando;
  String? get erro => _erro;

  // Registrar visita
  Future<void> registrarVisita({String? userId, String? pagina}) async {
    try {
      print(' [REGISTRO] Iniciando registro de visita...');
      print(' [REGISTRO] User: $userId, Página: $pagina');

      final sucesso = await ServicoEstatisticas.registrarVisita(
        userId: userId,
        pagina: pagina,
      );

      if (sucesso) {
        print(' [REGISTRO] Visita registrada COM SUCESSO!');

        await Future.delayed(const Duration(milliseconds: 800));
        await carregarEstatisticas();

        print(' [REGISTRO] Estatísticas atualizadas após visita');
      } else {
        print(' [REGISTRO] Falha ao registrar visita');
        _erro = 'Falha ao registrar visita no servidor';
        _scheduleNotifyListeners();
      }
    } catch (error) {
      print(' [REGISTRO] Erro: $error');
      _erro = 'Erro ao registrar visita: $error';
      _scheduleNotifyListeners();
    }
  }

  //Carregar estatísticas
  Future<void> carregarEstatisticas() async {
    _carregando = true;
    _erro = null;
    _scheduleNotifyListeners();

    try {
      print(' [ESTADO] Buscando estatísticas atualizadas...');
      _estatisticas = await ServicoEstatisticas.buscarEstatisticas();
      _erro = null;

      // DEBUG DETALHADO
      print(' [ESTADO] Estatísticas carregadas!');
      print(' [ESTADO] Total de acessos: ${_estatisticas?['totalAcessos']}');

      final acessosPorDia = _estatisticas?['acessosPorDia'] ?? {};
      print(' [ESTADO] Dias com dados: ${acessosPorDia.length}');
      print(' [ESTADO] Estrutura acessosPorDia: $acessosPorDia');

      // Verifica se tem dados de HOJE
      final DateTime agora = DateTime.now();
      final String hojeStr =
          '${agora.year}-${agora.month.toString().padLeft(2, '0')}-${agora.day.toString().padLeft(2, '0')}';
      print(
        ' [ESTADO] Tem dados de hoje ($hojeStr)? ${acessosPorDia.containsKey(hojeStr)}',
      );
    } catch (e) {
      _erro = 'Erro ao carregar estatísticas: $e';
      print(' [ESTADO] Erro ao carregar estatísticas: $e');
    } finally {
      _carregando = false;
      _scheduleNotifyListeners();
    }
  }

  // Evitar conflito de notificação durante build
  void _scheduleNotifyListeners() {
    if (!_disposed) {
      Future.microtask(() {
        if (!_disposed) {
          notifyListeners();
        }
      });
    }
  }

   @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  

  void limparErro() {
    _erro = null;
    _scheduleNotifyListeners();
  }
}


