class InsideBuffers {
  static const String dashboardPageIndex = "dashboardPageIndex";
  static const String dashboardDate = "dashboardDate";
  static const String dashboardSyncDate = "dashboardSyncDate";
}

class _InsideBufferFlags {
  final bool notclear;

  const _InsideBufferFlags({this.notclear});
}

// класс синглтон для передач данных между разделенными частями приложения
class InsideBuffer {
  static final InsideBuffer _instance = InsideBuffer._internal();
  InsideBuffer._internal();
  factory InsideBuffer() => _instance;

  final Map<String, dynamic> _bufferMap = {};
  final Map<String, _InsideBufferFlags> _bufferFlags = {};

  List<DateTime> dashboardDateSync = []; // отдельно список дат на главном экране для синхронизации

  void put(String name, dynamic value,
      {bool notclearFlag = false, bool notIfExist = false}) {
    if (notIfExist) {
      if (_bufferMap.containsKey(name)) return;
    }

    _bufferMap[name] = value;
    _bufferFlags[name] = _InsideBufferFlags(notclear: notclearFlag);
  }

  dynamic get(String name,
      {bool notErrIfNotFound = false, String defaultValue = ""}) {
    if (!_bufferMap.containsKey(name)) {
      if (notErrIfNotFound) {
        return defaultValue;
      }

      throw "Item $name not found";
    }

    _InsideBufferFlags flags = _bufferFlags[name];

    final dynamic item = _bufferMap[name];
    if (!flags.notclear) _bufferMap.remove(name);

    return item;
  }
}
