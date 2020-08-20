import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travel_observatory/database/travel_observatory_db.dart';
import 'package:travel_observatory/location/get_gps_coordinates.dart';
import 'package:travel_observatory/model/animals_model.dart';
import 'package:travel_observatory/model/observation_model.dart';

class ObservationScreen extends StatefulWidget {
  @override
  ObservationScreenState createState() => new ObservationScreenState();
}

class ObservationScreenState extends State<ObservationScreen> {
  TravelObservatoryDb _travelObservatoryDb = new TravelObservatoryDb();
  GetGPSCoordinates gpsCoordinates;

  List<Animals> animalsList;
  ObservationScreenState({Key key, this.animalsList});

  List data;
  List<Observation> observatoryList;
  int count = 0;

  @override
  void initState() {
    super.initState();
    /*WidgetsBinding.instance.addPostFrameCallback((_) async {
      await loadAsset();
    });*/
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
        body: new Container(
          child: new Center(
            // Use future builder and DefaultAssetBundle to load the local JSON file
            child: new FutureBuilder(
                future: loadAsset(),
                builder: (context, snapshot) {
                  var tagsJson = jsonDecode(snapshot.data);
                  List tags = tagsJson != null ? List.from(tagsJson) : null;

                  print(tags.toString());

                  return new ListView.builder(
                      itemCount: tags == null ? 0 : tags.length,
                      itemBuilder: (BuildContext context, int index) {
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
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.lightBlueAccent),
                                ),
                                new Text(
                                  // Read the name field value and set it in the Text widget
                                  tags[index]['animal'].toString(),
                                  // set some style to text
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.lightBlueAccent),
                                ),
                              ],
                            )),
                            padding: const EdgeInsets.all(15.0),
                          ),
                        );
                      });
                }),
          ),
        ));
  }

  List<Animals> parseJson(String response) {
    if (response == null) {
      return [];
    }
    final parsed = json.decode(response).cast<Map<String, dynamic>>();
    return parsed.map<Animals>((json) => new Animals.fromJson(json)).toList();
  }

  Future<String> loadAsset() async {
    //Allows us to read at runtime.
    return await DefaultAssetBundle.of(context).loadString('assets/mani.json');
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

  ListView getObservationListView() {
    print('getObservationListView');
    return ListView.builder(
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.amber,
              child: Text(this.animalsList[position].animalName),
            ),
            title: Text(this.animalsList[position].animalName,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(this.animalsList[position].animalName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onTap: () {
                    //_delete(context, todoList[position]);
                  },
                ),
              ],
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              // navigateToDetail(this.todoList[position], 'Edit Todo');
            },
          ),
        );
      },
    );
  }

  void updateListView() {
    print('updateListView');
    final Future<Database> dbFuture = _travelObservatoryDb.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Observation>> tripListFuture =
          _travelObservatoryDb.getObservations() as Future<List<Observation>>;
      tripListFuture.then((tripList) {
        setState(() {
          this.observatoryList = tripList;
          this.count = tripList.length;
        });
        print(tripList);
      });
    });
  }

  Widget animalsWidget() {
    return ListView.builder(
        itemCount: animalsList == null ? 0 : animalsList.length,
        itemBuilder: (BuildContext context, int index) {
          return new Card(
            child: new Container(
              child: new Center(
                  child: new Column(
                // Stretch the cards in horizontal axis
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Text(
                    // Read the name field value and set it in the Text widget
                    animalsList[index].animalName,
                    // set some style to text
                    style: new TextStyle(
                        fontSize: 20.0, color: Colors.lightBlueAccent),
                  ),
                ],
              )),
              padding: const EdgeInsets.all(15.0),
            ),
          );
        });
  }
}
