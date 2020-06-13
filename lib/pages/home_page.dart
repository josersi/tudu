import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:intl/intl.dart';
import 'package:tudu/models/tudu_model.dart';
import 'package:tudu/service/tudu_service.dart';
import 'package:tudu/utils/asset_util.dart';

class TuduHomePage extends StatefulWidget {
  TuduHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _TuduHomePageState createState() => _TuduHomePageState();
}

class _TuduHomePageState extends State<TuduHomePage> {
  final TuduService _tuduService = new TuduService();

  void _addNewTudu() async {
    final String tuduMessage = await _queryTuduMessage(this.context);

    if (tuduMessage.isNotEmpty) {
      final TuduModel tudu = new TuduModel(UniqueKey().hashCode.toString(), tuduMessage, DateTime.now());
      await _tuduService.insertTudu(tudu);
      setState(() => {});
    }
  }

  void _setTuduState(TuduModel tudu, bool newState) async {
    tudu.done = newState;
    await _tuduService.updateTudu(tudu);
    
    setState(() {});
  }

  void _deleteTudu(TuduModel tudu) async {
    await _tuduService.deleteTudu(tudu);
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
        actions: <Widget>[
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert),
            onSelected: (int result) async {
              PackageInfo packageInfo = await PackageInfo.fromPlatform();
              String legalNotice = await AssetUtil.getAsset("legal_notice.txt");

              showAboutDialog(
                context: context,
                applicationVersion: packageInfo.version,
                applicationLegalese: legalNotice
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem(
                value: 1,
                child: Text('About'),
              )
            ],
          )
        ],
      ),
      body: FutureBuilder<List<TuduModel>>(
        future: _tuduService.getAllTudus(),
        builder: (BuildContext context, AsyncSnapshot<List<TuduModel>> snapshot) {

          List<TuduModel> tudus = snapshot.data ?? [];

          return Center(
            child: new ListView.builder(
              itemCount: tudus.length,
              itemBuilder: (BuildContext context, int index) {
                TuduModel tudu = tudus[index];

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
                          color: Colors.grey,
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