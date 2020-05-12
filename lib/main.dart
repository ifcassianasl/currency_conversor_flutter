import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = 'https://api.hgbrasil.com/finance';

void main() => runApp(
      MaterialApp(
        home: Home(),
        theme: ThemeData(
          hintColor: Colors.amber,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.amber),
            ),
            hintStyle: TextStyle(color: Colors.amber),
          ),
        ),
      ),
    );

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final usdController = TextEditingController();
  final eurController = TextEditingController();

  double dollar;
  double euro;

  void _clearAll() {
    realController.text = "";
    usdController.text = "";
    eurController.text = "";
  }

  void _realChanged(String value) {
    if (value.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(value);

    usdController.text = (real / this.dollar).toStringAsFixed(2);
    eurController.text = (real / this.euro).toStringAsFixed(2);
  }

  void _usdChanged(String value) {
    if (value.isEmpty) {
      _clearAll();
      return;
    }

    double usd = double.parse(value);

    realController.text = (this.dollar * usd).toStringAsFixed(2);
    eurController.text = (this.dollar * usd / this.euro).toStringAsFixed(2);
  }

  void _eurChanged(String value) {
    if (value.isEmpty) {
      _clearAll();
      return;
    }

    double eur = double.parse(value);

    realController.text = (this.euro * eur).toStringAsFixed(2);
    usdController.text = (this.euro * eur / this.dollar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Currency Conversor \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando dados...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              );

            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dollar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];
                return SingleChildScrollView(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150.0,
                        color: Colors.amber,
                      ),
                      Divider(),
                      buildTextField(
                          "Reais", "R\$", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dolares", "US\$", usdController, _usdChanged),
                      Divider(),
                      buildTextField("Euros", "€", eurController, _eurChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
      color: Colors.amber,
      fontSize: 22.0,
    ),
    onChanged: function,
    keyboardType: TextInputType.number,
  );
}
