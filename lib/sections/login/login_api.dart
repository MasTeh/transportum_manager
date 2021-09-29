import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/network/socket.dart';

class LoginApiErrors {
  static const int userNotAccess = 0;
  static const int userDeleted = 1;
  static const int userNotManager = 2;
  static const int clientNotFound = 3;

  final Map<int, String> errorMessages = {
    0: "Ошибка авторизации: неправильный логин ИЛИ пароль, либо и то, и другое",
    1: "Ошибка авторизации: доступ приостановлен",
    2: "Данная учётная запись не является менеджерской",
    3: "Некорректно указан ID клиента (такого клиента нет в базе)"
  };

  String getErrorMessage(int errorCode) {
    return errorMessages[errorCode];
  }
}

class LoginApiMode {
  static int autologin = 0;
  static int manual = 1;
}

class LoginApi {
  void getUserByHash(String hash, int userId, int clientId) {
    SocketQuery query = SocketQuery("get_user_by_hash")
        .addParam('hash', hash)
        .addParam('user_id', userId)
        .addParam('client_id', clientId);

    _loginQuery(query);
  }

  void loginUser(String login, String password, String clientId) {
    SocketQuery query = SocketQuery("login")
        .addParam('client_login', clientId)
        .addParam('login', login)
        .addParam('password', password);

    this._loginQuery(query);
  }

  void _loginQuery(SocketQuery query) {
    TransportumSocket().query(query, callback: (dynamic response) {
      int errorCode;

      try {
        if (response['result'] == 'not_client') {
          errorCode = LoginApiErrors.clientNotFound;
          this.onError(LoginApiErrors().getErrorMessage(errorCode));
          return;
        }

        if (response['result'] == 'not_user') {
          errorCode = LoginApiErrors.userNotAccess;
          this.onError(LoginApiErrors().getErrorMessage(errorCode));
          return;
        }

        if (response['result'] == 'found') {
          if (response['user']['deleted'] == 1) {
            errorCode = LoginApiErrors.userDeleted;
            this.onError(LoginApiErrors().getErrorMessage(errorCode));
            return;
          }

          if (response['user']['type'] != 1) {
            errorCode = LoginApiErrors.userNotManager;
            this.onError(LoginApiErrors().getErrorMessage(errorCode));
            return;
          }

          this.onSuccess(response);
        }
      } catch (err) {
        log.e(err);
      }
    });
  }

  void Function(String message) onError;
  void Function(Map<String, dynamic> jsonData) onSuccess;

  LoginApi setOnErrorListener(Function(String message) callback) {
    this.onError = callback;
    return this;
  }

  LoginApi setOnSuccessListener(
      Function(Map<String, dynamic> jsonData) callback) {
    this.onSuccess = callback;
    return this;
  }
}
