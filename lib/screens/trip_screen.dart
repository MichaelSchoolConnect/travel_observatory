import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travel_observatory/database/travel_observatory_db.dart';
import 'package:travel_observatory/local_storage/save_file_locally.dart';
import 'package:travel_observatory/location/get_gps_coordinates.dart';
import 'package:travel_observatory/model/trip_model.dart';

class TripScreen extends StatefulWidget {
  TripScreen({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _TripScreenState createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  TravelObservatoryDb _travelObservatoryDb = new TravelObservatoryDb();
  //Save file in the local directory.
  SaveFileLocally saveFileLocally = new SaveFileLocally();
  GetGPSCoordinates gpsCoordinates;

  BuildContext context;

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
    this.context = context;
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
      ),
      body: getTripListView(),

      floatingActionButton: FloatingActionButton(
        onPressed: _saveTrip,
        tooltip: 'Save trip',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  ListView getTripListView() {
    print('getTripListView');
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
              // navigateToDetail(this.todoList[position], 'Edit Todo');
            },
          ),
        );
      },
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

  _getCurrentDate() {
    var date = new DateTime.now().toString();

    var dateParse = DateTime.parse(date);

    var formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";

    setState(() {
      finalDate = formattedDate.toString();
    });
  }

  String _convertDate() {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    return "${dateParse.day}-${dateParse.month}-${dateParse.year}";
  }

  // Save data to database
  void _insertTrip() async {
    //Date
    var date = _convertDate();
    //Time
    var time = new DateTime.now();

// Create a Trip and add it to the trips table.
    final trip = Trip(
        date: date.toString(),
        time: time.toString(),
        gpsCoordinates: gpsCoordinates.getCoordinates().toString());

    int result;

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
      _showAlertDialog('Status', 'Trip info saved successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem saving trip info');
    }
  }

  void _saveTrip() {
    setState(() {
      debugPrint("Save button clicked");
      _insertTrip();
    });
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }
}
