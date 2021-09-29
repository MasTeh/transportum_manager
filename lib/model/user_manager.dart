import 'dart:convert';

import 'package:transportumformanager/entity/person.dart';
import 'package:transportumformanager/interface/UserDetails.dart';
import 'package:transportumformanager/interface/UserRole.dart';

class UserRoleNames {
  static final String admin = "Администратор";
  static final String manager = "Менеджер";
  static final String owner = "Владелец";
}

class UserManager extends Person implements UserDetails, UserRole {
  final bool isSuperAdmin;
  final int client_id;

  const UserManager(
      int userId,
      String fam,
      String name,
      String otch,
      String phone,
      String login,
      String password,
      this.isSuperAdmin,
      this.client_id)
      : super(userId, fam, name, otch, phone, login, password);

  factory UserManager.fromJSON(Map<String, dynamic> jsonData) {
    bool _isSuperAdmin = false;
    if (jsonData.containsKey('superadmin')) {
      int superAdmin = jsonData['superadmin'];
      if (superAdmin == 1) _isSuperAdmin = true;
    }

    return UserManager(
        jsonData['id'] as int,
        jsonData['fam'] as String,
        jsonData['name'] as String,
        jsonData['otch'] as String,
        jsonData['phone'] as String,
        jsonData['login'] as String,
        jsonData['password'] as String,
        _isSuperAdmin,
        jsonData['client_id'] as int);
  }

  @override
  String fullFIO() {
    var elements = [this.fam, this.name, this.otch];
    return elements.join(" ");
  }

  @override
  String shortFIO() {
    var elements = [this.fam, name.length > 0 ? ((this.name)[0] + ".") : "", otch.length > 0 ? ((this.otch)[0] + "."):""];
    return elements.join(" ");
  }

  @override
  String firstLastName() {
    var elements = [this.fam, this.name];
    return elements.join(" ");
  }
  

  @override
  String roleLabel() {
    if (this.isSuperAdmin)
      return UserRoleNames.admin;
    else
      return UserRoleNames.manager;
  }
}
