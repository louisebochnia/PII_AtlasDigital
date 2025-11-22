import 'package:atlas_digital/src/telas/painelAdm.dart';
import 'package:atlas_digital/temas.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPopup extends StatefulWidget {
  const LoginPopup({super.key});

  @override
  State<LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<LoginPopup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();

  bool etapaEmail = true;
  String? emailSelecionado;
  String? mensagemErro;
  bool lembrarSenha = false;
  bool isLoading = false;
  
  String baseUrl = 'http://localhost:3000';  // URL do seu backend

  Future<void> verificarEmail() async {
    setState(() {
      isLoading = true;
      mensagemErro = null;
    });

    String email = emailController.text.trim();

    if (!email.endsWith('@fmabc.net')) {
      setState(() {
        mensagemErro = "Apenas e-mails @fmabc.net são permitidos.";
        isLoading = false;
      });
      return;
    }

    try {
      // Tenta verificar se é um admin
      final adminResponse = await http.post(
        Uri.parse('$baseUrl/api/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': 'dummy'}),
      );

      if (adminResponse.statusCode != 404) {
        setState(() {
          emailSelecionado = email;
          etapaEmail = false;
          isLoading = false;
        });
        return;
      }

      // Se não for admin, tenta verificar se é subadmin
      final subadminResponse = await http.post(
        Uri.parse('$baseUrl/api/subadmin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': 'dummy'}),
      );

      if (subadminResponse.statusCode != 404) {
        setState(() {
          emailSelecionado = email;
          etapaEmail = false;
          isLoading = false;
        });
        return;
      }

      setState(() {
        mensagemErro = "Email não cadastrado.";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        mensagemErro = "Erro ao verificar email. Tente novamente.";
        isLoading = false;
      });
    }
  }

  Future<void> verificarOuCadastrarSenha() async {
    setState(() {
      isLoading = true;
      mensagemErro = null;
    });

    String email = emailSelecionado!;
    String senha = senhaController.text.trim();

    if (senha.isEmpty) {
      setState(() {
        mensagemErro = "Digite uma senha válida.";
        isLoading = false;
      });
      return;
    }

    try {
      // Tenta login como admin
      var response = await http.post(
        Uri.parse('$baseUrl/api/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': senha}),
      );

      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          mensagemErro = "Login realizado com sucesso!";
          isLoading = false;
        });
        
        // Salva o token se "lembrar senha" estiver marcado
        if (lembrarSenha) {
          // TODO: Implementar armazenamento seguro do token
        }

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PainelAdm()),
          );
        });
        return;
      }

      // Se não for admin, tenta como subadmin
      response = await http.post(
        Uri.parse('$baseUrl/api/subadmin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': senha}),
      );

      data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          mensagemErro = "Login realizado com sucesso!";
          isLoading = false;
        });
        
        if (lembrarSenha) {
          // TODO: Implementar armazenamento seguro do token
        }

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PainelAdm()),
          );
        });
        return;
      }

      setState(() {
        mensagemErro = "Senha incorreta.";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        mensagemErro = "Erro ao realizar login. Tente novamente.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Texto de instrução dinâmico
    String textoInstrucao;
    if (etapaEmail) {
      textoInstrucao = "Coloque seu e-mail para entrar na sua conta";
    } else {
      textoInstrucao = "Digite sua senha para continuar";
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
