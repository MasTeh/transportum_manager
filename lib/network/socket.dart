import 'dart:async';
import 'dart:convert';

import 'package:transportumformanager/global/ChangesListener.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';
import 'package:transportumformanager/network/query.dart';
import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:logger/logger.dart';
import 'dart:math';

final log = Logger();

class TransportumSocket {
  static final TransportumSocket _singleton = TransportumSocket._internal();

  var _socket;
  final String wssAddress = 'wss://transportum.ru';
  Map<int, Function> _queryStack = {};
  bool inited = false;

  int _lastPingTimestamp = 0;

  factory TransportumSocket() {
    return _singleton;
  }

  TransportumSocket._internal();

  Timer _pingChecker;

  int ping = 0;
  int _clientId;

  Future<void> init() async {
    _socket = await IOWebSocketChannel.connect(wssAddress);

    this.inited = true;

    log.i("Connectiong WebSocket");

    _pingChecker = Timer.periodic(Duration(milliseconds: 500), (pingChecker) {
      int currentStamp = DateTime.now().millisecondsSinceEpoch;
      int newPing = currentStamp - _lastPingTimestamp;
      if (newPing > 0) this.ping = newPing;

      if (this.ping > 5000) {
        _pingChecker.cancel();
        _socket = null;
        _socket = this.init();
        log.v("Reconnect");
      }
    });

    _socket.stream.listen((message) {
      Map<String, dynamic> msgJSON = jsonDecode(message);
      String type = msgJSON["type"];

      if (type == "ping") {
        _lastPingTimestamp = new DateTime.now().millisecondsSinceEpoch;
      }

      if (type == "console") {
        log.i(msgJSON["message"]);
      }

      if (type == "server-event") {
        log.i(msgJSON["action"]);
        log.i(msgJSON);

        String action = msgJSON["action"];

        if (action == "update_desk") {
          AppData().changeListener.emitt(ChangesListeners.dashboardPageUpdate);
        }
      }

      if (type == "query_send") {
        final Map<String, dynamic> emptyResult = {"result": "empty"};
        final Map<String, dynamic> errorResult = {
          "result": "error",
          "error": "JsonParseError"
        };
        int qid = msgJSON["qid"];
        if (_queryStack.containsKey(qid)) {
          String jsonString;
          Map<String, dynamic> jsonObject = {};
          if (msgJSON["flutterdata"] != null) {
            try {
              jsonString = msgJSON["flutterdata"].toString();
              if (jsonString == '[]' ||
                  jsonString == '{}' ||
                  jsonString == '' ||
                  jsonString == null) {
                jsonObject = emptyResult;
              } else {
                jsonObject = Map<String, dynamic>.from(msgJSON["flutterdata"]);
              }
            } catch (err) {
              log.e(err);
              jsonObject = errorResult;
            }
          } else {
            try {
              //log.w(msgJSON['data']);
              jsonString = msgJSON["data"].toString();
              if (jsonString == '[]' ||
                  jsonString == '{}' ||
                  jsonString == '' ||
                  jsonString == null) {
                jsonObject = emptyResult;
              } else {
                jsonObject = Map<String, dynamic>.from(msgJSON["data"]);
              }
            } catch (err) {
              log.e("Error query: " + msgJSON.toString());
              log.e(err);
              jsonObject = errorResult;
            }
          }

          _queryStack[qid](jsonObject);
        }
        //log.i(msgJSON);
      }
    });
  }

  int _randNum() {
    Random random = new Random();
    int randomInt = random.nextInt(1000);

    if (_queryStack.containsKey(randomInt))
      this._randNum();
    else
      return randomInt;
  }

  void setClientId(int client_id) {
    this._clientId = client_id;
  }

  int getClientId() {
    return _clientId;
  }

  Future<dynamic> queryAsync(SocketQuery socketQuery) {
    Completer completer = Completer();
    query(socketQuery, callback: (response) {
      completer.complete(response);
    });

    return completer.future;
  }

  void query(SocketQuery query, {Function callback, bool withoutClientID}) {
    if (!inited) init();

    int qId = this._randNum();
    Map<String, dynamic> querySend = {};
    querySend['qid'] = qId;
    querySend['type'] = 'query_send';

    if (this._clientId != null && withoutClientID != true) {
      querySend['client_id'] = this._clientId;
    }

    querySend['params'] = query.build();

    //log.v(querySend);

    _socket.sink.add(jsonEncode(querySend));
    _queryStack[qId] = callback;
  }
}
