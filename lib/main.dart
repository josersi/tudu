import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

void main()  => runApp(TuduApp());

final Future<Database> database = getDatabasesPath().then((String databasePath) {
  Sqflite.setDebugModeOn(true);

  return openDatabase(
    join(databasePath, 'tudu_database.db'),
    onCreate: (db, version) async => await db.execute("CREATE TABLE tudus(id STRING PRIMARY KEY, text TEXT, creationDate INTEGER, done BOOLEAN)"),
    version: 1);
});

Future<void> insertTudu(TuduItem tudu) async {

  final Database db = await database;

  await db.insert('tudus', tudu.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<TuduItem>> getAllTudus() async {
  final Database db = await database;

  final List<Map<String, dynamic>> maps = await db.query('tudus');

  return List.generate(maps.length, (i) {
    return TuduItem(
      maps[i]['id'].toString(),
      maps[i]['text'],
      DateTime.fromMillisecondsSinceEpoch(maps[i]['creationDate']),
      maps[i]['done'] == 1,
    );
  });
}

Future<void> updateTudu(TuduItem tudu) async {
  final db = await database;

  await db.update('tudus', tudu.toMap(), where: "id = ?", whereArgs: [tudu.id]);
}

Future<void> deleteTudu(TuduItem tudu) async {
 
  final db = await database;

  await db.delete('tudus', where: "id = ?", whereArgs: [tudu.id]);
}

class TuduApp extends StatelessWidget {
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tudu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TuduHomePage(title: 'My Tudus'),
    );
  }
}

class TuduHomePage extends StatefulWidget {
  TuduHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TuduHomePageState createState() => _TuduHomePageState();
}

class _TuduHomePageState extends State<TuduHomePage> {

  void _addNewTudu() async {
    final String tuduMessage = await _queryTuduMessage(this.context);

    if (tuduMessage.isNotEmpty) {
      await insertTudu(new TuduItem(UniqueKey().hashCode.toString(), tuduMessage, DateTime.now()));
      setState(() => {});
    }
  }

  void _setTuduState(TuduItem tudu, bool newState) async {
    tudu.done = newState;
    await updateTudu(tudu);
    
    setState(() {});
  }

  void _deleteTudu(TuduItem tudu) async {
    await deleteTudu(tudu);
    setState(() {});
  }

  Future<String> _queryTuduMessage(BuildContext context) async {
    String tuduMessage = '';

    return showDialog<String>(
      context: context,
      barrierDismissible: false, // dialog is dismissible with a tap on the barrier
      builder: (BuildContext context) {

        return AlertDialog(
          title: Text('Create new tudu'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  autofocus: true,
                  decoration: new InputDecoration(labelText: 'What to do', hintText: 'Do something'),
                  onChanged: (value) {
                    tuduMessage = value;
                  },
                )
              )
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(tuduMessage);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = new DateFormat(DateFormat.YEAR_MONTH_DAY);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<TuduItem>>(
        future: getAllTudus(),
        builder: (BuildContext context, AsyncSnapshot<List<TuduItem>> snapshot) {

          List<TuduItem> tudus = snapshot.data ?? [];

          return Center(
            child: new ListView.builder(
              itemCount: tudus.length,
              itemBuilder: (BuildContext context, int index) {
                TuduItem tudu = tudus[index];

                return new Column(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new Checkbox(
                          value: tudu.done, 
                          onChanged: (value) {
                            _setTuduState(tudu, value);
                          }
                        ),
                        new Expanded(
                          child: new ListTile(
                            title: new Text('${tudu.text}'),
                            subtitle: new Text('${formatter.format(tudu.creationDate)}'),
                          )
                        ),
                        new IconButton(
                          icon: Icon(Icons.delete), 
                          tooltip: 'Remove tudu from the list',
                          onPressed: () {
                            _deleteTudu(tudu);
                          }
                        )
                      ]
                    ),                
                    new Divider(height: 2.0),
                  ],
                );
              },
            )
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        onPressed: _addNewTudu,
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TuduItem {
  final String id;
  final String text;
  final DateTime creationDate;
  bool done;

  TuduItem(this.id, this.text, this.creationDate, [ this.done = false ]);

   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'creationDate': creationDate.millisecondsSinceEpoch,
      'done': done
    };
  }
}
