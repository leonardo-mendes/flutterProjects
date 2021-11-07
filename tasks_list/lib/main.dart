import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();

  List _toDoList = [];
  Map<String, dynamic>? _lastRemoved;
  int? _lastRemovedIndex;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = jsonDecode(data);
      });
    });
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return "null";
    }
  }

  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = {};
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
          child: Icon(_toDoList[index]["ok"] ? Icons.check : Icons.error),
        ),
        onChanged: (value) {
          setState(() {
            _toDoList[index]["ok"] = value;
            _saveData();
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _lastRemoved = Map.from(_toDoList[index]);
          _lastRemovedIndex = index;
          _toDoList.removeAt(index);
          _saveData();

          final snack = SnackBar(
            duration: const Duration(seconds: 2),
            content: Text("Removed \"${_lastRemoved?["title"]}\" task!"),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                setState(() {
                  _toDoList.insert(_lastRemovedIndex!, _lastRemoved);
                  _saveData();
                });
              },
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _toDoList.sort((firstElement, secondElement){
        if( firstElement["ok"] && !secondElement["ok"]) {
          return 1;
        } else if( !firstElement["ok"] && secondElement["ok"]) {
          return -1;
        }
        return 0;
      });
      _saveData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Tasks List"),
          backgroundColor: Colors.blueAccent,
          centerTitle: true),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: _toDoController,
                  decoration: const InputDecoration(
                      labelText: "New Task",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                )),
                ElevatedButton(onPressed: _addToDo, child: const Text("+"))
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
                child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10.0),
                    itemCount: _toDoList.length,
                    itemBuilder: buildItem),
                onRefresh: _refresh,
              ))
        ],
      ),
    );
  }
}
