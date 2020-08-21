import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:travel_observatory/database/travel_observatory_db.dart';
import 'package:travel_observatory/model/observation_model.dart';

class ObservationScreen extends StatefulWidget {
  @override
  ObservationScreenState createState() => new ObservationScreenState();
}

class ObservationScreenState extends State<ObservationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TravelObservatoryDb _travelObservatoryDb;
  TextEditingController sizeOfAnimalTextController;
  TextEditingController numOfAnimalsTextController;

  ScrollController _scrollController;
  List tags;

  @override
  void initState() {
    super.initState();
    _travelObservatoryDb = new TravelObservatoryDb();
    sizeOfAnimalTextController = TextEditingController();
    numOfAnimalsTextController = TextEditingController();

    _scrollController = new ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    print(_scrollController.position.extentAfter);
    if (_scrollController.position.extentAfter == tags.length) {
      setState(() {
        //tags.addAll(new List.generate(42, (index) => 'Inserted $index'));
        print('add more data here...');
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Clean up the controller when the widget is disposed.
    sizeOfAnimalTextController.dispose();
    numOfAnimalsTextController.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "Observations",
            style: new TextStyle(color: Colors.white),
          ),
        ),
        body: _buildList());
  }

  Widget _buildList() {
    return Container(
      child: new Center(
        // Use future builder and DefaultAssetBundle to load the local JSON file
        child: FutureBuilder(
            future: loadAsset(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();

              var tagsJson = jsonDecode(snapshot.data);
              tags = tagsJson != null ? List.from(tagsJson) : null;

              for (int i = 0; i < tags.length; i++) {
                print(tags[i]);
              }

              return new ListView.builder(
                  controller: _scrollController,
                  itemCount: tags == null ? 0 : tags.length,
                  itemBuilder: (BuildContext context, int index) {
                    return listItem(index);
                  });
            }),
      ),
    );
  }

  Widget listItem(int index) {
    return Card(
      child: ListTile(
        title: Text(tags[index]['animal'].toString()),
        onTap: () {
          _displayDialog(context, index);
        },
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
                  insertObservation();
                  _showToast();
                },
              )
            ],
          );
        });
  }

  void _showToast() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('Trip started'),
    ));
  }
}
