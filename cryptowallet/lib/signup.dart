import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'home.dart';
import 'models.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String message = "";
  bool status = false;

  Future<String> signUpUser(String name, String email, String password, String phone) async {
    if (name.trim() == "" || email.trim() == "" || password.trim() == "" || !email.contains("@") || !email.contains(".")) {
      String msg = "Email valido, Nome e senha é obrigatorio!";
      setState(() {
        message = msg;
        status = false;
      });
      return msg;
    }

    try {
      final response = await http.post(
        Uri.parse('${API_HOST}/v1/user/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (response.statusCode == 201) {
        //User userData = User.fromJson(jsonDecode(response.body));
        setState(() {
          message = "Usuario Criado com Sucesso!";
          status = true;
        });
      } else {
        setState(() {
          message = "Falha ao criar usuario!";
          status = false;
        });
      }
    } on Exception catch (_) {
      message = "Falha ao criar usuario!";
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Cadastro"),
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
                controller: nameController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Nome', hintText: 'Entre com nome completo'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Email', hintText: 'Entre com um email valido como abc@gmail.com'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: phoneController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Telefone', hintText: 'Opcional'),
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
                  String msg = await signUpUser(nameController.text, emailController.text, passwordController.text, phoneController.text);

                  await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Informação'),
                          content: Text(msg),
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

                  if (status) {
                    Navigator.pop(context);
                  }
                  ;
                },
                child: const Text(
                  'Registrar-se',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
