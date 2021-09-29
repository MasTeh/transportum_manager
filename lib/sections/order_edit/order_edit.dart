import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transportumformanager/global/appstorage/AppStorage.dart';
import 'package:transportumformanager/helper/log.dart';
import 'package:transportumformanager/helper/remove_decimal_zero.dart';
import 'package:transportumformanager/helper/toast.dart';
import 'package:transportumformanager/model/order.dart';
import 'package:transportumformanager/model/transport.dart';
import 'package:transportumformanager/model/user_driver.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_company.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_day_piece.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_driver.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_manager.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_payment_method.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_transport.dart';
import 'package:transportumformanager/sections/order_edit/input_autocomplete.dart';
import 'package:transportumformanager/sections/order_edit/order_edit_api.dart';
import 'package:transportumformanager/widgets/dateInput.dart';
import 'package:transportumformanager/widgets/dateTimeInput.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class OrderEdit extends StatefulWidget {
  final OrderModel orderModel;
  final bool isDublicate;
  OrderEdit({Key key, this.orderModel, this.isDublicate = false})
      : super(key: key);

  @override
  _OrderEditState createState() => _OrderEditState();
}

enum OrderEditMode { add, edit, dublicate }
enum OrderType { transport, work }

class _OrderEditState extends State<OrderEdit> {
  OrderEditMode orderEditMode;
  OrderType orderType = OrderType.transport;
  OrderPayMethod orderPayMethod = OrderPayMethod.hours;

  OrderEditAPI orderEditApi = OrderEditAPI();

  var transportId = TextEditingController(text: "-1");
  var driverId = TextEditingController(text: "-1");
  var managerId = TextEditingController(text: "-1");
  var dateWeb = TextEditingController();
  var dateLabel = TextEditingController();
  var timeLabel = TextEditingController();
  var dayPiece = TextEditingController(text: "-1");
  var companyId = TextEditingController(text: "-1");
  var trailer = TextEditingController(text: "Без прицепа");
  var addressFromShort = TextEditingController();
  var addressFromFull = TextEditingController();
  var addressDestShort = TextEditingController();
  var addressDestFull = TextEditingController();

  var loadContact_phone1 = TextEditingController(text: "");
  var loadContact_phone2 = TextEditingController(text: "");
  var loadContact_phone3 = TextEditingController(text: "");
  var loadContact_name1 = TextEditingController(text: "");
  var loadContact_name2 = TextEditingController(text: "");
  var loadContact_name3 = TextEditingController(text: "");
  var unloadContact_phone1 = TextEditingController(text: "");
  var unloadContact_phone2 = TextEditingController(text: "");
  var unloadContact_phone3 = TextEditingController(text: "");
  var unloadContact_name1 = TextEditingController(text: "");
  var unloadContact_name2 = TextEditingController(text: "");
  var unloadContact_name3 = TextEditingController(text: "");

  var priceFull = TextEditingController(text: "");
  var priceHour = TextEditingController(text: "");
  var hours1 = TextEditingController(text: "");
  var hours2 = TextEditingController(text: "");
  var pieces = TextEditingController(text: "");
  var sellerPrice = TextEditingController(text: "");
  var payment_method = TextEditingController(text: "-1");

  int additionalContactCount1 = 0;
  int additionalContactCount2 = 0;

  // погрузка
  Widget _additionalContact1 = Container();
  Widget _additionalContact2 = Container();
  Widget _additionalContact3 = Container();

  // выгрузка
  Widget _additional_Contact1 = Container();
  Widget _additional_Contact2 = Container();
  Widget _additional_Contact3 = Container();

  @override
  void initState() {
    if (widget.orderModel == null)
      orderEditMode = OrderEditMode.add;
    else if (widget.isDublicate)
      orderEditMode = OrderEditMode.dublicate;
    else if (widget.orderModel != null) orderEditMode = OrderEditMode.edit;

    if (orderEditMode == OrderEditMode.add) {
      managerId.text = AppData().getUser().id.toString();
    }

    super.initState();
  }

  void transportChangedCallback(transportId) {
    Function clearDriver = () {
      this.driverId.text = "-1";
      setState(() {});
    };

    if (transportId == "-1") {
      clearDriver();
      return;
    }

    Transport transport =
        AppStorage().getTransportSafe(int.parse(transportId.toString()));

    if (transport == null) {
      clearDriver();
      return;
    }

    int driverId = transport.defaultDriverId;

    UserDriver driver = AppStorage().getDriverSafe(driverId);
    if (driver != null) {
      this.driverId.text = driver.id.toString();
      Toasts.showShort(
          "Водитель ${driver.shortFIO()} был поставлен автоматически");
      setState(() {});
    } else {
      clearDriver();
      return;
    }
  }

  void dateChangedCallback(date) {
    int piece = 1;
    int time = int.parse(DateFormat("HH").format(date));
    if (time >= 0 && time < 8) piece = 1;
    if (time >= 8 && time < 10) piece = 1;
    if (time >= 10 && time < 12) piece = 2;
    if (time >= 12 && time < 14) piece = 3;
    if (time >= 14 && time < 16) piece = 4;
    if (time >= 16 && time < 18) piece = 5;
    if (time >= 18) piece = 6;
    dayPiece.text = piece.toString();
    Toasts.showShort("Автоматически установлена $piece часть дня.");
    setState(() {});
  }

  Widget additionalsContactBlock1() {
    return Row(children: [
      Flexible(
          flex: 1,
          child: InputAutocomplete(
              controller: loadContact_name2,
              field: 'contact',
              owner: 'orders',
              icon: Icons.person,
              title: 'Имя 2')),
      Flexible(
          flex: 1,
          child: InputAutocomplete(
              controller: loadContact_phone2,
              field: 'load_phone',
              owner: 'orders',
              title: 'Телефон 2')),
    ]);
  }

  Widget additionalsContactBlock2() {
    return Row(children: [
      Flexible(
          flex: 1,
          child: InputAutocomplete(
              controller: loadContact_name3,
              field: 'contact',
              owner: 'orders',
              icon: Icons.person,
              title: 'Имя 3')),
      Flexible(
          flex: 1,
          child: InputAutocomplete(
              controller: loadContact_phone3,
              field: 'load_phone',
              owner: 'orders',
              title: 'Телефон 3')),
    ]);
  }

  // выгрузки
  Widget additionalsContactBlock_1() {
    return Row(children: [
      Flexible(
          flex: 1,
          child: InputAutocomplete(
              controller: unloadContact_name2,
              field: 'contact_unload',
              owner: 'orders',
              icon: Icons.person,
              title: 'Имя 2')),
      Flexible(
          flex: 1,
          child: InputAutocomplete(
              controller: unloadContact_phone2,
              field: 'unload_phone',
              owner: 'orders',
              title: 'Телефон 2')),
    ]);
  }

  Widget additionalsContactBlock_2() {
    return Row(children: [
      Flexible(
          flex: 1,
          child: InputAutocomplete(
              controller: unloadContact_name3,
              field: 'contact2_unload',
              owner: 'orders',
              icon: Icons.person,
              title: 'Имя 3')),
      Flexible(
          flex: 1,
          child: InputAutocomplete(
              controller: unloadContact_phone3,
              field: 'unload_phone2',
              owner: 'orders',
              title: 'Телефон 3')),
    ]);
  }

  void loadAdditionalContacts1() {
    if (additionalContactCount1 == 0) {
      _additionalContact1 = additionalsContactBlock1();
    }

    if (additionalContactCount1 == 1) {
      _additionalContact2 = additionalsContactBlock2();
    }

    additionalContactCount1++;
  }

  void loadAdditionalContacts2() {
    if (additionalContactCount2 == 0) {
      _additional_Contact1 = additionalsContactBlock_1();
    }

    if (additionalContactCount2 == 1) {
      _additional_Contact2 = additionalsContactBlock_2();
    }

    additionalContactCount2++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Создание заявки")),
      body: ListView(children: [
        FormEditTransport(
            controller: transportId,
            callbackForDriverChange: (transportId) {
              transportChangedCallback(transportId);
            }),
        FormEditDriver(controller: driverId),
        FormEditManager(controller: managerId),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: DateTimeInput(
                label: "Дата и время заявки",
                controllerForWeb: dateWeb,
                controllerForTime: timeLabel,
                onConfirmChanged: (date) {
                  dateChangedCallback(date);
                },
                confirm: true,
                controllerForLabel: dateLabel)),
        FormEditDayPiece(controller: dayPiece),
        FormEditCompany(controller: companyId),
        Container(
          child: Row(children: [
            Flexible(
              flex: 1,
              child: RadioListTile<OrderType>(
                  dense: true,
                  value: OrderType.transport,
                  groupValue: orderType,
                  title: Text("Перевозка груза"),
                  onChanged: (value) {
                    orderType = OrderType.transport;
                    setState(() {});
                  }),
            ),
            Flexible(
              flex: 1,
              child: RadioListTile<OrderType>(
                  dense: true,
                  value: OrderType.work,
                  groupValue: orderType,
                  title: Text("Работы на объекте"),
                  onChanged: (value) {
                    orderType = OrderType.work;
                    setState(() {});
                  }),
            ),
          ]),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                orderType == OrderType.transport
                    ? "Место погрузки"
                    : "Место работ",
                style: TextStyle(fontSize: 22, fontFamily: "Monserat")),
            InputAutocomplete(
                controller: addressFromShort,
                field: 'load_address_short',
                owner: 'orders',
                icon: Icons.place_outlined,
                title: orderType == OrderType.transport
                    ? 'Краткий адрес ПОГРУЗКИ'
                    : 'Краткий адрес МЕСТА РАБОТ'),
            InputAutocomplete(
                controller: addressFromFull,
                field: 'load_address',
                owner: 'orders',
                icon: Icons.place_outlined,
                title: orderType == OrderType.transport
                    ? 'Полный адрес ПОГРУЗКИ'
                    : 'Полный адрес МЕСТА РАБОТ'),
            Container(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Text(
                        orderType == OrderType.transport
                            ? "Контакты места погрузки"
                            : "Контакты места работ",
                        style: TextStyle(fontSize: 16)),
                    additionalContactCount1 < 2
                        ? IconButton(
                            icon: Icon(Icons.add),
                            splashRadius: 20,
                            onPressed: () {
                              loadAdditionalContacts1();
                              setState(() {});
                            })
                        : Container()
                  ],
                )),
            Row(children: [
              Flexible(
                  flex: 1,
                  child: InputAutocomplete(
                      controller: loadContact_name1,
                      field: 'contact',
                      owner: 'orders',
                      icon: Icons.person,
                      title: 'Имя')),
              Flexible(
                  flex: 1,
                  child: InputAutocomplete(
                      controller: loadContact_phone1,
                      field: 'load_phone',
                      owner: 'orders',
                      title: 'Телефон')),
            ]),
            _additionalContact1,
            _additionalContact2,
          ]),
        ),
        orderType == OrderType.transport
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Место выгрузки",
                          style:
                              TextStyle(fontSize: 22, fontFamily: "Monserat")),
                      InputAutocomplete(
                          controller: addressDestShort,
                          field: 'unload_address_short',
                          owner: 'orders',
                          icon: Icons.place_outlined,
                          title: 'Кратки адрес ВЫГРУЗКИ'),
                      InputAutocomplete(
                          controller: addressDestFull,
                          field: 'unload_address',
                          owner: 'orders',
                          icon: Icons.place_outlined,
                          title: 'Полный адрес ВЫГРУЗКИ'),
                      Container(
                          padding: EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Text("Контакты места выгрузки",
                                  style: TextStyle(fontSize: 16)),
                              additionalContactCount2 < 2
                                  ? IconButton(
                                      icon: Icon(Icons.add),
                                      splashRadius: 20,
                                      onPressed: () {
                                        loadAdditionalContacts2();
                                        setState(() {});
                                      })
                                  : Container()
                            ],
                          )),
                      Row(children: [
                        Flexible(
                            flex: 1,
                            child: InputAutocomplete(
                                controller: unloadContact_name1,
                                field: 'contact_unload',
                                owner: 'orders',
                                icon: Icons.person,
                                title: 'Имя')),
                        Flexible(
                            flex: 1,
                            child: InputAutocomplete(
                                controller: unloadContact_phone1,
                                field: 'unload_phone',
                                owner: 'orders',
                                title: 'Телефон')),
                      ]),
                      _additional_Contact1,
                      _additional_Contact2,
                    ]),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text("Метод расчёта оплаты", style: TextStyle(fontSize: 16)),
        ),
        Container(
          child: Row(children: [
            Flexible(
              flex: 1,
              child: RadioListTile<OrderPayMethod>(
                  dense: true,
                  value: OrderPayMethod.hours,
                  groupValue: orderPayMethod,
                  title: Text("За часы"),
                  onChanged: (value) {
                    orderPayMethod = OrderPayMethod.hours;
                    pieces.text = "";
                    sellerPrice.text = "";
                    setState(() {});
                  }),
            ),
            Flexible(
              flex: 1,
              child: RadioListTile<OrderPayMethod>(
                  dense: true,
                  value: OrderPayMethod.fixprice,
                  groupValue: orderPayMethod,
                  title: Text("За штуки"),
                  onChanged: (value) {
                    orderPayMethod = OrderPayMethod.fixprice;
                    hours1.text = "";
                    priceHour.text = "";
                    setState(() {});
                  }),
            ),
          ]),
        ),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: orderPayMethod == OrderPayMethod.hours
                ? Row(children: [
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                          autofocus: false,
                          controller: priceHour,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                              labelText: "Стоимость час",
                              labelStyle: TextStyle(
                                  color: Colors.blue[900], fontSize: 16))),
                    ),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                          autofocus: false,
                          controller: hours1,
                          onChanged: (text) {
                            double _value1 = double.tryParse(priceHour.text);
                            double _value2 = double.tryParse(text);
                            if (_value1 != null && _value2 != null) {
                              priceFull.text =
                                  removeDecimalZeroFormat(_value1 * _value2)
                                      .toString();
                              setState(() {});
                            }
                          },
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                              labelText: "Часы выставления",
                              labelStyle: TextStyle(
                                  color: Colors.blue[900], fontSize: 16))),
                    )
                  ])
                : Row(children: [
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                          autofocus: false,
                          controller: pieces,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                              labelText: "Количество штук (ходок)",
                              labelStyle: TextStyle(
                                  color: Colors.blue[900], fontSize: 16))),
                    ),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                          autofocus: false,
                          controller: sellerPrice,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                              labelText: "Стоимость поставщика",
                              labelStyle: TextStyle(
                                  color: Colors.blue[900], fontSize: 16))),
                    )
                  ])),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Flexible(
                flex: 1,
                child: TextFormField(
                    autofocus: false,
                    controller: priceFull,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                        labelText: "Стоимость заявки",
                        labelStyle:
                            TextStyle(color: Colors.blue[900], fontSize: 16))),
              ),
              Flexible(
                flex: 1,
                child: TextFormField(
                    autofocus: false,
                    controller: hours2,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                        labelText: "Часы водителю",
                        labelStyle:
                            TextStyle(color: Colors.blue[900], fontSize: 16))),
              )
            ])),
        FormEditPaymentMethod(controller: payment_method),
        InputAutocomplete(),
        Container(height: 30),
        Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: [
              ElevatedButton.icon(
                  onPressed: () {},
                  onLongPress: () {
                    Toasts.showShort("Началось...");
                  },
                  icon: Icon(Icons.save_alt),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text("Проверить и сохранить",
                        style: TextStyle(fontFamily: 'Monserat', fontSize: 18)),
                  )),
              Container(height: 10),
              Text("требуется длительное нажатие",
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        )
      ]),
    );
  }
}
