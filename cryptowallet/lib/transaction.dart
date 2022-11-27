import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'home.dart';
import 'models.dart';

const List<String> listCurrency = <String>['LTC', 'BTC', 'ETH'];

class TransactionPage extends StatefulWidget {
  late User loggedUser;
  late Extract extract;
  TransactionPage(this.loggedUser, this.extract);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController toAddressController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  String dropdownValue = listCurrency.first;
  String message = "";
  bool status = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.extract.addresses.LTCAddress.value;
  }

  Future<String> createTransaction(String token, String currency, String toAddress, double amount, String message) async {
    if (currency.trim() == "" || toAddress.trim() == "" || amount <= 0.0) {
      String msg = "Endereço e quantidade é obrigatorio!";
      setState(() {
        message = msg;
        status = false;
      });
      return msg;
    }

    try {
      final response = await http.post(
        Uri.parse('${API_HOST}/v1/transaction/new'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Token': token,
        },
        body: jsonEncode(<String, dynamic>{
          'currency': currency,
          'to_address': toAddress,
          'amount': amount,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        Transaction transact = Transaction.fromJson(jsonDecode(response.body));
        setState(() {
          message = "Transação feita com Sucesso!";
          status = true;
        });
      } else {
        Error err = Error.fromJson(jsonDecode(response.body));
        setState(() {
          message = "Falha ao fazer Transação: ${err.detail.msg}";
          status = false;
        });
      }
    } on Exception catch (_) {
      message = "Falha ao fazer Transação!";
    }

    return message;
  }

  DropdownButton getDropdown() {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_forward),
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        color: Colors.deepOrangeAccent,
      ),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
          if (dropdownValue == "LTC") {
            fromAddressController.text = widget.extract.addresses.LTCAddress.value;
          } else if (dropdownValue == "BTC") {
            fromAddressController.text = widget.extract.addresses.BTCAddress.value;
          } else if (dropdownValue == "ETH") {
            fromAddressController.text = widget.extract.addresses.ETHAddress.value;
          }
        });
      },
      items: listCurrency.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Transação"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: const EdgeInsets.only(left: 0, right: 15.0, top: 20, bottom: 15),
              child: Text(
                'Nova Transação',
                style: TextStyle(color: Colors.black, fontSize: 25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                width: 300.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(color: Colors.orange, style: BorderStyle.solid, width: 0.80),
                ),
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: getDropdown(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: TextField(
                controller: fromAddressController,
                //enabled: false,
                readOnly: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Meu Endereço', hintText: ''),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 15),
              child: TextField(
                controller: toAddressController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Endereço', hintText: 'Entre com o endereço de destino'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: amountController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Quantidade', hintText: 'Entre com a quantidade a ser enviada'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\,?\d{0,8}'))],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 25),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: messageController,
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Mensagem', hintText: 'Opcional'),
              ),
            ),
            Row(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 0, top: 5, bottom: 10),
                child: Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage(widget.loggedUser)),
                      );
                    },
                    child: const Text(
                      'Voltar',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(left: 0, right: 15.0, top: 5, bottom: 10),
                child: Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () async {
                      String msg = await createTransaction(widget.loggedUser.token, dropdownValue, toAddressController.text, double.parse(amountController.text.replaceAll(',', '.')), messageController.text);

                      await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Informação'),
                              content: Text(msg),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Ok'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          });

                      if (status) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage(widget.loggedUser)),
                        );
                        //Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      'Enviar',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
