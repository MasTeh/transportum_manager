import 'package:flutter/cupertino.dart';

enum PhotoOwner { drivers, orders, repair, transport }

class PhotoModel {
  @required
  final int id;
  @required
  final int client_id;
  @required
  final int item_id;
  @required
  final PhotoOwner owner;
  @required
  final String photoSmallURL;
  @required
  final String photoBigURL;
  @required
  final DateTime created;

  const PhotoModel(this.id, this.client_id, this.item_id, this.owner,
      this.photoSmallURL, this.photoBigURL, this.created);

  factory PhotoModel.fromJSON(Map<String, dynamic> jsonData) {
    PhotoOwner photoOwner;
    if (jsonData['owner'].toString() == "transport")
      photoOwner = PhotoOwner.transport;
    if (jsonData['owner'].toString() == "orders")
      photoOwner = PhotoOwner.transport;
    if (jsonData['owner'].toString() == "repair")
      photoOwner = PhotoOwner.transport;
    if (jsonData['owner'].toString() == "drivers")
      photoOwner = PhotoOwner.transport;

    DateTime created = DateTime.parse(jsonData['created'] as String);

    return PhotoModel(
        jsonData['id'] as int,
        jsonData['client_id'] as int,
        jsonData['item_id'] as int,
        photoOwner,
        jsonData['photo500'],
        jsonData['photo'],
        created);
  }

  static String getStringOwner(PhotoOwner owner) {
    return ((owner.toString()).split('.')).last;
  }
}
