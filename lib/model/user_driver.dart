import 'dart:convert';

import 'package:transportumformanager/entity/person.dart';
import 'package:transportumformanager/interface/UserDetails.dart';
import 'package:transportumformanager/model/position.dart';

class UserDriver extends Person implements UserDetails {
  final int client_id;
  final String photoUrl;
  final bool isMechanic;
  final bool isOwn;
  final Position position;
  final String passport;
  final bool isDeleted;

  const UserDriver(
      int userId,
      String fam,
      String name,
      String otch,
      String phone,
      String login,
      String password,
      this.client_id,
      this.photoUrl,
      this.isMechanic,
      this.isOwn,
      this.position,
      this.passport,
      this.isDeleted)
      : super(userId, fam, name, otch, phone, login, password);

  factory UserDriver.fromJSON(Map<String, dynamic> jsonData) {
    bool _isMechanic = false;
    bool _isOwn = false;
    bool _isDeleted = false;
    Position _position;

    if (jsonData.containsKey('is_mechanic')) {
      int _fieldValue = jsonData['is_mechanic'] as int;
      if (_fieldValue == 1) _isMechanic = true;
    }

    if (jsonData.containsKey('is_own')) {
      bool _fieldValue = jsonData['is_own'] as bool;
      if (_fieldValue == true) _isOwn = true;
    }

    if (jsonData.containsKey('deleted')) {
      int _fieldValue = jsonData['deleted'] as int;
      if (_fieldValue == 1) _isDeleted = true;
    }

    if (jsonData.containsKey('lat') && jsonData.containsKey('lng')) {
      String _lat = jsonData['lat'] as String;
      String _lng = jsonData['lng'] as String;
      if (_lat != "" && _lng != "") {
        _position = Position.fromStrings(_lat, _lng);
      }
    }

    return UserDriver(
        jsonData['id'] as int,
        jsonData['fam'] as String,
        jsonData['name'] as String,
        jsonData['otch'] as String,
        jsonData['phone'] as String,
        jsonData['login'] as String,
        jsonData['password'] as String,
        jsonData['client_id'] as int,
        jsonData['photo'] as String,
        _isMechanic,
        _isOwn,
        _position,
        jsonData['passport'] as String,
        _isDeleted);
  }

  String fullFIO() {
    var elements = [this.fam, this.name, this.otch];
    return elements.join(" ");
  }

  String shortFIO() {
    var elements = [this.fam, name.length > 0 ? ((this.name)[0] + ".") : "", otch.length > 0 ? ((this.otch)[0] + "."):""];
    return elements.join(" ");
  }

  String firstLastName() {
    var elements = [this.fam, this.name];
    return elements.join(" ");
  }
}
