import 'package:atlas_digital/app_shell.dart';
import 'package:atlas_digital/src/componentes/sub_componentes/painelAdm_Administradores2.dart';
import 'package:atlas_digital/src/componentes/sub_componentes/painelAdm_Estatisticas.dart';
import 'package:atlas_digital/src/componentes/sub_componentes/painelAdm_Inicio2.dart';
import 'package:atlas_digital/src/componentes/sub_componentes/painelAdm_Conteudo.dart';
import 'package:atlas_digital/src/componentes/sub_componentes/painelAdm_Galeria.dart';
import 'package:atlas_digital/temas.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../estado/estado_usuario.dart'; 

// Classe para gerenciar o estado do upload globalmente
class UploadState with ChangeNotifier {
  bool _mostrarPopupProgresso = false;
  double _progressoUpload = 0.0;
  bool _uploadCancelado = false;
  Function? _onCancelarUpload;

  bool get mostrarPopupProgresso => _mostrarPopupProgresso;
  double get progressoUpload => _progressoUpload;
  bool get uploadCancelado => _uploadCancelado;

  void iniciarUpload(Function onCancelar) {
    _mostrarPopupProgresso = true;
    _progressoUpload = 0.0;
    _uploadCancelado = false;
    _onCancelarUpload = onCancelar;
    notifyListeners();
  }

  void atualizarProgresso(double progresso) {
    _progressoUpload = progresso;
    notifyListeners();
  }

  void cancelarUpload() {
    _uploadCancelado = true;
    _mostrarPopupProgresso = false;
    if (_onCancelarUpload != null) {
      _onCancelarUpload!();
    }
    notifyListeners();
  }

  void finalizarUpload() {
    _mostrarPopupProgresso = false;
    _progressoUpload = 0.0;
    _onCancelarUpload = null;
    notifyListeners();
  }
}

class PainelAdm extends StatefulWidget {
  const PainelAdm({super.key});

  @override
  State<PainelAdm> createState() => _PainelAdmState();
}

class _PainelAdmState extends State<PainelAdm> {
  int _selectedIndex = 0;
  final UploadState _uploadState = UploadState();

  final List<String> _menuLabels = [
    "Início",
    "Conteúdo",
    "Galeria",
    "Administradores",
    "Estatísticas",
  ];

  final List<IconData> _menuIcons = [
    Icons.home,
    Icons.content_paste_outlined,
    Icons.image_outlined,
    Icons.people_alt_outlined,
    Icons.auto_graph_rounded,
  ];

  //  FUNÇÃO DE LOGOUT
  Future<void> _fazerLogout(BuildContext context) async {
    final estadoUsuario = Provider.of<EstadoUsuario>(context, listen: false);
    await estadoUsuario.logout();
    
    // Voltar para o AppShell (site normal)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _uploadState,
      child: Scaffold(
        appBar: AppBar( //  APP BAR ADICIONADO COM LOGOUT
          backgroundColor: AppColors.brandGreen,
          foregroundColor: Colors.white,
          title: const Text(
            'Painel Administrativo',
            style: TextStyle(
              fontFamily: "Arial",
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<EstadoUsuario>(
              builder: (context, estadoUsuario, child) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.account_circle, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _fazerLogout(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'info',
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.green),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                estadoUsuario.usuario?.email ?? 'Usuário',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Arial",
                                ),
                              ),
                              Text(
                                estadoUsuario.usuario?.tipo == 'admin' 
                                    ? 'Admin Geral' 
                                    : 'Subadmin',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontFamily: "Arial",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: const [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Sair',
                            style: TextStyle(
                              fontFamily: "Arial",
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              child: Row(
                children: [
                  // MENU LATERAL
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: const Color.fromARGB(255, 214, 206, 206),
                            width: 4,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (int i = 0; i < _menuLabels.length; i++) ...[
                            _menuButton(_menuIcons[i], _menuLabels[i], i),
                            const SizedBox(height: 12),
                          ],
                          const Spacer(),
                          _exitButton(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // CONTEÚDO PRINCIPAL COM ANIMAÇÃO
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey(_selectedIndex),
                          child: _buildMenuContent(_selectedIndex),
                        ),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // POPUP GLOBAL DE PROGRESSO DO UPLOAD
            Consumer<UploadState>(
              builder: (context, uploadState, child) {
                if (!uploadState.mostrarPopupProgresso) return const SizedBox();

                return Stack(
                  children: [
                    // Fundo semi-transparente que bloqueia interação
                    ModalBarrier(
                      color: Colors.black.withOpacity(0.5),
                      dismissible: false,
                    ),

                    // Diálogo de progresso
                    Center(
                      child: AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text(
                          "Enviando Imagem",
                          style: TextStyle(fontFamily: "Arial"),
                          textAlign: TextAlign.center,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Fazendo upload da imagem...",
                              style: TextStyle(fontFamily: "Arial"),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            LinearProgressIndicator(
                              value: uploadState.progressoUpload / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                              minHeight: 12,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${uploadState.progressoUpload.toStringAsFixed(1)}%",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Arial",
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Aguarde enquanto o arquivo é enviado",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontFamily: "Arial",
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              uploadState.cancelarUpload();
                            },
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(
                                color: Colors.red,
                                fontFamily: "Arial",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContent(int index) {
    switch (index) {
      case 0:
        return InicioPage();
      case 1:
        return ConteudoPage();
      case 2:
        return GaleriaPage(uploadState: _uploadState);
      case 3:
        return AdministradoresPage();
      case 4:
        return EstatisticasPage();
      default:
        return InicioPage();
    }
  }

  Widget _menuButton(IconData icon, String label, int index) {
    bool isSelected = index == _selectedIndex;

    return TextButton(
      onPressed: () {
        if (!mounted) return;
        setState(() {
          _selectedIndex = index;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? AppColors.brandGreen : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSelected
              ? const BorderSide(color: AppColors.brandGreen, width: 3)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.green),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.green,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                fontFamily: "Arial",
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _exitButton() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AppShell()),
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 220, 20, 20),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        children: const [
          Icon(Icons.exit_to_app, color: Colors.white, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Voltar para o site",
              style: TextStyle(
                fontSize: 15,
                fontFamily: "Arial",
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}