class Usuario {
  String? id;
  String email;
  String senha;
  String tipo; // 'admin' ou 'subadmin'

  Usuario({
    this.id,
    required this.email,
    required this.senha,
    required this.tipo,
  });

  // Converte um Map em um objeto Usuario
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id'] ?? json['id'],
      email: json['email'],
      senha: json['senha'] ?? '',
      tipo: json['cargo'] ?? 'subadmin', // Lê 'cargo' do backend
    );
  }

  // Converte o objeto Usuario em um Map - CORRIGIDO
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'senha': senha,
      'cargo': tipo, // ← CORREÇÃO: Envia como 'cargo' para o backend
    };
  }

  // Para criar um usuário a partir do login - CORRIGIDO
  factory Usuario.fromLoginJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? json['_id'],
      email: json['email'] ?? '',
      senha: '',
      tipo: json['cargo'] ?? 'subadmin', // ← CORREÇÃO: usa apenas 'cargo'
    );
  }

  // Cópia do objeto com possíveis alterações
  Usuario copyWith({String? id, String? email, String? senha, String? tipo}) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  String toString() {
    return 'Usuario(id: $id, email: $email, tipo: $tipo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Usuario &&
        other.id == id &&
        other.email == email &&
        other.tipo == tipo;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ tipo.hashCode;
}

// Modelo para resposta de login
class LoginResponse {
  final String token;
  final String tipo;
  final String id;
  final Usuario usuario;

  LoginResponse({
    required this.token,
    required this.tipo,
    required this.id,
    required this.usuario,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      tipo: json['cargo'] ?? 'subadmin', // ← CORREÇÃO: usa 'cargo'
      id: json['id'] ?? json['_id'],
      usuario: Usuario.fromLoginJson(json),
    );
  }
}

// Modelo para requisição de login
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

// Modelo para requisição de cadastro
class SignupRequest {
  final String email;
  final String password;
  final String tipo;

  SignupRequest({
    required this.email,
    required this.password,
    required this.tipo,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password, 'cargo': tipo};
  }
}

// Constantes para tipos de usuário
class TiposUsuario {
  static const String admin = 'admin';
  static const String subadmin = 'subadmin';

  static List<String> get todos => [admin, subadmin];

  static String getDescricao(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'subadmin':
        return 'Subadministrador';
      default:
        return tipo;
    }
  }
}
