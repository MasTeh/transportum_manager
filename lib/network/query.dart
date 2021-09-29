import 'dart:collection';

class SocketQuery {
  final String action;
  final Map<String, dynamic> params = {};

  SocketQuery(this.action) {
    this.params['action'] = this.action;
  }

  SocketQuery addParam(String name, dynamic value) {
    this.params[name] = value;
    return this;
  }

  Map<String, dynamic> build() {
    return params;
  }
}
