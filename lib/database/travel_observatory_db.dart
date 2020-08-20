import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:travel_observatory/model/observation_model.dart';
import 'package:travel_observatory/model/trip_model.dart';

class TravelObservatoryDb {
  // Singleton DatabaseHelper
  static TravelObservatoryDb _databaseHelper;
  // Singleton Database
  static Database _database;

  String databaseName = 'travel_observatory_db.db';
  String tableName = 'trips';
  String observatoryTable = 'observatories';

  int id = 0;
  String date = 'date';
  String time = 'time';
  String gpsCoordinates = 'gpsCoordinates';

  // Named constructor to create instance of DatabaseHelper
  TravelObservatoryDb._createInstance();

  factory TravelObservatoryDb() {
    if (_databaseHelper == null) {
      _databaseHelper = TravelObservatoryDb
          ._createInstance(); // This is executed only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, databaseName);

    // Open/create the database at a given path
    var tripDatabase =
        await openDatabase(dbPath, version: 1, onCreate: _createDb);
    return tripDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
      "CREATE TABLE $tableName(id INTEGER PRIMARY KEY, "
      "$date TEXT, $time TEXT, $gpsCoordinates TEXT)",
    );

    await db.execute(
      "CREATE TABLE $observatoryTable(id INTEGER PRIMARY KEY, "
      "$date TEXT, $time TEXT, $gpsCoordinates TEXT)",
    );
  }

  // Fetch Operation: Get all todo objects from database
  Future<List<Map<String, dynamic>>> getTodoMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $todoTable order by $colTitle ASC');
    var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Insert Operation: Insert a trip object to database
  Future<int> insertTrip(Trip trip) async {
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    var result = await db.insert(
      tableName,
      trip.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return result;
  }

  // Insert Operation: Insert a trip object to database
  Future<int> insertObservatory(Observation observation) async {
    print('inserted obs');
    // Get a reference to the database.
    final Database db = await database;

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    var result = await db.insert(
      observatoryTable,
      observation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return result;
  }

  // Update Operation: Update a trip object and save it to database
  Future<int> updateTrip(Trip trip) async {
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    var result = await db.update(
      tableName,
      trip.toMap(),
      // Ensure that the Dog has a matching id.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [trip.id],
    );

    return result;
  }

  Future<int> updateObservation(Observation observation) async {
    print('updated obs');
    // Get a reference to the database.
    final db = await database;

    // Update the given Dog.
    var result = await db.update(
      observatoryTable,
      observation.toMap(),
      // Ensure that the Dog has a matching id.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [observation.id],
    );

    return result;
  }

  // Delete Operation: Delete a todo object from database
  Future<int> deleteTodo(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $tableName WHERE id = $id');
    return result;
  }

  // Get number of todo objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $tableName');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Trip>> getObservations() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query(observatoryTable);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Trip(
          id: maps[i]['id'],
          date: maps[i]['date'],
          time: maps[i]['time'],
          gpsCoordinates: maps[i]['gpsCoordinates']);
    });
  }

  Future<List<Trip>> getTrips() async {
    // Get a reference to the database.
    final Database db = await database;

// Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query(tableName);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Trip(
          id: maps[i]['id'],
          date: maps[i]['date'],
          time: maps[i]['time'],
          gpsCoordinates: maps[i]['gpsCoordinates']);
    });
  }
}
