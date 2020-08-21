import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:travel_observatory/database/travel_observatory_db.dart';
import 'package:travel_observatory/model/observation_model.dart';

import '../snackbar.dart';

class ObservationScreen extends StatefulWidget {
  @override
  ObservationScreenState createState() => new ObservationScreenState();
}

class ObservationScreenState extends State<ObservationScreen> {
  TravelObservatoryDb _travelObservatoryDb;
  TextEditingController sizeOfAnimalTextController;
  TextEditingController numOfAnimalsTextController;

  List tags;

  @override
  void initState() {
    super.initState();
    _travelObservatoryDb = new TravelObservatoryDb();
    sizeOfAnimalTextController = TextEditingController();
    numOfAnimalsTextController = TextEditingController();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    sizeOfAnimalTextController.dispose();
    numOfAnimalsTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            "Observations",
            style: new TextStyle(color: Colors.white),
          ),
        ),
        body: setContentView());
  }

  Widget setContentView() {
    return Container(
      child: new Center(
        // Use future builder and DefaultAssetBundle to load the local JSON file
        child: new FutureBuilder(
            future: loadAsset(),
            builder: (context, snapshot) {
              var tagsJson = jsonDecode(snapshot.data);
              tags = tagsJson != null ? List.from(tagsJson) : null;

              print(tags.toString());

              return new ListView.builder(
                  itemCount: tags == null ? 0 : tags.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        title: Text(tags[index]['id'].toString()),
                        subtitle: Text(tags[index]['animal'].toString()),
                        onTap: () {
                          _displayDialog(context, index);
                        },
                      ),
                    );
                  });
            }),
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Drawer Header'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Item 1'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Item 2'),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget listLayout(List tags, int index) {
    return new Card(
      child: new Container(
        child: new Center(
            child: new Column(
          // Stretch the cards in horizontal axis
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Text(
              // Read the name field value and set it in the Text widget
              tags[index]['id'].toString(),
              // set some style to text
              style:
                  new TextStyle(fontSize: 20.0, color: Colors.lightBlueAccent),
            ),
            new Text(
              // Read the name field value and set it in the Text widget
              tags[index]['animal'].toString(),
              // set some style to text
              style:
                  new TextStyle(fontSize: 20.0, color: Colors.lightBlueAccent),
            ),
          ],
        )),
        padding: const EdgeInsets.all(15.0),
      ),
    );
  }

  Future<String> loadAsset() async {
    //Allows us to read at runtime.
    return await DefaultAssetBundle.of(context)
        .loadString('assets/animals.json');
  }

  void insertObservation() async {
    final ob = Observation(
        date: 'date.toString()',
        time: 'time.toString()',
        gpsCoordinates: 'gpsCoordinates.getCoordinates().toString()');

    int result;

    if (ob.id != null) {
      // Case 1: Update operation
      result = await _travelObservatoryDb.updateObservation(ob);
    } else {
      // Case 2: Insert Operation
      result = await _travelObservatoryDb.insertObservatory(ob);
    }
  }

  _displayDialog(BuildContext context, int index) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(tags[index]['animal'].toString()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: sizeOfAnimalTextController,
                  decoration: InputDecoration(hintText: "Size of animal"),
                ),
                TextField(
                  controller: numOfAnimalsTextController,
                  decoration: InputDecoration(hintText: "No. of animal"),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text('Save'),
                onPressed: () {
                  print(sizeOfAnimalTextController.text);
                  SnackBarPage();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }
}
