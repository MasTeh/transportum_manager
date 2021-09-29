import 'dart:async';

class ChangesListeners {
  static String ordersList = "ordersList";
  static String mainScreen = "mainScreen";
  static String orderDetails = "orderDetails";
  static String dashboardPageChanged = "dashboardPageChanged";
  static String dashboardDateChanged = "dashboardDateChanged";
  static String dashboardLoadNewStack = "dashboardLoadNewStack";
}

class ChangesListener {
  // singletone
  static final ChangesListener _instance = ChangesListener._internal();

  ChangesListener._internal();

  Map<String, Map<String, dynamic>> _listeners = {};
  Timer _checker;

  ChangesListener() {
    _checker = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (_listeners.length > 0) {
        _listeners.forEach((name, value) {
          _checkTaskEndStart(name);
        });
      }
    });
  }

  void _checkTaskEndStart(name) {
    if (_listeners[name]['state'] == true) {
      Function listFunc = _listeners[name]['func'];
      _listeners[name]['state'] = false;
      listFunc();
      print("Listener $name reacted");
    }
  }

  void setListener(String name, Function func) {
    _listeners[name] = {"state": false, "func": func};
  }

  void removeListener(String name) {
    if (_listeners.containsKey(name)) {
      _listeners.remove(name);
    } else {
      print("Listener $name not found");
    }
  }

  void emitt(String name) {
    if (_listeners.containsKey(name)) {
      _listeners[name]["state"] = true;
      //print("Emitted " + name);
    } else {
      print("Listener $name not found");
    }
  }
}
