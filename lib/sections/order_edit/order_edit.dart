import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:transportumformanager/entity/contact.dart';
import 'package:transportumformanager/global/ChangesListener.dart';
import 'package:transportumformanager/global/InsideBuffer.dart';
import 'package:transportumformanager/global/appstorage/AppStorage.dart';
import 'package:transportumformanager/helper/dialogs.dart';
import 'package:transportumformanager/helper/log.dart';
import 'package:transportumformanager/helper/remove_decimal_zero.dart';
import 'package:transportumformanager/helper/toast.dart';
import 'package:transportumformanager/model/company.dart';
import 'package:transportumformanager/model/order.dart';
import 'package:transportumformanager/model/transport.dart';
import 'package:transportumformanager/model/user_driver.dart';
import 'package:transportumformanager/model/user_manager.dart';
import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/network/socket.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';
import 'package:transportumformanager/sections/order_details/order_details_api.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_company.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_day_piece.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_driver.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_manager.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_payment_method.dart';
import 'package:transportumformanager/sections/order_edit/form_edit_transport.dart';
import 'package:transportumformanager/sections/order_edit/input_autocomplete.dart';
import 'package:transportumformanager/sections/order_edit/order_edit_api.dart';
import 'package:transportumformanager/widgets/TextIcon.dart';
import 'package:transportumformanager/widgets/dateInput.dart';
import 'package:transportumformanager/widgets/dateTimeInput.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:transportumformanager/widgets/preloaders.dart';

final log = Logger();

enum OrderEditMode { add, edit, dublicate }
enum OrderEditType { transport, work }

class OrderEdit extends StatefulWidget {
  final int orderId;
  final OrderEditMode editMode;
  OrderEdit({Key key, this.orderId, this.editMode = OrderEditMode.add})
      : super(key: key);

  @override
  _OrderEditState createState() => _OrderEditState();
}

class _OrderEditState extends State<OrderEdit> {
  OrderEditType orderType = OrderEditType.transport;
  OrderPayMethod orderPayMethod = OrderPayMethod.hours;

  OrderEditAPI orderEditApi = OrderEditAPI();

  OrderModel orderModel;

  bool dataPreloaded = false;

  int orderId;

  var transportId = TextEditingController(text: "-1");
  var driverId = TextEditingController(text: "-1");
  var managerId = TextEditingController(text: "-1");
  var dateWeb = TextEditingController();
  var dateLabel = TextEditingController();
  var timeLabel = TextEditingController();
  DateTime orderDateTime;

  var orderNum = TextEditingController(text: "-1");
  var pieces = TextEditingController(text: "1");
  var companyId = TextEditingController(text: "-1");
  var addressFromShort = TextEditingController();
  var addressFromFull = TextEditingController();
  var addressFromFull2 = TextEditingController();
  var addressFromFull3 = TextEditingController();
  var addressFromFull4 = TextEditingController();

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
  var sellerPrice = TextEditingController(text: "");
  var payment_method = TextEditingController(text: "-1");
  var cargoType = TextEditingController(text: "");
  var cargoDesc = TextEditingController(text: "");

  bool haveTrailer = false;

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
    if (widget.editMode == OrderEditMode.add) {
      dataPreloaded = true;
      orderDateTime = InsideBuffer().get(InsideBuffers.dashboardDate,
          notErrIfNotFound: true, defaultValue: null);
    }

    if (widget.editMode == OrderEditMode.dublicate ||
        widget.editMode == OrderEditMode.edit) {
      dataPreloaded = false;
      preloadForm();
    }

    if (widget.editMode == OrderEditMode.add) {
      managerId.text = AppData().getUser().id.toString();
    }

    super.initState();
  }

  void preloadForm() async {
    if (widget.orderId == null) return;

    var orderJSON = await OrderDetailsApi().loadOrder(widget.orderId);

    orderModel = OrderModel.fromJSON(orderJSON);

    transportId.text = orderModel.trandportId.toString();

    haveTrailer = orderModel.haveTrailer;

    driverId.text = orderModel.driverId.toString();
    managerId.text = orderModel.managerId.toString();

    //dateWeb.text = DateFormat('yyyy-MM-dd').format(orderModel.date);
    //dateLabel.text = DateFormat.yMMMMd('ru').format(orderModel.date);

    if (widget.editMode == OrderEditMode.edit) orderId = orderModel.id;

    timeLabel.text = orderModel.time;

    companyId.text = orderModel.companyId.toString();
    addressFromShort.text = orderModel.addressFromShort;
    addressFromFull.text = orderModel.addressFromShort;
    addressFromFull2.text = orderModel.addressFrom2;
    addressFromFull3.text = orderModel.addressFrom3;
    addressFromFull4.text = orderModel.addressFrom4;

    addressDestShort.text = orderModel.addressDestShort;
    addressDestFull.text = orderModel.addressDestLong;

    loadContact_phone1.text = orderModel.loadContact1.phone;
    loadContact_phone2.text = orderModel.loadContact2.phone;
    loadContact_phone3.text = orderModel.loadContact3.phone;
    loadContact_name1.text = orderModel.loadContact1.name;
    loadContact_name2.text = orderModel.loadContact2.name;
    loadContact_name3.text = orderModel.loadContact3.name;
    unloadContact_phone1.text = orderModel.unloadContact1.phone;
    unloadContact_phone2.text = orderModel.unloadContact2.phone;
    unloadContact_phone3.text = orderModel.unloadContact3.phone;
    unloadContact_name1.text = orderModel.unloadContact1.name;
    unloadContact_name2.text = orderModel.unloadContact2.name;
    unloadContact_name3.text = orderModel.unloadContact3.name;

    priceFull.text = removeDecimalZeroFormat(orderModel.priceSummary);
    priceHour.text = removeDecimalZeroFormat(orderModel.pricePerHour);
    hours1.text = removeDecimalZeroFormat(orderModel.hours);
    hours2.text = removeDecimalZeroFormat(orderModel.hoursForDriver);
    pieces.text = orderModel.pieces.toString();
    sellerPrice.text = removeDecimalZeroFormat(orderModel.priceSeller);

    cargoType.text = orderModel.cargoType;
    cargoDesc.text = orderModel.cargoDesc;

    additionalContactCount1 = 0;
    additionalContactCount2 = 0;

    dataPreloaded = true;

    if (orderModel.addressDestShort == "") orderType = OrderEditType.work;

    orderNum.text = orderModel.orderNum.toString();
    payment_method.text = orderModel.getPaymentMethodLabel();

    if (orderModel.pieces > 0) {
      orderPayMethod = OrderPayMethod.fixprice;
    }

    orderPayMethod = orderModel.orderPayMethod;

    orderDateTime = orderModel.date;

    setState(() {});
  }

  Future<bool> validateForm(BuildContext context) async {
    List<String> errors = [];

    if (transportId.text == "-1") {
      errors.add("Транспорт");
    }
    if (driverId.text == "-1") {
      errors.add("Водитель");
    }
    if (managerId.text == "-1") {
      errors.add("Ответственный менеджер");
    }
    if (orderNum.text == "-1") {
      errors.add("Не указана часть дня");
    }
    if (companyId.text == "-1") {
      errors.add("Не указана компания заказчика");
    }
    if (addressFromShort.text == "") {
      errors.add("Краткий адрес погрузки / места работы");
    }
    if (addressFromFull.text == "") {
      errors.add("Полный адрес погрузки / места работы");
    }

    /*if (loadContact_phone1.text == "") {
      errors.add("Контакт погрузки / места работы");
    }*/

    if (orderType == OrderEditType.transport) {
      if (addressDestShort.text == "") {
        errors.add("Краткий адрес выгрузки");
      }
      if (addressDestFull.text == "") {
        errors.add("Полный адрес выгрузки");
      }
    }

    if (priceFull.text == "") {
      errors.add("Стоимость заявки");
    }

    if (orderPayMethod == OrderPayMethod.hours) {
      if (hours1.text == "") {
        errors.add("Часы выставления");
      }
      if (hours2.text == "") {
        errors.add("Часы водителя");
      }
      if (priceHour.text == "") {
        errors.add("Стоимость часа");
      }
    }

    if (orderPayMethod == OrderPayMethod.fixprice) {
      if (pieces.text == "") {
        errors.add("Число ходок (штук)");
      }
      if (sellerPrice.text == "") {
        errors.add("Стоимость поставщика");
      }
      if (hours2.text == "") {
        errors.add("Часы водителя");
      }
    }

    if (payment_method.text == "-1") {
      errors.add("Способ оплаты");
    }

    if (errors.length > 0) {
      Dialogs.showAlert(
          context, "Проверка...", "НЕОБХОДИМО ЗАПОЛНИТЬ\n" + errors.join("\n"));

      return false;
    }

    if (widget.editMode == OrderEditMode.add ||
        widget.editMode == OrderEditMode.dublicate) {
      var response = await orderEditApi.checkOrderExist(
          dateWeb.text, transportId.text, orderNum.text);

      if (response['result'] == 'ok') {
        if ((response['exist'] as bool) == true) {
          Dialogs.showAlert(context, "(!!!) Нельзя добавить",
              "На данную часть дня, на ${dateLabel.text} уже есть другая заявка, необходимо поменять на другую часть дня.");

          return false;
        }
      }
    }

    return true;
  }

  void saveOrder(BuildContext context) {
    int updateId = 0;
    if (widget.orderId != null && widget.editMode == OrderEditMode.edit) {
      updateId = widget.orderId;
    }

    int orderStatus = 0;
    if (orderModel != null && widget.editMode != OrderEditMode.add) {
      orderStatus = orderModel.status;
    }

    Transport transport =
        AppStorage().getTransportSafe(int.parse(transportId.text));
    if (transport == null) {
      Dialogs.showAlert(context, "Ошибка",
          "Не найден транспорт во внутреннем хранилище приложения. Попробуйте перезагрузить приложение. Это очень редкая ошибка, возможно транспорт был добавлен в момент добавления заявки.");
      return;
    }

    UserManager manager =
        AppStorage().getManagerSafe(int.parse(managerId.text));
    if (manager == null) {
      Dialogs.showAlert(context, "Ошибка",
          "Не найден менеджер во внутреннем хранилище приложения. Попробуйте перезагрузить приложение. Это очень редкая ошибка, возможно менеджер был добавлен в момент добавления заявки.");
      return;
    }

    OrderNds orderNds = OrderNds.withNds;
    OrderCash orderCash = OrderCash.bank;
    if (payment_method.text == "Безнал с НДС") orderNds = OrderNds.withNds;
    if (payment_method.text == "Безнал без НДС") orderNds = OrderNds.withoutNds;
    if (payment_method.text == "Наличный") {
      orderNds = OrderNds.withoutNds;
      orderCash = OrderCash.cash;
    }
    if (orderModel.orderNds != null) {
      orderNds = orderModel.orderNds;
    }
    if (orderModel.orderCash != null) {
      orderCash = orderModel.orderCash;
    }

    OrderModel newOrder = OrderModel(
        updateId, // id,
        int.parse(transportId.text), // trandportId,
        int.parse(driverId.text), // driverId,
        DateTime.parse(dateWeb.text), // date,
        timeLabel.text, // time,
        transport.number, // carNumber,
        haveTrailer, // haveTrailer,
        cargoDesc.text, // cargoDesc,
        cargoType.text, // cargoType,
        orderStatus, // status,
        int.parse(managerId.text), // managerId,
        manager.login, // managerLogin,
        int.parse(companyId.text), // companyId,
        "", // companyName,
        addressFromShort.text, // addressFromShort,
        addressFromFull.text, // addressFromLong,
        addressFromFull2.text, // addressFrom2,
        addressFromFull3.text, // addressFrom3,
        addressFromFull4.text, // addressFrom4,
        addressDestShort.text, // addressDestShort,
        addressDestFull.text, // addressDestLong,
        "", // coordsFrom,
        "", // coordsDest,
        OrderContact.build(
            loadContact_name1.text, loadContact_phone1.text), // loadContact1,
        OrderContact.build(
            loadContact_name2.text, loadContact_phone2.text), // loadContact2,
        OrderContact.build(
            loadContact_name3.text, loadContact_phone3.text), // loadContact3,
        OrderContact.build(unloadContact_name1.text,
            unloadContact_phone1.text), // unloadContact1,
        OrderContact.build(unloadContact_name2.text,
            unloadContact_phone2.text), // unloadContact2,
        OrderContact.build(unloadContact_name3.text,
            unloadContact_phone3.text), // unloadContact3,
        double.parse(priceFull.text), // priceSummary,
        double.parse(sellerPrice.text), // priceSeller,
        double.parse(priceHour.text), // pricePerHour,
        orderPayMethod, // orderPayMethod,
        orderNds, // orderNds,
        orderCash, // orderCash,
        double.parse(hours1.text), // hours,
        double.parse(hours2.text), // hoursForDriver,
        int.parse(pieces.text), // pieces,
        int.parse(orderNum.text) // orderNum
        );

    

    orderEditApi.addOrder(newOrder).then((response) {
      if (response['result'] == 'ok') {
        AppData().changeListener.emitt(ChangesListeners.orderDetails);
        Navigator.pop(context);
      }
    });
  }

  void checkTrailerIncorrect() async {
    if (!this.haveTrailer) {
      var checkTrailerExist = await orderEditApi.checkTrailerExist(
          dateWeb.text, transportId.text, orderNum.text);

      if (checkTrailerExist['result'] == 'ok') {
        if ((checkTrailerExist['exist'] as bool) == true) {
          Dialogs.showAlert(context, "(!) Предупреждение",
              "Предыдущая заявка данного транспорта С ПРИЦЕПОМ, это может создать затруднения в дальнейших заявках. Это не помешает, но ИМЕЙТЕ ЭТО В ВИДУ!");
        }
      }
    }
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
    orderNum.text = piece.toString();
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
    String _title = "Создание заявки";
    if (widget.editMode == OrderEditMode.dublicate) {
      _title = "Дублирование заявки";
    }

    if (widget.editMode == OrderEditMode.edit) {
      _title = "Редактирование заявки";
    }

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: dataPreloaded == false
          ? CenterPreloader()
          : ListView(children: [
              widget.editMode == OrderEditMode.dublicate
                  ? Container(
                      padding: EdgeInsets.all(20),
                      child: Center(
                          child: TextIcon(
                        label: "Режим дублирования",
                        textStyle:
                            TextStyle(fontSize: 22, color: Colors.indigo),
                        iconData: Icons.warning_amber_rounded,
                      )))
                  : Container(),
              FormEditTransport(
                  controller: transportId,
                  callbackForDriverChange: (transportId) {
                    transportChangedCallback(transportId);
                  }),
              Container(
                child: Row(children: [
                  Flexible(
                    flex: 1,
                    child: RadioListTile<bool>(
                        dense: true,
                        value: false,
                        groupValue: haveTrailer,
                        title: Text("Без прицепа"),
                        onChanged: (value) {
                          haveTrailer = false;
                          setState(() {});
                          this.checkTrailerIncorrect();
                        }),
                  ),
                  Flexible(
                    flex: 1,
                    child: RadioListTile<bool>(
                        dense: true,
                        value: true,
                        groupValue: haveTrailer,
                        title: Text("С прицепом"),
                        onChanged: (value) {
                          haveTrailer = true;
                          setState(() {});
                          this.checkTrailerIncorrect();
                        }),
                  ),
                ]),
              ),
              FormEditDriver(controller: driverId),
              FormEditManager(controller: managerId),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                  child: DateTimeInput(
                      label: "Дата и время заявки",
                      initialDateTime: orderDateTime,
                      controllerForWeb: dateWeb,
                      controllerForTime: timeLabel,
                      onConfirmChanged: (date) {
                        dateChangedCallback(date);
                      },
                      confirm: true,
                      controllerForLabel: dateLabel)),
              FormEditDayPiece(controller: orderNum),
              FormEditCompany(controller: companyId),
              Container(
                child: Row(children: [
                  Flexible(
                    flex: 1,
                    child: RadioListTile<OrderEditType>(
                        dense: true,
                        value: OrderEditType.transport,
                        groupValue: orderType,
                        title: Text("Перевозка груза"),
                        onChanged: (value) {
                          orderType = OrderEditType.transport;
                          setState(() {});
                        }),
                  ),
                  Flexible(
                    flex: 1,
                    child: RadioListTile<OrderEditType>(
                        dense: true,
                        value: OrderEditType.work,
                        groupValue: orderType,
                        title: Text("Работы на объекте"),
                        onChanged: (value) {
                          orderType = OrderEditType.work;
                          setState(() {});
                        }),
                  ),
                ]),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          orderType == OrderEditType.transport
                              ? "Место погрузки"
                              : "Место работ",
                          style:
                              TextStyle(fontSize: 22, fontFamily: "Monserat")),
                      InputAutocomplete(
                          controller: addressFromShort,
                          field: 'load_address_short',
                          owner: 'orders',
                          icon: Icons.place_outlined,
                          title: orderType == OrderEditType.transport
                              ? 'Краткий адрес ПОГРУЗКИ'
                              : 'Краткий адрес МЕСТА РАБОТ'),
                      InputAutocomplete(
                          controller: addressFromFull,
                          field: 'load_address',
                          owner: 'orders',
                          icon: Icons.place_outlined,
                          title: orderType == OrderEditType.transport
                              ? 'Полный адрес ПОГРУЗКИ'
                              : 'Полный адрес МЕСТА РАБОТ'),
                      InputAutocomplete(
                          controller: addressFromFull2,
                          field: 'load_address',
                          owner: 'orders',
                          icon: Icons.place_outlined,
                          title: "Второй адрес погрузки"),
                      InputAutocomplete(
                          controller: addressFromFull3,
                          field: 'load_address',
                          owner: 'orders',
                          icon: Icons.place_outlined,
                          title: "Третий адрес погрузки"),
                      Container(
                          padding: EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Text(
                                  orderType == OrderEditType.transport
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
              orderType == OrderEditType.transport
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Место выгрузки",
                                style: TextStyle(
                                    fontSize: 22, fontFamily: "Monserat")),
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
                child: Text("Метод расчёта оплаты",
                    style: TextStyle(fontSize: 16)),
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
                          if (widget.editMode == OrderEditMode.add) {
                            pieces.text = "";
                            sellerPrice.text = "";
                          }
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
                          if (widget.editMode == OrderEditMode.add) {
                            hours1.text = "";
                            priceHour.text = "";
                          }
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
                                onChanged: (text) {
                                  double _value1 =
                                      double.tryParse(priceHour.text);
                                  double _value2 = double.tryParse(hours1.text);

                                  if (_value1 != null && _value2 != null) {
                                    priceFull.text = removeDecimalZeroFormat(
                                            _value1 * _value2)
                                        .toString();

                                    setState(() {});
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: "Стоимость в час",
                                    labelStyle: TextStyle(
                                        color: Colors.blue[900],
                                        fontSize: 16))),
                          ),
                          Flexible(
                            flex: 1,
                            child: TextFormField(
                                autofocus: false,
                                controller: hours1,
                                onChanged: (text) {
                                  double _value1 =
                                      double.tryParse(priceHour.text);
                                  double _value2 = double.tryParse(text);
                                  if (_value1 != null && _value2 != null) {
                                    priceFull.text = removeDecimalZeroFormat(
                                            _value1 * _value2)
                                        .toString();
                                    setState(() {});
                                  }
                                },
                                keyboardType: TextInputType.number,
                                style: TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                    labelText: "Часы выставления",
                                    labelStyle: TextStyle(
                                        color: Colors.blue[900],
                                        fontSize: 16))),
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
                                        color: Colors.blue[900],
                                        fontSize: 16))),
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
                                        color: Colors.blue[900],
                                        fontSize: 16))),
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
                              labelStyle: TextStyle(
                                  color: Colors.blue[900], fontSize: 16))),
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
                              labelStyle: TextStyle(
                                  color: Colors.blue[900], fontSize: 16))),
                    )
                  ])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: FormEditPaymentMethod(controller: payment_method),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InputAutocomplete(
                    controller: cargoType,
                    field: 'cargo_type',
                    owner: 'orders',
                    title: 'Краткое описание'),
              ),
              Container(height: 10),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    autofocus: false,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value.length < 5) {
                        return "Требуется описание (не менее 5 символов)";
                      }
                      return null;
                    },
                    controller: cargoDesc,
                    style: TextStyle(fontSize: 16),
                    maxLines: 10,
                    minLines: 3,
                    decoration: InputDecoration(
                        labelText: "Подробности заявки",
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: "Monserat")),
                  )),
              Container(height: 30),
              Container(
                margin: EdgeInsets.all(20),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {},
                        onLongPress: () {
                          validateForm(context).then((valid) {
                            if (valid) {
                              saveOrder(context);
                            } else {
                              Toasts.showShort("Ошибка заполнения");
                            }
                          });
                        },
                        icon: Icon(Icons.save_alt),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text("Проверить и сохранить",
                              style: TextStyle(
                                  fontFamily: 'Monserat', fontSize: 18)),
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
