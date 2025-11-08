import 'package:flutter/foundation.dart';
import 'package:atlas_digital/config/servicos/servico_estatisticas.dart';

class EstadoEstatisticas with ChangeNotifier {
  Map<String, dynamic>? _estatisticas;
  bool _carregando = false;
  String? _erro;

  Map<String, dynamic>? get estatisticas => _estatisticas;
  bool get carregando => _carregando;
  String? get erro => _erro;

  // Registrar visita
  Future<void> registrarVisita({String? userId, String? pagina}) async {
    try {
      print('--Iniciando registro de visita...');
      
      final sucesso = await ServicoEstatisticas.registrarVisita(
        userId: userId, 
        pagina: pagina
      );
      
      if (sucesso) {
        print(' Visita registrada no servidor, aguardando para atualizar...');
        
        //Aguardar um pouco e depois atualizar
        await Future.delayed(const Duration(milliseconds: 800));
        
        // Recarregar estatísticas atualizadas
        await carregarEstatisticas();
        
        print('Estatísticas atualizadas após visita');
      } else {
        _erro = 'Falha ao registrar visita no servidor';
        _scheduleNotifyListeners();
      }
    } catch (error) {
      _erro = 'Erro ao registrar visita: $error';
      print('Erro ao registrar visita: $error');
      _scheduleNotifyListeners();
    }
  }

  //Carregar estatísticas
  Future<void> carregarEstatisticas() async {
    _carregando = true;
    _erro = null;
    _scheduleNotifyListeners();

    try {
      print('Buscando estatísticas atualizadas...');
      _estatisticas = await ServicoEstatisticas.buscarEstatisticas();
      _erro = null;
      print('Estatísticas carregadas: ${_estatisticas?['totalAcessos']} acessos');
    } catch (e) {
      _erro = 'Erro ao carregar estatísticas: $e';
      print('Erro ao carregar estatísticas: $e');
    } finally {
      _carregando = false;
      _scheduleNotifyListeners();
    }
  }

  // Evitar conflito de notificação durante build
  void _scheduleNotifyListeners() {
    Future.microtask(() => notifyListeners());
  }

  void limparErro() {
    _erro = null;
    _scheduleNotifyListeners();
  }
}