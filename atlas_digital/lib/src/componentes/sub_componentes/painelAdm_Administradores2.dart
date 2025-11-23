import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:atlas_digital/src/modelos/usuario.dart';
import 'package:atlas_digital/src/estado/estado_usuario.dart';

class AdministradoresPage extends StatefulWidget {
  const AdministradoresPage({super.key});

  @override
  State<AdministradoresPage> createState() => _AdministradoresPageState();
}

class _AdministradoresPageState extends State<AdministradoresPage> {
  List<Usuario> _administradores = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarAdministradores();
  }

  Future<void> _carregarAdministradores() async {
    final estadoUsuario = Provider.of<EstadoUsuario>(context, listen: false);

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final usuarios = await estadoUsuario.buscarUsuarios();
      setState(() {
        _administradores = usuarios
            .where(
              (usuario) =>
                  usuario.tipo == TiposUsuario.admin ||
                  usuario.tipo == TiposUsuario.subadmin,
            )
            .toList();
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = 'Erro ao carregar administradores: $e';
        _carregando = false;
      });
    }
  }

  void _abrirPopupAdministrador({Usuario? usuario}) {
    final isEditando = usuario != null;
    final emailController = TextEditingController(
      text: isEditando ? usuario.email : '',
    );
    final senhaController = TextEditingController();
    String? tipoSelecionado = isEditando ? usuario.tipo : TiposUsuario.subadmin;
    bool mostrarSenha = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                isEditando ? "Editar Administrador" : "Novo Administrador",
                style: const TextStyle(fontFamily: "Arial"),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      style: const TextStyle(fontFamily: "Arial"),
                      decoration: const InputDecoration(
                        labelText: "Email @fmabc.net",
                        border: OutlineInputBorder(),
                      ),
                      enabled: !isEditando,
                    ),
                    const SizedBox(height: 16),

                    if (!isEditando) ...[
                      TextField(
                        controller: senhaController,
                        obscureText: !mostrarSenha,
                        style: const TextStyle(fontFamily: "Arial"),
                        decoration: InputDecoration(
                          labelText: "Senha",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              mostrarSenha
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                mostrarSenha = !mostrarSenha;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text(
                      "Tipo de Administrador",
                      style: TextStyle(
                        fontFamily: "Arial",
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _TipoAdminCard(
                            tipo: TiposUsuario.admin,
                            titulo: 'Admin Geral',
                            descricao: 'Acesso completo',
                            selecionado: tipoSelecionado == TiposUsuario.admin,
                            onTap: () => setState(
                              () => tipoSelecionado = TiposUsuario.admin,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _TipoAdminCard(
                            tipo: TiposUsuario.subadmin,
                            titulo: 'Subadmin',
                            descricao: 'Acesso limitado',
                            selecionado:
                                tipoSelecionado == TiposUsuario.subadmin,
                            onTap: () => setState(
                              () => tipoSelecionado = TiposUsuario.subadmin,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(fontFamily: "Arial"),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final senha = senhaController.text.trim();

                    if (email.isEmpty || (!isEditando && senha.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Preencha todos os campos antes de salvar",
                            style: TextStyle(fontFamily: "Arial"),
                          ),
                        ),
                      );
                      return;
                    }

                    if (!email.endsWith('@fmabc.net')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Apenas emails @fmabc.net são permitidos",
                            style: TextStyle(fontFamily: "Arial"),
                          ),
                        ),
                      );
                      return;
                    }

                    final estadoUsuario = Provider.of<EstadoUsuario>(
                      context,
                      listen: false,
                    );

                    try {
                      if (isEditando) {
                        // Editar administrador existente
                        final usuarioAtualizado = usuario.copyWith(
                          email: email,
                          tipo: tipoSelecionado!,
                        );

                        final sucesso = await estadoUsuario.atualizarUsuario(
                          usuario.id!,
                          usuarioAtualizado,
                        );

                        if (sucesso) {
                          await _carregarAdministradores();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Administrador atualizado com sucesso!",
                                style: TextStyle(fontFamily: "Arial"),
                              ),
                            ),
                          );
                        }
                      } else {
                        // Criar novo administrador
                        final sucesso = await estadoUsuario.cadastrar(
                          email,
                          senha,
                          tipoSelecionado!,
                        );

                        if (sucesso) {
                          await _carregarAdministradores();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Novo administrador adicionado!",
                                style: TextStyle(fontFamily: "Arial"),
                              ),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Erro: $e",
                            style: const TextStyle(fontFamily: "Arial"),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Salvar",
                    style: TextStyle(fontFamily: "Arial"),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deletarAdministrador(Usuario usuario) async {
    final estadoUsuario = Provider.of<EstadoUsuario>(context, listen: false);

    // Não permitir que admin delete a si mesmo
    if (usuario.id == estadoUsuario.usuario?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Você não pode deletar sua própria conta",
            style: TextStyle(fontFamily: "Arial"),
          ),
        ),
      );
      return;
    }

    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Confirmar exclusão",
          style: TextStyle(fontFamily: "Arial"),
        ),
        content: Text(
          "Tem certeza que deseja deletar o administrador ${usuario.email}?",
          style: const TextStyle(fontFamily: "Arial"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Cancelar",
              style: TextStyle(fontFamily: "Arial"),
            ),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              bool isHovered = false;

              return MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red, 
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Deletar",
                    style: TextStyle(
                      fontFamily: "Arial",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        final sucesso = await estadoUsuario.deletarUsuario(usuario.id!);

        if (sucesso) {
          await _carregarAdministradores();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Administrador removido com sucesso",
                style: TextStyle(fontFamily: "Arial"),
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Erro ao deletar: $e",
              style: const TextStyle(fontFamily: "Arial"),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final estadoUsuario = Provider.of<EstadoUsuario>(context);

    // Verificar se o usuário atual é admin
    if (!estadoUsuario.isAdmin) {
      return const Center(
        child: Text(
          "Acesso restrito a administradores",
          style: TextStyle(fontFamily: "Arial", fontSize: 18),
        ),
      );
    }

    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _erro!,
              style: const TextStyle(fontFamily: "Arial", color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarAdministradores,
              child: const Text(
                "Tentar Novamente",
                style: TextStyle(fontFamily: "Arial"),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Administradores',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: "Arial",
          ),
        ),
        const SizedBox(height: 20),

        // Botão novo administrador - apenas Admin Geral pode criar outros admins
        if (estadoUsuario.isAdmin)
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () => _abrirPopupAdministrador(),
              icon: const Icon(Icons.add),
              label: const Text(
                "Novo Administrador",
                style: TextStyle(fontFamily: "Arial"),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),

        Expanded(
          child: ListView.builder(
            itemCount: _administradores.length,
            itemBuilder: (context, index) {
              final admin = _administradores[index];
              final isUsuarioAtual = admin.id == estadoUsuario.usuario?.id;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 243, 242, 242),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Ícone do tipo
                    Icon(
                      admin.tipo == TiposUsuario.admin
                          ? Icons.admin_panel_settings
                          : Icons.verified_user,
                      color: admin.tipo == TiposUsuario.admin
                          ? Colors.blue
                          : Colors.green,
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            admin.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFamily: "Arial",
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            admin.tipo == TiposUsuario.admin
                                ? 'Admin Geral'
                                : 'Subadmin',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: "Arial",
                            ),
                          ),
                          if (isUsuarioAtual)
                            Text(
                              'Você',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[700],
                                fontFamily: "Arial",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Botões de ação
                    if (!isUsuarioAtual && estadoUsuario.isAdmin)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.black87),
                            onPressed: () =>
                                _abrirPopupAdministrador(usuario: admin),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletarAdministrador(admin),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Widget para os cards de seleção de tipo
class _TipoAdminCard extends StatelessWidget {
  final String tipo;
  final String titulo;
  final String descricao;
  final bool selecionado;
  final VoidCallback onTap;

  const _TipoAdminCard({
    required this.tipo,
    required this.titulo,
    required this.descricao,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selecionado ? Colors.green.withOpacity(0.1) : Colors.grey[100],
          border: Border.all(
            color: selecionado ? Colors.green : Colors.grey[300]!,
            width: selecionado ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selecionado ? Colors.green : Colors.black,
                fontFamily: 'Arial',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              descricao,
              style: TextStyle(
                fontSize: 10,
                color: selecionado ? Colors.green : Colors.grey[600],
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
