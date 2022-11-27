import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

class ExtractPage extends StatefulWidget {
  late User loggedUser;
  ExtractPage(this.loggedUser);

  @override
  _ExtractPageState createState() => _ExtractPageState();
}

class _ExtractPageState extends State<ExtractPage> {
  late Future<Transactions> extractData;
  bool status = false;
  String message = "";

  @override
  void initState() {
    super.initState();
    extractData = getExtractData(widget.loggedUser.token);
  }

  Future<Transactions> getExtractData(String token) async {
    Transactions extract = Transactions(extract: []);

    if (token.trim() == "") {
      setState(() {
        message = "Token invalido!";
        status = false;
      });
      return extract;
    }

    try {
      final response = await http.get(
        Uri.parse('${API_HOST}/v1/wallet/extract'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Token': token,
        },
      );

      if (response.statusCode == 200) {
        Transactions extract = Transactions.fromJson(jsonDecode(response.body));
        setState(() {
          status = true;
        });

        return extract;
      } else {
        setState(() {
          message = "Falha ao buscar extrato!";
          status = false;
        });
      }
    } on Exception catch (_) {
      setState(() {
        message = "Falha ao buscar extrato!";
        status = false;
      });
    }

    return extract;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extrato'),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Expanded(
          //constraints: const BoxConstraints(
          //  minHeight: 100,
          //  maxHeight: 300,
          //),
          child: FutureBuilder<Transactions>(
            future: extractData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    itemCount: null == snapshot.data!.extract ? 0 : snapshot.data!.extract.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () async => {
                                await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Detalhes'),
                                        content: Column(
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                                                child: Text(
                                                  'De: ${snapshot.data!.extract[index].fromAddress}',
                                                  style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.left,
                                                )),
                                            Padding(
                                                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                                                child: Text(
                                                  'Para: ${snapshot.data!.extract[index].toAddress}',
                                                  style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.left,
                                                )),
                                            const Padding(
                                                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                                                child: Text(
                                                  'Mensagem:',
                                                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.left,
                                                )),
                                            Padding(
                                                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                                                child: Text(
                                                  snapshot.data!.extract[index].message,
                                                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.left,
                                                )),
                                            const Padding(
                                                padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                                                child: Text(
                                                  'Hash:',
                                                  style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.left,
                                                )),
                                            Padding(
                                                padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
                                                child: Text(
                                                  snapshot.data!.extract[index].hash,
                                                  style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.left,
                                                )),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('Ok'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    })
                              },
                          child: Container(
                              color: snapshot.data!.extract[index].value > 0 ? Colors.green[100] : Colors.red[100],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
                                      child: Column(children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              tooltip: snapshot.data!.extract[index].value > 0 ? 'Recebido' : 'Enviado',
                                              icon: snapshot.data!.extract[index].value > 0 ? const Icon(Icons.add) : const Icon(Icons.remove),
                                              onPressed: () {},
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Text(
                                                  snapshot.data!.extract[index].currency,
                                                  style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.left,
                                                )),
                                            Padding(
                                                padding: const EdgeInsets.only(left: 100),
                                                child: Text(
                                                  snapshot.data!.extract[index].date,
                                                  style: const TextStyle(color: Colors.black, fontSize: 20),
                                                  textAlign: TextAlign.left,
                                                )),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Text(
                                                  snapshot.data!.extract[index].hash.substring(0, 10),
                                                  style: const TextStyle(color: Colors.black, fontSize: 20),
                                                  textAlign: TextAlign.left,
                                                )),
                                            Padding(
                                                padding: const EdgeInsets.only(left: 15),
                                                child: Text(
                                                  'Amount: ${snapshot.data!.extract[index].value.toString()}',
                                                  style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.right,
                                                )),
                                          ],
                                        )
                                      ])),
                                ],
                              )));
                    });
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(
          context,
        ),
        tooltip: 'Voltar',
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
