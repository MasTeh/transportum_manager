import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:transportumformanager/global/ChangesListener.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';
import 'package:transportumformanager/helper/app_functions.dart';
import 'package:transportumformanager/sections/login/login.dart';
import 'package:transportumformanager/network/socket.dart';
import 'package:transportumformanager/helper/dialogs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:transportumformanager/widgets/preloaders.dart';

final log = Logger();
final ImagePicker picker = ImagePicker();

Function appbarSaveButton;

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Профиль"),
          actions: [
            TextButton(
                onPressed: () {
                  if (appbarSaveButton != null) appbarSaveButton();
                },
                child: Text(
                  "Сохранить изменения",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: ProfileBody());
  }
}

class ProfileBody extends StatefulWidget {
  const ProfileBody({Key key}) : super(key: key);

  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  Map<String, List<Widget>> photos = {
    'drivers_passport': [],
    'drivers_document1': [],
    'drivers_otherdocuments': []
  };

  Map<String, int> photosPreloaders = {
    'drivers_passport': 0,
    'drivers_document1': 0,
    'drivers_otherdocuments': 0
  };

  var famInput = TextEditingController(text: AppData().getUser().fam);
  var nameInput = TextEditingController(text: AppData().getUser().name);
  var otchInput = TextEditingController(text: AppData().getUser().otch);
  var phoneInput =
      TextEditingController(text: AppData().getUser().phone);


  BuildContext profileContext;

  bool avatarIsLoading = false;

  void updateProfile() {
    

  }


  @override
  void initState() {
    super.initState();
    
  }



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.9;
    double leftWidth = screenWidth * 0.4;
    double rightWidth = screenWidth * 0.6;

    profileContext = context;

    var padding5 = EdgeInsets.all(5);
    var padding10 = EdgeInsets.all(10);


    appbarSaveButton = () {
      updateProfile();
    };

    return ListView(padding: EdgeInsets.all(20), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("Вы вошли как " + AppData().getUser().login,
            textAlign: TextAlign.right,
            style: new TextStyle(color: Colors.black54, fontSize: 14)),
        TextButton.icon(
            onPressed: () {
              AppData().prefs.clear();
              AppData().clear();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (r) => false);
            },
            icon: Icon(Icons.logout),
            label: Text("Выйти"))
      ]),
      Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Divider(
              color: Color(0xFFC5C2C2),
              height: 3,
              thickness: 3,
              indent: 0,
              endIndent: 0)),
      
      TextField(
        autofocus: false,
        controller: famInput,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
            labelText: "Фамилия",
            labelStyle: TextStyle(
                color: Colors.black, fontSize: 16, fontFamily: "Monserat")),
      ),
      TextField(
        autofocus: false,
        controller: nameInput,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
            labelText: "Имя",
            labelStyle: TextStyle(
                color: Colors.black, fontSize: 16, fontFamily: "Monserat")),
      ),
      TextField(
        autofocus: false,
        controller: otchInput,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
            labelText: "Отчество",
            labelStyle: TextStyle(
                color: Colors.black, fontSize: 16, fontFamily: "Monserat")),
      ),
      TextField(
        autofocus: false,
        controller: phoneInput,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
            labelText: "Телефон",
            labelStyle: TextStyle(
                color: Colors.black, fontSize: 16, fontFamily: "Monserat")),
      ),
      
      
      Container(
        padding: EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GridView.count(
                  crossAxisCount: 4,
                  children: photos['drivers_passport'],
                  shrinkWrap: true,
                  physics: BouncingScrollPhysics())
            ],
          ),
        ),
      ),
      Divider(
          color: Color(0xFFC5C2C2),
          height: 3,
          thickness: 3,
          indent: 0,
          endIndent: 0),
      
      
    ]);
  }
}
