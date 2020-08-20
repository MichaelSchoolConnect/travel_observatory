import 'package:location/location.dart';

class GetGPSCoordinates {
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Future<void> checkLocationPermission() async {
    print('Check if service is enabled');
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    print('Has permissions');
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    print('Try to get location');
    _locationData = await location.getLocation();
    print('location: ' + _locationData.toString());
  }

  String getCoordinates() {
    print('getting coordinates' + _locationData.toString());
    return _locationData.toString();
  }
}
