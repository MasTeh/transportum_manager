import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:transportumformanager/entity/contact.dart';
import 'package:transportumformanager/helper/month_names.dart';
import 'package:transportumformanager/helper/remove_decimal_zero.dart';

mixin OrderStates {
  static const int setted = 0;
  static const int active = 1;
  static const int done = 2;
  static const int problem = 3;
  static const int sended1c = 4;
  static const int paid1c = 5;

  static const Map<int, String> _names = {
    0: "Назначено",
    1: "Выполняется",
    2: "Завершено",
    3: "Проблема",
    4: "Выставлен счет",
    5: "Счет оплачен",
  };

  static String getName(int stateCode) {
    return OrderStates._names[stateCode];
  }
}

class OrderContact extends Contact {
  final isEmpty;
  OrderContact(String name, String phone, this.isEmpty) : super(name, phone);

  factory OrderContact.build(String name, String phone) {
    if (phone == "")
      return OrderContact(null, null, true);
    else
      return OrderContact(name, phone, false);
  }

  bool notName() {
    if (this.name == null) return true;
    if (this.name == "")
      return true;
    else
      return false;
  }
}

enum OrderPayMethod { hours, fixprice }
enum OrderNds { withNds, withoutNds }
enum OrderCash { bank, cash }

class OrderModel {
  final int id;
  final int trandportId;
  final int driverId;
  final DateTime date;
  final String time;
  final String carNumber;
  final bool haveTrailer;
  final String cargoDesc;
  final String cargoType;
  final int status;
  final int managerId;
  final String managerLogin;
  final int companyId;
  final String companyName;
  final String addressFromShort;
  final String addressFromLong;
  final String addressFrom2;
  final String addressFrom3;
  final String addressFrom4;
  final String addressDestShort;
  final String addressDestLong;
  final String coordsFrom;
  final String coordsDest;
  final OrderContact loadContact1;
  final OrderContact loadContact2;
  final OrderContact loadContact3;
  final OrderContact unloadContact1;
  final OrderContact unloadContact2;
  final OrderContact unloadContact3;
  final double priceSummary; // общая цена заказа
  final double priceSeller; // цена поставщшика
  final double pricePerHour; // цена в час
  final OrderPayMethod orderPayMethod;
  final OrderNds orderNds;
  final OrderCash orderCash;
  final double hours;
  final double hoursForDriver;
  final int pieces;
  final int orderNum;

  const OrderModel(
      this.id,
      this.trandportId,
      this.driverId,
      this.date,
      this.time,
      this.carNumber,
      this.haveTrailer,
      this.cargoDesc,
      this.cargoType,
      this.status,
      this.managerId,
      this.managerLogin,
      this.companyId,
      this.companyName,
      this.addressFromShort,
      this.addressFromLong,
      this.addressFrom2,
      this.addressFrom3,
      this.addressFrom4,
      this.addressDestShort,
      this.addressDestLong,
      this.coordsFrom,
      this.coordsDest,
      this.loadContact1,
      this.loadContact2,
      this.loadContact3,
      this.unloadContact1,
      this.unloadContact2,
      this.unloadContact3,
      this.priceSummary,
      this.priceSeller,
      this.pricePerHour,
      this.orderPayMethod,
      this.orderNds,
      this.orderCash,
      this.hours,
      this.hoursForDriver,
      this.pieces,
      this.orderNum);

  factory OrderModel.fromJSON(dynamic jsonData) {
    bool _trailerFlag = false;

    if ((jsonData['trailer']).toString() == 'С прицепом') {
      _trailerFlag = true;
    }

    int _status = jsonData['status'] as int;

    if ((jsonData['exported'] as int) == 1) _status = 4;
    if ((jsonData['invoice_uid'] as String) != "") _status = 4;
    if ((jsonData['paid_status'] as String) == "Оплачен") _status = 5;

    var _loadContact1 = OrderContact.build(
        jsonData['load_phone'] as String, jsonData['contact']);
    var _loadContact2 = OrderContact.build(
        jsonData['load_phone2'] as String, jsonData['contact2']);
    var _loadContact3 = OrderContact.build(
        jsonData['load_phone3'] as String, jsonData['contact3']);

    var _unloadContact1 = OrderContact.build(
        jsonData['unload_phone'] as String, jsonData['contact_unload']);
    var _unloadContact2 = OrderContact.build(
        jsonData['unload_phone2'] as String, jsonData['contact2_unload']);
    var _unloadContact3 = OrderContact.build(
        jsonData['unload_phone3'] as String, jsonData['contact3_unload']);

    double _priceSummary = double.parse(jsonData['order_price'].toString() ?? "0");
    double _priceSeller = double.parse(jsonData['seller_price'].toString() ?? "0");
    double _pricePerHour = double.parse(jsonData['hour_price'].toString() ?? "0");
    double _hours = double.parse(jsonData['hours'].toString() ?? "0");

    double _hoursForDriver = double.parse(jsonData['hours2'].toString() ?? "0");

    var _payMethod = OrderPayMethod.hours;
    var _orderNds = OrderNds.withNds;
    var _orderCash = OrderCash.bank;
    var _pieces = jsonData['pieces'] as int;

    if (_pieces > 0) _payMethod = OrderPayMethod.fixprice;

    if ((jsonData['nds'] as String) == "Безнал с НДС") {
      _orderNds = OrderNds.withNds;
      _orderCash = OrderCash.bank;
    } else if ((jsonData['nds'] as String) == "Безнал без НДС") {
      _orderNds = OrderNds.withoutNds;
      _orderCash = OrderCash.bank;
    } else if ((jsonData['nds'] as String) == "Наличный") {
      _orderNds = OrderNds.withoutNds;
      _orderCash = OrderCash.cash;
    }
    var log = Logger();

    DateTime _orderDate = DateTime.parse(jsonData['flutterdate'].toString());

    String _time = jsonData['time'] as String;

    /*try {
      var _timesplited = _time.split(':');
      _orderDate = DateTime(
          _orderDate.year,
          _orderDate.month,
          _orderDate.day,
          int.parse(_timesplited[0].toString()),
          int.parse(_timesplited[1].toString()));
    } catch (err) {
      print("OrderModel datetime parsing ERROR!!!");
    }*/

    return OrderModel(
        jsonData['id'] as int,
        jsonData['transport_id'] as int,
        jsonData['driver_id'] as int,
        _orderDate,
        _time,
        "", // car number устарело
        _trailerFlag,
        jsonData['cargo_desc'] as String ?? "",
        jsonData['cargo_type'] as String ?? "",
        _status,
        jsonData['manager_id'] as int,
        jsonData['manager_login'] as String ?? "n/a",
        jsonData['company_id'] as int,
        jsonData['company_name'] as String ?? "", // company name устарело
        jsonData['load_address_short'] as String ?? "",
        jsonData['load_address'] as String ?? "",
        jsonData['load_address2'] as String ?? "",
        jsonData['load_address3'] as String ?? "",
        jsonData['load_address4'] as String ?? "",
        jsonData['unload_address_short'] as String ?? "",
        jsonData['unload_address'] as String ?? "",
        jsonData['load_address_coords'] as String ?? "",
        jsonData['unload_address_coords'] as String ?? "",
        _loadContact1,
        _loadContact2,
        _loadContact3,
        _unloadContact1,
        _unloadContact2,
        _unloadContact3,
        _priceSummary,
        _priceSeller,
        _pricePerHour,
        _payMethod,
        _orderNds,
        _orderCash,
        _hours,
        _hoursForDriver,
        _pieces,
        jsonData['order_num'] as int);
  }

  dynamic toJSON({bool withUpdateId = false}) {
    Map<String, dynamic> json = {};

    if (withUpdateId) json['is_update'] = id;

    json['transport_id'] = this.trandportId;
    json['driver_id'] = this.driverId;
    json['manager_id'] = this.managerId;
    json['date'] = DateFormat('yyyy-MM-dd').format(this.date);
    json['time'] = this.time ?? "00:00";
    json['trailer'] = this.getTrailerLabelLong();
    json['cargo_desc'] = this.cargoDesc;
    json['cargo_type'] = this.cargoType;
    json['company_id'] = this.companyId;
    json['load_address_short'] = this.addressFromShort;
    json['load_address'] = this.addressFromLong;
    json['load_address2'] = this.addressFrom2 ?? "";
    json['load_address3'] = this.addressFrom3 ?? "";
    json['load_address4'] = this.addressFrom4 ?? "";
    json['unload_address_short'] = this.addressDestShort ?? "";
    json['unload_address'] = this.addressDestLong ?? "";
    json['load_address_coords'] = this.coordsFrom ?? "";
    json['unload_address_coords'] = this.coordsDest ?? "";
    json['load_phone'] = this.loadContact1.phone ?? "";
    json['load_phone2'] = this.loadContact2.phone ?? "";
    json['load_phone3'] = this.loadContact3.phone ?? "";
    json['contact'] = this.loadContact1.name ?? "";
    json['contact2'] = this.loadContact2.name ?? "";
    json['contact3'] = this.loadContact3.name ?? "";
    json['unload_phone'] = this.unloadContact1.phone ?? "";
    json['unload_phone2'] = this.unloadContact2.phone ?? "";
    json['unload_phone3'] = this.unloadContact3.phone ?? "";
    json['contact_unload'] = this.unloadContact1.name ?? "";
    json['contact2_unload'] = this.unloadContact2.name ?? "";
    json['contact3_unload'] = this.unloadContact3.name ?? "";
    json['nds'] = this.getCashAndNdsLabel();
    json['pieces'] = this.pieces ?? 0;
    json['order_price'] = this.priceSummary ?? 0;
    json['seller_price'] = this.priceSeller ?? 0;
    json['hour_price'] = this.pricePerHour ?? 0;
    json['hours'] = this.hours ?? 0;
    json['hours2'] = this.hoursForDriver ?? 0;
    json['order_num'] = this.orderNum;

    return json;
  }

  String getPaymentMethodLabel() {
    if (orderNds == OrderNds.withNds) return "Безнал с НДС";
    if (orderNds == OrderNds.withoutNds && orderCash == OrderCash.bank)
      return "Безнал без НДС";
    if (orderCash == OrderCash.cash) return "Наличный";
  }

  String getPriceSummary() {
    return removeDecimalZeroFormat(this.priceSummary);
  }

  String getPriceSeller() {
    return removeDecimalZeroFormat(this.priceSeller);
  }

  String getPricePerHour() {
    return removeDecimalZeroFormat(this.pricePerHour);
  }

  String getHours() {
    return removeDecimalZeroFormat(this.hours);
  }

  String getHoursForDriver() {
    return removeDecimalZeroFormat(this.hoursForDriver);
  }

  double getMarja() {
    return (this.priceSummary - this.priceSeller);
  }

  String getMarjaString() {
    return removeDecimalZeroFormat(this.getMarja());
  }

  String getCashAndNdsLabel() {
    var _label = "";
    if (this.orderCash == OrderCash.bank) _label = "Безнал";

    if (this.orderNds == OrderNds.withNds) _label += " с НДС";
    if (this.orderNds == OrderNds.withoutNds) _label += " без НДС";

    if (this.orderCash == OrderCash.cash) _label = "Наличный";

    return _label;
  }

  bool notDestination() {
    if (this._paramEmpty(this.addressDestLong) ||
        this._paramEmpty(this.addressDestShort))
      return true;
    else
      return false;
  }

  bool _paramEmpty(param) {
    if (param == null) return true;
    if (param == "") return true;

    return false;
  }

  String getGeoDest() {
    if (!this._paramEmpty(this.coordsDest)) {
      return this.coordsDest;
    } else {
      return this.addressDestLong;
    }
  }

  String getGeoFrom() {
    if (!this._paramEmpty(this.coordsFrom)) {
      return this.coordsFrom;
    } else {
      return this.addressFromLong;
    }
  }

  String getDay() {
    int monthNum = date.month - 1;
    return "${this.date.day} ${MonthNames.short[monthNum]}";
  }

  String getTrailerLabelLong() {
    if (this.haveTrailer)
      return "С прицепом";
    else
      return "Без прицепа";
  }

  String getTrailerLabelShort() {
    if (this.haveTrailer)
      return "+ ПРИЦ";
    else
      return "";
  }

  String getStatusLabel() {
    return OrderStates.getName(this.status);
  }

  TextStyle getStatusLabelStyle({double fontSize = 14}) {
    if (this.status == OrderStates.active)
      return TextStyle(color: Colors.blue[900], fontSize: fontSize);

    if (this.status == OrderStates.done)
      return TextStyle(color: Colors.green[900], fontSize: fontSize);

    if (this.status == OrderStates.problem) return TextStyle(color: Colors.red);

    if (this.status == OrderStates.sended1c)
      return TextStyle(color: Colors.green[800], fontSize: fontSize);

    if (this.status == OrderStates.paid1c)
      return TextStyle(
          color: Colors.green[800],
          fontWeight: FontWeight.bold,
          fontSize: fontSize);

    return TextStyle(color: Colors.grey, fontSize: fontSize);
  }
}
