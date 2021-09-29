import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transportumformanager/helper/toast.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';
import 'package:transportumformanager/sections/home/home.dart';
import 'package:transportumformanager/model/user_manager.dart';
import 'package:transportumformanager/sections/login/login_api.dart';
import 'package:transportumformanager/widgets/preloaders.dart';
import 'dart:async';
import '../../helper/dialogs.dart';
import '../../network/socket.dart';
import 'package:logger/logger.dart';

final log = Logger();

class LoginPage extends StatefulWidget {
  final String title = "Авторизация";

  LoginPage({Key key, title}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  Timer onlineChecker;
  String logoVariant = "assets/logo-offline.png";

  final clientIdController = TextEditingController();
  final loginController = TextEditingController();
  final passwordController = TextEditingController();

  LoginApi autologinApi = LoginApi();

  double _loadingHeightRegulator = 0;
  CrossFadeState _loadingFadeState = CrossFadeState.showFirst;

  bool _animationFinished = false;
  bool _prefsInited = false;

  bool disposed = false;

  int _blockNum = 0;

  SharedPreferences prefs;

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    AppData().prefs = prefs;
    _prefsInited = true;
  }

  @override
  void initState() {
    super.initState();

    log.i("INIT STATE");

    initPrefs();
    startShow();

    autologinApi.setOnSuccessListener((response) {
      
      AppData().clientName = response['client_name'];

      //AppData().role = response['user']['role'];

      var jsonUser = response['user'];
      log.i(jsonUser);
      var user = UserManager.fromJSON(jsonUser);
      TransportumSocket().setClientId(user.client_id);
      log.i("CLIENT_ID=${TransportumSocket().getClientId()} setted");
      log.i("User logged client_id=${user.client_id}, user_id=${user.id}");
      AppData().setCurrentUser(user);

      prefs.setInt("user_id", response['user']['id']);
      prefs.setInt("client_id", response['user']['client_id']);
      prefs.setString("hash", response['user']['password']);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }).setOnErrorListener((String errorMessage) {
      Dialogs.showAlert(context, "Неудача", errorMessage);
      restoreLoginForm();
    });

    onlineChecker = new Timer.periodic(Duration(seconds: 1), (onlineChecker) {
      int ping = TransportumSocket().ping;

      if (ping > 1000 || ping == 0) {
        setState(() {
          logoVariant = "assets/logo-offline.png";
        });
      } else {
        setState(() {
          logoVariant = "assets/logo-online.png";
          if (_prefsInited) {
            onlineChecker.cancel();
            startAuth();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double formWidth = MediaQuery.of(context).size.width * 0.8;

    Widget loginForm = Container(
        width: formWidth,
        child: Form(
          child: Column(children: [
            TextFormField(
              autofocus: false,
              textInputAction: TextInputAction.next,
              controller: clientIdController,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  labelText: "ID клиента",
                  labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Monserat")),
            ),
            TextFormField(
              autofocus: false,
              textInputAction: TextInputAction.next,
              controller: loginController,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  labelText: "Логин",
                  labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Monserat")),
            ),
            TextFormField(
              obscureText: true,
              textInputAction: TextInputAction.done,
              autofocus: false,
              controller: passwordController,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.https_outlined, color: Colors.white),
                  labelText: "Пароль",
                  labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Monserat")),
            ),
            Padding(padding: EdgeInsets.only(top: 30)),
            FlatButton(
                onPressed: () {
                  onLoginButtonClick();
                },
                child: Padding(
                    padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                    child: Text("Войти в систему",
                        style: TextStyle(
                            color: Colors.green[50],
                            fontSize: 20,
                            fontFamily: "Monserat"))))
          ]),
        ));

    Widget loadingForm = AnimatedContainer(
        duration: Duration(seconds: 1),
        height: _loadingHeightRegulator,
        curve: Curves.easeInOutCubic,
        child: AnimatedCrossFade(
            duration: Duration(milliseconds: 1000),
            crossFadeState: _loadingFadeState,
            firstChild: Container(height: 100),
            secondChild: Column(children: [
              Padding(padding: EdgeInsets.only(top: 20)),
              Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text("Установка связи...",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Monserat",
                          fontSize: 20))),
              CenterPreloader()
            ])));

    Widget currentVisibleBlock = loadingForm;

    if (_blockNum == 1) currentVisibleBlock = loginForm;

    return Scaffold(
        backgroundColor: Color(0xFF22bd01),
        body: Center(
            child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF21ba00), Color(0xFF0c5600)],
          )),
          child: Center(
              child: ListView(
                  padding: EdgeInsets.fromLTRB(30, 100, 30, 0),
                  children: [
                Container(
                    child: Image.asset(logoVariant, width: 150), height: 150),
                currentVisibleBlock
              ])),
        )));
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  void startShow() {
    Future.delayed(Duration(seconds: 1), () {
      if (disposed) return;
      Future.delayed(Duration(seconds: 1), () {
        if (disposed) return;
        setState(() {
          _loadingFadeState = CrossFadeState.showSecond;

          Future.delayed(Duration(seconds: 1), () {
            _animationFinished = true;
          });
        });
      });

      setState(() {
        _loadingHeightRegulator = 120;
      });
    });
  }

  void startAuth() {
    int user_id = prefs.getInt("user_id");
    int client_id = prefs.getInt("client_id");
    String hash = prefs.getString("hash");

    log.i('user_id=' + user_id.toString());
    log.i('client_id=' + client_id.toString());
    log.i('password=' + hash.toString());

    if (user_id == null || hash == null || client_id == null) {
      restoreLoginForm();

      return;
    }

    autologinApi.getUserByHash(hash, user_id, client_id);
  }

  void restoreLoginForm() {
    prefs.remove("user_id");
    prefs.remove("hash");
    prefs.remove("client_id");

    loginController.text = "";
    passwordController.text = "";
    clientIdController.text = "";

    setState(() {
      _blockNum = 1;
    });
  }

  void onLoginButtonClick() {
    if (loginController.text == "" || passwordController.text == "") {
      Dialogs.showAlert(context, "Ошибка", "Логин или пароль не был заполнен");

      return;
    }

    LoginApi().setOnSuccessListener((response) {
      prefs.setInt("user_id", response['user']['id']);
      prefs.setInt("client_id", response['user']['client_id']);
      prefs.setString("hash", response['user']['password']);

      startAuth();
    }).setOnErrorListener((errorMessage) {
      Dialogs.showAlert(context, "Неудача", errorMessage);
      restoreLoginForm();
    }).loginUser(
        loginController.text, passwordController.text, clientIdController.text);

  }
}
