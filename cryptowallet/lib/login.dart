import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'home.dart';
import 'models.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String message = "";
  bool status = false;

  Future<User> loginUser(String email, String password) async {
    if (email.trim() == "" || password.trim() == "" || !email.contains("@") || !email.contains(".")) {
      setState(() {
        message = "Email valido e senha é obrigatorio!";
        status = false;
      });
      return User(name: "", email: "", phone: "", password: "", token: "");
    }

    try {
      final response = await http.post(
        Uri.parse('${API_HOST}/v1/user/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        User userData = User.fromJson(jsonDecode(response.body));
        setState(() {
          message = "Usuario Logado com Sucesso!";
          status = true;
        });

        return userData;
      } else {
        setState(() {
          message = "Falha ao fazer login!";
          status = false;
        });
      }
    } on Exception catch (_) {
      setState(() {
        message = "Falha ao fazer login!";
        status = false;
      });
    }

    return User(name: "", email: "", phone: "", password: "", token: "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 40, bottom: 0),
              child: Text(
                'Crypto Wallet',
                style: TextStyle(color: Colors.black, fontSize: 25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 15),
              child: Center(
                child: Container(width: 200, height: 150, child: Image.asset('assets/images/crypto-wallet-512.png')),
              ),
            ),
            Padding(
              //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Email', hintText: 'Entre com um email valido como abc@gmail.com'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 25),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Senha', hintText: 'Entre com uma senha segura'),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () async {
                  try {
                    User usr = await loginUser(emailController.text, passwordController.text);

                    if (status) {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => HomePage(usr)));
                    } else {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Informação'),
                              content: Text(message),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Ok'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          });
                    }
                  } on Exception catch (_) {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Informação'),
                            content: Text(message),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Ok'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        });
                  }
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10, bottom: 0),
              child: TextButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text("Indisponivel"),
                    content: Text("Função não implementada ainda!"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context, 'OK'),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
                child: const Text(
                  'Esqueci minha senha',
                  style: TextStyle(color: Colors.orange, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(
              height: 130,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage()),
              ),
              child: const Text(
                'Novo Usuário? Cadastre-se',
                style: TextStyle(color: Colors.orange, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
