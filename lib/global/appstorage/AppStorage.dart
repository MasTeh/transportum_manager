import 'package:logger/logger.dart';
import 'package:transportumformanager/global/appstorage/AppStorage_api.dart';
import 'package:transportumformanager/model/company.dart';
import 'package:transportumformanager/model/transport.dart';
import 'package:transportumformanager/model/user_driver.dart';
import 'package:transportumformanager/model/user_manager.dart';

// класс синглтон для хранения сущностей
// водители, транспорты, нераспред заявки, и т п

class AppStorage {
  static final AppStorage _instance = AppStorage._internal();
  AppStorage._internal();
  factory AppStorage() {
    return _instance;
  }

  final log = Logger();

  final Map<int, UserDriver> drivers = {};
  final Map<int, Transport> transports = {};
  final Map<int, Company> companies = {};
  final Map<int, UserManager> managers = {};

  void updateAllStorages() {
    updateTransports();
    updateDrivers();
    updateCompanies();
    updateManagers();
  }

  // Transport block start

  void updateTransports() async {
    List<dynamic> jsonItems = await AppStorageApi().getTransports();
    try {
      jsonItems.forEach((element) {
        transports[element['id'] as int] = Transport.fromJSON(element);
      });
    } catch (err) {
      log.e(err);
    }
  }

  Transport getTransport(int transportId) {
    if (!transports.containsKey(transportId))
      throw "Transport ID=$transportId not found";

    return transports[transportId];
  }

  Transport getTransportSafe(int transportId) {
    try {
      if (!transports.containsKey(transportId)) return null;
      return transports[transportId];
    } catch (err) {
      return null;
    }
  }

  // Transport block end

  // Driver block start

  void updateDrivers() async {
    Map<String, dynamic> jsonReponse = await AppStorageApi().getDrivers();
    try {
      var jsonItems = List<dynamic>.from(jsonReponse['items']);
      jsonItems.forEach((element) {
        drivers[element['id'] as int] = UserDriver.fromJSON(element);
      });
    } catch (err) {
      log.e(err);
    }
  }

  UserDriver getDriver(int userId) {
    if (!drivers.containsKey(userId)) throw "Driver ID=$userId not found";

    return drivers[userId];
  }

  UserDriver getDriverSafe(int userId) {
    if (!drivers.containsKey(userId)) return null;

    return drivers[userId];
  }

  bool driverExist(int userId) {
    if (!drivers.containsKey(userId))
      return false;
    else
      return true;
  }

  // Driver block end

  // Company block start

  void updateCompanies() async {
    try {
      List<dynamic> jsonItems = await AppStorageApi().getCompanies();
      jsonItems.forEach((element) {
        companies[element['id'] as int] = Company.fromJSON(element);
      });
    } catch (err) {
      log.e(err);
    }
  }

  Company getCompany(int companyId) {
    if (!companies.containsKey(companyId))
      throw "Company ID=$companyId not found";

    return companies[companyId];
  }

  Company getCompanySafe(int companyId) {
    if (!companies.containsKey(companyId)) 
      return null;
    else
      return companies[companyId];
  }

  // Company block end

  // Managers block start

  void updateManagers() async {
    try {
      List<dynamic> jsonItems = await AppStorageApi().getManagers();
      jsonItems.forEach((element) {
        managers[element['id'] as int] = UserManager.fromJSON(element);
      });
    } catch (err) {
      log.e(err);
    }
  }

  UserManager getManager(int managerId) {
    if (!managers.containsKey(managerId))
      throw "Manager ID=$managerId not found";

    return managers[managerId];
  }

  UserManager getManagerSafe(int managerId) {
    try {
      if (!managers.containsKey(managerId)) return null;
      return managers[managerId];
    } catch (err) {
      return null;
    }
  }

  // Managers block end
}
