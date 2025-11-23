import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/usuario.dart';

class EstadoUsuario with ChangeNotifier {
  Usuario? _usuario;
  String? _token;
  bool _carregando = false;
  String? _erro;
  String _baseUrl = 'http://localhost:3000';

  // Chaves para shared_preferences
  static const String _keyToken = 'auth_token';
  static const String _keyUsuario = 'user_data';

  // Getters
  Usuario? get usuario => _usuario;
  String? get token => _token;
  bool get carregando => _carregando;
  String? get erro => _erro;
  bool get estaLogado => _usuario != null && _token != null;

  // Carregar dados salvos ao inicializar
  Future<void> carregarDadosSalvos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tokenSalvo = prefs.getString(_keyToken);
      final String? usuarioJson = prefs.getString(_keyUsuario);

      if (tokenSalvo != null && usuarioJson != null) {
        _token = tokenSalvo;
        final Map<String, dynamic> usuarioData = json.decode(usuarioJson);
        _usuario = Usuario.fromJson(usuarioData);
        
        print(' Sessão restaurada: ${_usuario?.email}');
        notifyListeners();
      }
    } catch (e) {
      print(' Erro ao carregar sessão: $e');
      await _limparDadosSalvos();
    }
  }

  // Salvar dados de login
  Future<void> _salvarDadosLogin(String token, Usuario usuario) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyToken, token);
      await prefs.setString(_keyUsuario, json.encode(usuario.toJson()));
      
      print(' Sessão salva: ${usuario.email}');
    } catch (e) {
      print(' Erro ao salvar sessão: $e');
    }
  }

  // Limpar dados de login (logout)
  Future<void> _limparDadosSalvos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyToken);
      await prefs.remove(_keyUsuario);
      
      print(' Sessão removida');
    } catch (e) {
      print(' Erro ao limpar sessão: $e');
    }
  }

  // Setters privados
  void _setCarregando(bool carregando) {
    _carregando = carregando;
    notifyListeners();
  }

  void _setErro(String? erro) {
    _erro = erro;
    notifyListeners();
  }

  // Método para verificar email 
  Future<bool> verificarEmail(String email) async {
    _setCarregando(true);
    _setErro(null);

    if (!email.endsWith('@fmabc.net')) {
      _setCarregando(false);
      _setErro("Apenas e-mails @fmabc.net são permitidos.");
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'), 
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'senha': 'senha_temporaria_qualquer',
        }),
      );

      print('=== DEBUG VERIFICAR EMAIL ===');
      print('Email testado: $email');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 401) {
        final data = json.decode(response.body);
        if (data['mensagem'] == "Senha inválida!") {
          print('--Email EXISTE - senha inválida');
          _setCarregando(false);
          return true;
        }
        if (data['mensagem'] == "Email inválido!") {
          print('-- Email NÃO existe');
          _setCarregando(false);
          _setErro("Email não cadastrado.");
          return false;
        }
      }

      if (response.statusCode == 200) {
        print('-- Email EXISTE - login bem sucedido');
        _setCarregando(false);
        return true;
      }

      print('-- Status code não esperado: ${response.statusCode}');
      _setCarregando(false);
      _setErro("Email não cadastrado.");
      return false;
    } catch (e) {
      print('=== ERRO VERIFICAR EMAIL ===');
      print('Erro: $e');
      print('URL tentada: $_baseUrl/login');
      _setCarregando(false);
      _setErro("Erro ao verificar email. Tente novamente.");
      return false;
    }
  }

  // Método para login
  Future<bool> login(String email, String senha) async {
    _setCarregando(true);
    _setErro(null);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'senha': senha}),
      );

      print('=== DEBUG LOGIN ===');
      print('Email: $email');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _processarLoginSucesso(data, email);
        
        // SALVAR DADOS PARA PERSISTÊNCIA
        await _salvarDadosLogin(data['token'], _usuario!);
        
        return true;
      } else if (response.statusCode == 401) {
        final data = json.decode(response.body);
        _setCarregando(false);
        _setErro(data['mensagem'] ?? "Credenciais inválidas.");
        return false;
      } else {
        _setCarregando(false);
        _setErro("Erro ao realizar login. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      _setCarregando(false);
      _setErro("Erro ao realizar login. Tente novamente.");
      return false;
    }
  }

  // Processa o sucesso do login
  Future<void> _processarLoginSucesso(
    Map<String, dynamic> data,
    String email,
  ) async {
    _token = data['token'];
    _usuario = Usuario(
      id: data['id'] ?? data['_id'],
      email: email,
      senha: '',
      tipo: data['cargo'] ?? 'subadmin',
    );
    _setCarregando(false);
  }

  // Cadastrar novo usuário
  Future<bool> cadastrar(String email, String senha, String tipo) async {
    _setCarregando(true);
    _setErro(null);

    try {
      if (!email.endsWith('@fmabc.net')) {
        throw Exception('Apenas e-mails @fmabc.net são permitidos.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/signup'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({
          'email': email,
          'senha': senha, 
          'cargo': tipo, 
        }),
      );

      if (response.statusCode == 201) {
        _setCarregando(false);
        return true;
      } else {
        final erroData = json.decode(response.body);
        throw Exception(
          erroData['message'] ?? erroData['error'] ?? 'Erro ao cadastrar',
        );
      }
    } catch (e) {
      _setCarregando(false);
      _setErro('Erro ao cadastrar: $e');
      return false;
    }
  }

  // LOGOUT ATUALIZADO
  Future<void> logout() async {
    _usuario = null;
    _token = null;
    _erro = null;
    await _limparDadosSalvos();
    notifyListeners();
    
    print('Usuário deslogado');
  }

  // Buscar lista de usuários
  Future<List<Usuario>> buscarUsuarios() async {
    _setCarregando(true);
    _setErro(null);

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/usuarios'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> usuariosJson = json.decode(response.body);
        List<Usuario> usuarios = usuariosJson
            .map((json) => Usuario.fromJson(json))
            .toList();
        _setCarregando(false);
        return usuarios;
      } else {
        throw Exception('Erro ao buscar usuários');
      }
    } catch (e) {
      _setCarregando(false);
      _setErro('Erro ao buscar usuários: $e');
      return [];
    }
  }

  // Buscar usuário por ID
  Future<Usuario?> buscarUsuarioPorId(String id) async {
    _setCarregando(true);
    _setErro(null);

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/usuario/$id'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        final usuarioJson = json.decode(response.body);
        final usuario = Usuario.fromJson(usuarioJson);
        _setCarregando(false);
        return usuario;
      } else {
        throw Exception('Usuário não encontrado');
      }
    } catch (e) {
      _setCarregando(false);
      _setErro('Erro ao buscar usuário: $e');
      return null;
    }
  }

  // Atualizar usuário
  Future<bool> atualizarUsuario(String id, Usuario usuarioAtualizado) async {
    _setCarregando(true);
    _setErro(null);

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/usuario/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(usuarioAtualizado.toJson()),
      );

      if (response.statusCode == 200) {
        if (_usuario?.id == id) {
          _usuario = usuarioAtualizado;
          //  ATUALIZAR DADOS SALVOS
          await _salvarDadosLogin(_token!, _usuario!);
        }
        _setCarregando(false);
        return true;
      } else {
        final erroData = json.decode(response.body);
        throw Exception(erroData['message'] ?? 'Erro ao atualizar usuário');
      }
    } catch (e) {
      _setCarregando(false);
      _setErro('Erro ao atualizar usuário: $e');
      return false;
    }
  }

  // Deletar usuário
  Future<bool> deletarUsuario(String id) async {
    _setCarregando(true);
    _setErro(null);

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/usuario/$id'),
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.statusCode == 200) {
        _setCarregando(false);
        return true;
      } else {
        final erroData = json.decode(response.body);
        throw Exception(erroData['message'] ?? 'Erro ao deletar usuário');
      }
    } catch (e) {
      _setCarregando(false);
      _setErro('Erro ao deletar usuário: $e');
      return false;
    }
  }

  // Limpar erros
  void limparErro() {
    _setErro(null);
  }

  // Verificar permissões baseadas no tipo
  bool temPermissao(String permissaoRequerida) {
    if (_usuario == null) return false;

    switch (_usuario!.tipo.toLowerCase()) {
      case 'admin':
        return true; // Admin tem todas as permissões
      case 'subadmin':
        return permissaoRequerida != 'admin'; // Subadmin não pode gerenciar admins
      default:
        return false;
    }
  }

  bool get isAdmin => _usuario?.tipo.toLowerCase() == 'admin';
  bool get isSubadmin => _usuario?.tipo.toLowerCase() == 'subadmin';

  bool podeGerenciarUsuarios() => isAdmin;
  bool podeCriarAdmin() => isAdmin;
  bool podeDeletarUsuario(Usuario outroUsuario) {
    if (!isAdmin) return false;
    // Admin pode deletar qualquer usuário
    return true;
  }

  bool podeEditarUsuario(Usuario outroUsuario) {
    if (!isAdmin) return false;
    // Admin pode editar qualquer usuário
    return true;
  }

  // Configurar URL base (caso precise mudar)
  void setBaseUrl(String url) {
    _baseUrl = url;
  }
}