import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MaterialApp(title: "Contador de Pessoas", home: Home()));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _people = 0;
  String _capacityText = "Pode Entrar!";

  void _changePeople(int cont) {
    setState(() {
      _people += cont;
      (_people >= 10)
          ? _capacityText = "Estamos lotado"
          : (_people < 0)
              ? _capacityText = "Mundo invertido?"
              : _capacityText = "Pode Entrar!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "images/restaurant.jpg",
          fit: BoxFit.cover,
          height: 1000.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Pessoas $_people",
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                        child: const Text("+1",
                            style:
                                TextStyle(fontSize: 40.0, color: Colors.white)),
                        onPressed: () {
                          _changePeople(1);
                        })),
                Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                        child: const Text("-1",
                            style:
                                TextStyle(fontSize: 40.0, color: Colors.white)),
                        onPressed: () {
                          _changePeople(-1);
                        }))
              ],
            ),
            Text(_capacityText,
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 30.0))
          ],
        )
      ],
    );
  }
}
