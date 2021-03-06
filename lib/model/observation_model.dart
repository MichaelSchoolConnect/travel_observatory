import 'package:travel_observatory/model/generic_model.dart';

class Observation implements GenericModel {
  final int id;
  final String date;
  final String time;
  final String gpsCoordinates;

  Observation({this.id, this.date, this.time, this.gpsCoordinates});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'gpsCoordinates': gpsCoordinates
    };
  }

  factory Observation.fromJson(Map<String, dynamic> data) => new Observation(
        id: data["id"],
        date: data["date"],
        time: data["time"],
        gpsCoordinates: data["gpsCoordinates"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "time": time,
        "gpsCoordinates": gpsCoordinates,
      };

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Trip{id: $id, date: $date, time: $time, gpscoordinates: $gpsCoordinates}';
  }

  // Generics implementation.
  @override
  T getGPSCoordinates<T>(gpsCoordinates) {
    return gpsCoordinates;
  }
}
