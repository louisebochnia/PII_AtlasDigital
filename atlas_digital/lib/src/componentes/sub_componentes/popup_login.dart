import 'package:atlas_digital/src/componentes/painelAdm.dart';
import 'package:atlas_digital/temas.dart';
import 'package:flutter/material.dart';

class LoginPopup extends StatefulWidget {
  const LoginPopup({super.key});

  @override
  State<LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<LoginPopup> {
  Map<String, String?> usuarios = {
    "adm@exemplo.com": "123456",
    "teste@exemplo.com": null,
  };

  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool etapaEmail = true;
  String? emailSelecionado;
  String? mensagemErro;
  bool lembrarSenha = false;

  void verificarEmail() {
    String email = emailController.text.trim();

    if (usuarios.containsKey(email)) {
      setState(() {
        emailSelecionado = email;
        etapaEmail = false;
        mensagemErro = null;
      });
    } else {
      setState(() {
        mensagemErro = "Email não cadastrado.";
      });
    }
  }

  void verificarOuCadastrarSenha() {
    String senha = senhaController.text.trim();

    if (senha.isEmpty) {
      setState(() {
        mensagemErro = "Digite uma senha válida.";
      });
      return;
    }

    if (usuarios[emailSelecionado] == null) {
      usuarios[emailSelecionado!] = senha;
      setState(() {
        mensagemErro = "Senha cadastrada com sucesso!";
      });
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PainelAdm()),
        );
      });
    } else {
      if (usuarios[emailSelecionado] == senha) {
        setState(() {
          mensagemErro = "Login realizado com sucesso!";
        });
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PainelAdm()),
          );
        });
      } else {
        setState(() {
          mensagemErro = "Senha incorreta.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Texto de instrução dinâmico
    String textoInstrucao;
    if (etapaEmail) {
      textoInstrucao = "Coloque seu e-mail para entrar na sua conta";
    } else {
      if (usuarios[emailSelecionado] == null) {
        textoInstrucao = "Primeiro acesso! Cadastre sua senha";
      } else {
        textoInstrucao = "Digite sua senha para continuar";
      }
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: 350,
        height: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            const Text(
              "Login",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Arial',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Texto de instrução
            Flexible(
              child: Text(
                textoInstrucao,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontFamily: 'Arial',
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(height: 20),

            // Campo email ou senha
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etapaEmail ? "Email" : "Senha",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: etapaEmail ? emailController : senhaController,
                  obscureText: !etapaEmail,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    hintText:
                        etapaEmail ? "Digite seu email" : "Digite sua senha",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'Arial',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Checkbox "Lembrar senha" (apenas na tela de senha)
            if (!etapaEmail)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: lembrarSenha,
                        onChanged: (val) {
                          setState(() {
                            lembrarSenha = val ?? false;
                          });
                        },
                      ),
                      const Text(
                        "Lembrar a senha",
                        style: TextStyle(fontFamily: 'Arial'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Ao clicar em Entrar, você aceita automaticamente nossos termos & condições",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.black,
                        fontFamily: 'Arial'),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            // Mensagem de erro ou sucesso
            if (mensagemErro != null)
              Text(
                mensagemErro!,
                style: TextStyle(
                  color: mensagemErro!.contains("sucesso")
                      ? Colors.green
                      : Colors.red,
                  fontFamily: 'Arial',
                ),
              ),

            const SizedBox(height: 15),

            // Botões expansíveis
            Row(
              children: [
                if (!etapaEmail)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          etapaEmail = true;
                          emailSelecionado = null;
                          mensagemErro = null;
                          senhaController.clear();
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Voltar",
                        style: TextStyle(fontFamily: 'Arial'),
                      ),
                    ),
                  ),
                if (!etapaEmail) const SizedBox(width: 28),
                Expanded(
                  child: TextButton(
                    onPressed: etapaEmail
                        ? verificarEmail
                        : verificarOuCadastrarSenha,
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      etapaEmail ? "Próximo" : "Entrar",
                      style: const TextStyle(fontFamily: 'Arial'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Indicador de etapas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: etapaEmail ? AppColors.brandGreen : Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: etapaEmail
                        ? const Color.fromARGB(255, 124, 124, 124)
                        : Colors.green,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
