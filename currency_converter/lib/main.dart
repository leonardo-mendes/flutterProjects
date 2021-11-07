import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=3f24643c";

// Run --> Edit Configurations --> Add Additional Run args --> --no-sound-null-safety to use http dependency

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double? dollar;
  double? euro;

  void _realChanged(String text){
    if(text.isNotEmpty){
      double real = double.parse(text);
      dollarController.text = (real / dollar!).toStringAsFixed(2);
      euroController.text = (real / euro!).toStringAsFixed(2);
    }
  }

  void _dollarChanged(String text){
    if(text.isNotEmpty){
      double dollar = double.parse(text);
      realController.text = (dollar * this.dollar!).toStringAsFixed(2);
      euroController.text = ((dollar * this.dollar!) / euro!).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text){
    if(text.isNotEmpty){
      double euro = double.parse(text);
      dollarController.text = (euro * this.euro! / dollar!).toStringAsFixed(2);
      realController.text = (euro * this.euro! / dollar!).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: const Text("\$ Currency Converter"),
          backgroundColor: Colors.amber,
          centerTitle: true),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text("Loading",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text("Error to load data.",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center),
                );
              } else {
                dollar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(Icons.monetization_on,
                          size: 150.0, color: Colors.amber),
                      buildTextField("Reais", "R\$", realController, _realChanged),
                      const Divider(),
                      buildTextField("Dollars", "US\$", dollarController, _dollarChanged),
                      const Divider(),
                      buildTextField("Euros", "€", euroController, _euroChanged),
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

// Requisição Async http
Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Widget buildTextField(String label, String prefix, TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    onChanged:  function as void Function(String)?,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber),
        border: const OutlineInputBorder(),
        prefixText: prefix),
    style: const TextStyle(color: Colors.amber),
  );
}
