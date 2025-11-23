import 'package:atlas_digital/temas.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:atlas_digital/src/estado/estado_usuario.dart';

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
  String baseUrl = 'http://localhost:3000';
  bool mostrarSenha = false;

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
      debugPrint('-- Verificando email: $email');

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'senha': 'senha_temporaria'}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('-- Resposta da API: ${response.statusCode}');
      debugPrint('-- Corpo da resposta: ${response.body}');

      if (response.statusCode == 401) {
        final data = json.decode(response.body);
        if (data['mensagem'] == "Senha inválida!") {
          debugPrint('-- Email EXISTE - senha inválida');
          setState(() {
            emailSelecionado = email;
            etapaEmail = false;
            isLoading = false;
            mensagemErro = null;
          });
          return;
        }
        if (data['mensagem'] == "Email inválido!") {
          debugPrint('-- Email NÃO existe');
          setState(() {
            mensagemErro = "Email não cadastrado.";
            isLoading = false;
          });
          return;
        }
      }

      if (response.statusCode == 200) {
        debugPrint('-- Email EXISTE - login bem sucedido');
        setState(() {
          emailSelecionado = email;
          etapaEmail = false;
          isLoading = false;
          mensagemErro = null;
        });
        return;
      }

      debugPrint('-- Status code não esperado: ${response.statusCode}');
      setState(() {
        mensagemErro = "Email não cadastrado.";
        isLoading = false;
      });
    } catch (e) {
      debugPrint('-- ERRO na verificação de email: $e');
      setState(() {
        mensagemErro = "Erro ao verificar email. Verifique a conexão.";
        isLoading = false;
      });
    }
  }

  Future<void> fazerLogin() async {
    setState(() {
      isLoading = true;
      mensagemErro = null;
    });

    try {
      final String senha = senhaController.text;
      debugPrint('-- Fazendo login: $emailSelecionado');
      debugPrint('-- Senha enviada: $senha');

      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': emailSelecionado, 'senha': senha}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('-- Resposta do login: ${response.statusCode}');
      debugPrint('-- Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('-- Login bem sucedido: $data');

        final estadoUsuario = Provider.of<EstadoUsuario>(context, listen: false);
        await estadoUsuario.login(emailSelecionado!, senha);

        // Fecha o popup e retorna os dados
        Navigator.pop(context, data);
      } else if (response.statusCode == 401) {
        final data = json.decode(response.body);
        setState(() {
          mensagemErro = "Senha incorreta. Verifique e tente novamente.";
          isLoading = false;
        });
        debugPrint('-- SENHA ENVIADA: "$senha"');
      } else {
        setState(() {
          mensagemErro = "Erro ao fazer login. Tente novamente.";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('-- ERRO no login: $e');
      setState(() {
        mensagemErro = "Erro ao fazer login. Verifique a conexão.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String textoInstrucao = etapaEmail
        ? "Coloque seu e-mail para entrar na sua conta"
        : "Digite sua senha para continuar";

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: 350,
        height: etapaEmail ? 400 : 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                if (etapaEmail)
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      hintText: "Digite seu email @fmabc.net",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Arial',
                      ),
                    ),
                    onSubmitted: (_) => verificarEmail(),
                  )
                else
                  TextField(
                    controller: senhaController,
                    obscureText: !mostrarSenha,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      hintText: "Digite sua senha",
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'Arial',
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          mostrarSenha ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            mostrarSenha = !mostrarSenha;
                          });
                        },
                      ),
                    ),
                    onSubmitted: (_) => fazerLogin(),
                  ),
              ],
            ),

            const SizedBox(height: 10),

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
                      fontFamily: 'Arial',
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 10),

            if (mensagemErro != null)
              Text(
                mensagemErro!,
                style: TextStyle(
                  color: mensagemErro!.contains("sucesso") ? Colors.green : Colors.red,
                  fontFamily: 'Arial',
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 15),

            Row(
              children: [
                if (!etapaEmail)
                  Expanded(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                etapaEmail = true;
                                emailSelecionado = null;
                                mensagemErro = null;
                                senhaController.clear();
                                mostrarSenha = false;
                              });
                            },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                    onPressed: isLoading
                        ? null
                        : (etapaEmail ? verificarEmail : fazerLogin),
                    style: TextButton.styleFrom(
                      backgroundColor: isLoading ? Colors.grey : AppColors.brandGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            etapaEmail ? "Próximo" : "Entrar",
                            style: const TextStyle(fontFamily: 'Arial'),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: etapaEmail ? AppColors.brandGreen : Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: etapaEmail ? const Color.fromARGB(255, 124, 124, 124) : Colors.green,
                    borderRadius: BorderRadius.circular(4),
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