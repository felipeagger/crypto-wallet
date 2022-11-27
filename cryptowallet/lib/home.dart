import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'extract.dart';
import 'models.dart';
import 'transaction.dart';

class HomePage extends StatefulWidget {
  late User loggedUser;
  HomePage(this.loggedUser);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Extract> extractData;
  late Extract _extract;
  bool status = false;
  String message = "";

  @override
  void initState() {
    super.initState();
    extractData = getHomeBalance(widget.loggedUser.token);
  }

  Future<Extract> getHomeBalance(String token) async {
    Extract extract = Extract(
        balance: Balance(
          BTC: Currency(value: 0, converted: 0),
          ETH: Currency(value: 0, converted: 0),
          LTC: Currency(value: 0, converted: 0),
          Total: '0,00',
        ),
        addresses: Addresses(
          BTCAddress: Wallet(value: ""),
          ETHAddress: Wallet(value: ""),
          LTCAddress: Wallet(value: ""),
        ));

    if (token.trim() == "") {
      setState(() {
        message = "Token invalido!";
        status = false;
      });
      return extract;
    }

    try {
      final response = await http.get(
        Uri.parse('${API_HOST}/v1/wallet/balance'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'X-Token': token,
        },
      );

      if (response.statusCode == 200) {
        Extract extract = Extract.fromJson(jsonDecode(response.body));
        setState(() {
          _extract = extract;
          status = true;
        });

        return extract;
      } else {
        setState(() {
          message = "Falha ao buscar saldo!";
          status = false;
        });
      }
    } on Exception catch (_) {
      setState(() {
        message = "Falha ao buscar saldo!";
        status = false;
      });
    }

    return extract;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Wallet'),
        //automaticallyImplyLeading: false,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/crypto-wallet-512.png'), fit: BoxFit.scaleDown, alignment: Alignment.center),
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Transação'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionPage(widget.loggedUser, _extract)),
                );
              },
            ),
            ListTile(
              title: const Text('Extrato'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExtractPage(widget.loggedUser)),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(left: 10, top: 10.0, bottom: 10),
            child: Text(
              'Carteira de: ${widget.loggedUser.name}',
              style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            )),
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 100,
            maxHeight: 300,
          ),
          child: FutureBuilder<Extract>(
            future: extractData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: <Widget>[
                    Container(
                      height: 50,
                      color: const Color.fromARGB(255, 204, 194, 194),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(left: 5, top: 5.0),
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: const BoxDecoration(
                                image: DecorationImage(image: AssetImage('assets/images/btc.png'), fit: BoxFit.contain, alignment: Alignment.topLeft),
                              ),
                            )),
                        const Padding(
                            padding: EdgeInsets.only(left: 15, top: 10.0),
                            child: Text(
                              'Bitcoin',
                              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            )),
                        const Spacer(),
                        Padding(
                            padding: const EdgeInsets.only(top: 10.0, right: 15),
                            child: Text(
                              '${snapshot.data!.balance.BTC.value}',
                              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            )),
                      ]),
                    ),
                    Container(
                      height: 50,
                      color: const Color.fromARGB(255, 204, 194, 194),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(left: 5, top: 5.0),
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: const BoxDecoration(
                                image: DecorationImage(image: AssetImage('assets/images/eth.png'), fit: BoxFit.contain, alignment: Alignment.topLeft),
                              ),
                            )),
                        const Padding(
                            padding: EdgeInsets.only(left: 15, top: 10.0),
                            child: Text(
                              'Ethereum',
                              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            )),
                        const Spacer(),
                        Padding(
                            padding: const EdgeInsets.only(top: 10.0, right: 15),
                            child: Text(
                              '${snapshot.data!.balance.ETH.value}',
                              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            )),
                      ]),
                    ),
                    Container(
                      height: 50,
                      color: const Color.fromARGB(255, 204, 194, 194),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(left: 5, top: 5.0),
                            child: Container(
                              height: 40.0,
                              width: 40.0,
                              decoration: const BoxDecoration(
                                image: DecorationImage(image: AssetImage('assets/images/ltc.png'), fit: BoxFit.contain, alignment: Alignment.topLeft),
                              ),
                            )),
                        const Padding(
                            padding: EdgeInsets.only(left: 15, top: 10.0),
                            child: Text(
                              'Litecoin',
                              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            )),
                        const Spacer(),
                        Padding(
                            padding: const EdgeInsets.only(top: 10.0, right: 15),
                            child: Text(
                              '${snapshot.data!.balance.LTC.value}',
                              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            )),
                      ]),
                    ),
                    Container(
                      height: 50,
                      color: Colors.white,
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.only(left: 15, top: 10.0),
                            child: Text(
                              'Total',
                              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            )),
                        const Spacer(),
                        Padding(
                            padding: const EdgeInsets.only(top: 10.0, right: 15),
                            child: Text(
                              '${snapshot.data!.balance.Total}',
                              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            )),
                      ]),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        //onPressed: () => Navigator.push(
        //  context,
        //  MaterialPageRoute(builder: (context) => TransactionPage(widget.loggedUser)),
        //),
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TransactionPage(widget.loggedUser, _extract)),
        ),
        tooltip: 'Transacionar',
        child: const Icon(Icons.currency_exchange),
      ),
      //bottomNavigationBar: _BottomAppBar(),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Colors.orange,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          children: <Widget>[
            const Spacer(),
            IconButton(
              tooltip: 'Extrato',
              icon: const Icon(Icons.history),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
