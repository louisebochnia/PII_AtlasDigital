import 'package:flutter/material.dart'; 

class EstadoNavegacao with ChangeNotifier {
  int _indiceAtual = 0;
  Widget? _paginaEspecial;
  
  int get indiceAtual => _indiceAtual;
  Widget? get paginaEspecial => _paginaEspecial;
  
  void mudarIndice(int index) {
    _indiceAtual = index;
    _paginaEspecial = null; 
    notifyListeners();
  }
  
  void definirPaginaEspecial(Widget pagina) {
    _paginaEspecial = pagina;
    notifyListeners();
  }
  
  void voltarParaNavegacaoNormal() {
    _paginaEspecial = null;
    notifyListeners();
  }
}