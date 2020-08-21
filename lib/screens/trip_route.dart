import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travel_observatory/database/travel_observatory_db.dart';
import 'package:travel_observatory/local_storage/save_file_locally.dart';
import 'package:travel_observatory/location/get_gps_coordinates.dart';
import 'package:travel_observatory/model/trip_model.dart';
import 'package:travel_observatory/screens/observation_route.dart';

class TripRoute extends StatefulWidget {
  TripRoute({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TripRouteState createState() => _TripRouteState();
}

class _TripRouteState extends State<TripRoute> {
  TravelObservatoryDb _travelObservatoryDb = new TravelObservatoryDb();
  //Save file in the local directory.
  SaveFileLocally saveFileLocally = new SaveFileLocally();

  GetGPSCoordinates gpsCoordinates;

  BuildContext buildContext;

  String coordinates;
  String finalDate = '';

  List<Trip> tripList;
  int count = 0;

  @override
  void initState() {
    super.initState();

    //1. Initialize db, if it doesn't exist, create one.
    _travelObservatoryDb.initializeDatabase();

    //2. Get location access permission and then the GPS Coordinates.
    gpsCoordinates = new GetGPSCoordinates();
    gpsCoordinates.checkLocationPermission();

    if (saveFileLocally != null) {
      saveFileLocally.readFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    this.buildContext = context;
    if (tripList == null) {
      tripList = List<Trip>();
      updateListView();
    }
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Trips'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            tooltip: 'View observations',
            onPressed: () {
              _goToObservationScreen();
            },
          ),
        ],
      ),

      body: _buildList(),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _startTrip();
        },
        icon: Icon(Icons.save),
        label: Text("Start trip"),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //Renders each of the data points as individual list items.
  ListView _buildList() {
    print('setting content');
    return ListView.builder(
      shrinkWrap: true,
      itemCount: tripList == null ? 0 : tripList.length,
      itemBuilder: (BuildContext context, int position) {
        if (tripList.length == null) {
          return Center(child: Text('...'));
        } else {
          return _listItem(tripList, position);
        }
      },
    );
  }

  //build each item in the list
  Widget _listItem(List<Trip> tripList, int position) {
    return Card(
      color: Colors.white,
      elevation: 2.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber,
          child: Text(getFirstLetter(this.tripList[position].date),
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(this.tripList[position].time,
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(this.tripList[position].gpsCoordinates),
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
        },
      ),
    );
  }

  getFirstLetter(String title) {
    return title.substring(0, 2);
  }

  void updateListView() {
    print('updateListView');
    final Future<Database> dbFuture = _travelObservatoryDb.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Trip>> tripListFuture = _travelObservatoryDb.getTrips();
      tripListFuture.then((tripList) {
        setState(() {
          this.tripList = tripList;
          this.count = tripList.length;
        });
        print(tripList);
      });
    });
  }

  String _convertDate() {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    return "${dateParse.day}-${dateParse.month}-${dateParse.year}";
  }

  // Create a Trip and add it to the trips table.
  void _insertTrip() async {
    var date = _convertDate();
    var time = new DateTime.now();
    int result;

    final trip = Trip(
        date: date.toString(),
        time: time.toString(),
        gpsCoordinates: gpsCoordinates.getCoordinates().toString());

    if (trip.id != null) {
      // Case 1: Update operation
      result = await _travelObservatoryDb.updateTrip(trip);
      saveFileLocally.writeFile(trip.toString());
    } else {
      // Case 2: Insert Operation
      result = await _travelObservatoryDb.insertTrip(trip);
      saveFileLocally.writeFile(trip.toString());
    }

    if (result != 0) {
      // Success
      print('success');
      updateListView();
    } else {
      // Failure
      print('failure');
    }
  }

  void _startTrip() {
    setState(() {
      _insertTrip();
      displayModalBottomSheet(context);
    });
  }

  void displayModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.music_note),
                    title: new Text('Music'),
                    onTap: () => {}),
                new ListTile(
                  leading: new Icon(Icons.videocam),
                  title: new Text('Video'),
                  onTap: () => {},
                ),
              ],
            ),
          );
        });
  }

  void _goToObservationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ObservationRoute()),
    );
  }
}
