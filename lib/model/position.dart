class Position {
  final double lat;
  final double lng;

  const Position(this.lat, this.lng);

  factory Position.fromStrings(dynamic lat, dynamic lng) {
    double _lat = double.parse(lat.toString());
    double _lng = double.parse(lng.toString());

    return Position(_lat, _lng);
  }
}
