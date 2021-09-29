import 'package:transportumformanager/entity/vehicle.dart';

class TransportIcons {
  static const ownCar = "assets/truck.png";
  static const rentCar = "assets/truck_rent.png";
}

class Transport extends Vehicle {
  final int defaultDriverId;
  final String techFunction;
  final String comment;
  final int companyId;

  const Transport(int id, String modelName, int client_id, String number,
      bool isOwn, this.defaultDriverId, this.techFunction, this.comment, this.companyId)
      : super(id, modelName, client_id, number, isOwn);

  factory Transport.fromJSON(Map<String, dynamic> jsonData) {
    bool _isOwn;
    int _jsonOwn = jsonData['type'] as int;
    if (_jsonOwn == 1)
      _isOwn = true;
    else
      _isOwn = false;

    return Transport(
        jsonData['id'] as int,
        jsonData['model'] as String,
        jsonData['client_id'] as int,
        jsonData['number'] as String,
        _isOwn,
        jsonData['default_driver'] as int,
        jsonData['function'] as String,
        jsonData['comment'] as String,
        jsonData['company_id'] as int);
  }

  String getIconAssetName() {
    if (this.isOwn)
      return TransportIcons.ownCar;
    else
      return TransportIcons.rentCar;
  }
}
