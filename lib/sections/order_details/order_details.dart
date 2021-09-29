import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:transportumformanager/global/ChangesListener.dart';
import 'package:transportumformanager/helper/remove_decimal_zero.dart';
import 'package:transportumformanager/model/order.dart';
import 'package:transportumformanager/model/transport.dart';
import 'package:transportumformanager/model/user_driver.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';
import 'package:transportumformanager/helper/app_functions.dart';
import 'package:transportumformanager/helper/preloader.dart';
import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/sections/order_details/order_details_api.dart';
import 'package:transportumformanager/widgets/TextIcon.dart';
import 'package:transportumformanager/widgets/blink_label.dart';
import 'package:transportumformanager/helper/dialogs.dart';
import 'package:transportumformanager/widgets/preloaders.dart';
import 'package:transportumformanager/network/socket.dart';
import 'package:transportumformanager/widgets/FlatIconButton.dart';
import 'package:expandable/expandable.dart';

import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:image_picker/image_picker.dart';

import 'package:confirm_dialog/confirm_dialog.dart';

final log = Logger();

class OrderDetails extends StatelessWidget {
  @required
  final String title;
  @required
  final int orderId;

  const OrderDetails({Key key, this.title, this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.title),
          actions: [            
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(                    
                      child: TextIcon(iconData: Icons.edit, label: "Редактировать", textStyle: TextStyle(fontSize: 15))),
                  PopupMenuItem(                    
                      child: TextIcon(iconData: Icons.copy, label: "Дублировать", textStyle: TextStyle(fontSize: 15))),
                ];
              },
            )
          ],
        ),
        body: OrderDetailsBody(orderId: orderId));
  }
}

class OrderDetailsBody extends StatefulWidget {
  final orderId;
  const OrderDetailsBody({Key key, this.orderId}) : super(key: key);

  @override
  _OrderDetailsBodyState createState() => _OrderDetailsBodyState();
}

class _OrderDetailsBodyState extends State<OrderDetailsBody> {
  final int fontSize = 14;
  final int itemPadding = 10;
  final Widget divider = Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Divider(color: Colors.grey, height: 2));
  bool isLoading = true;

  DateTime today = DateTime.now();

  OrderModel currOrder;
  UserDriver currDriver;
  Transport currTransport;

  String specialFormattedDateTime;

  BuildContext pageContext;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 1000), () {
      loadData();
      loadImages();
    });

    AppData().changeListener.setListener(ChangesListeners.orderDetails, () {
      loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();

    AppData().changeListener.removeListener(ChangesListeners.orderDetails);
  }

  void loadData() {
    OrderDetailsApi().loadOrder(widget.orderId).then((orderJSON) {
      currOrder = OrderModel.fromJSON(orderJSON);
      currDriver = UserDriver.fromJSON(orderJSON['driver']);
      currTransport = Transport.fromJSON(orderJSON['transport']);

      specialFormattedDateTime = orderJSON['date_label3'];

      isLoading = false;

      setState(() {});
    }).onError((error, stackTrace) {
      log.e(stackTrace.toString());
      if (error == OrderDetailsApi.errors.orderNotFound) {
        Dialogs.showAlert(pageContext, "Ошибка", "Заказ не найден");
      }
    });
  }

  List<String> imagesUrls = [];
  List<String> bigImagesUrls = [];
  List<String> imagesIds = [];
  dynamic pickImageError;
  String retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  void loadImages() {
    imagesUrls.clear();
    SocketQuery query = SocketQuery('get_photos')
        .addParam('item_id', "${widget.orderId}")
        .addParam('owner', 'orders');

    TransportumSocket().query(query, callback: (responseJson) {
      List<dynamic> images = responseJson['items'];
      images.forEach((image) {
        imagesUrls.add(image['photo500'].toString());
        bigImagesUrls.add(image['photo'].toString());
        imagesIds.add(image['id'].toString());
      });

      setState(() {});
    });
  }

  void onImageButtonPressed(ImageSource source) async {
    try {
      final pickedFile = await _picker.getImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      uploadImage(pickedFile);

      setState(() {});
    } catch (e) {
      setState(() {
        pickImageError = e;
      });
    }
  }

  void uploadImage(PickedFile pickedFile) async {
    final bytes = await pickedFile.readAsBytes();

    SocketQuery query = SocketQuery('add_photo')
        .addParam('item_id', "${widget.orderId}")
        .addParam('owner', 'orders')
        .addParam('base64data', base64.encode(bytes));

    imagesUrls.clear();
    bigImagesUrls.clear();
    imagesIds.clear();
    imagesUrls.add("loading");
    bigImagesUrls.add("loading");
    imagesIds.add("loading");

    setState(() {});

    TransportumSocket().query(query, callback: (response) {
      loadImages();
    });
  }

  Future<void> removePhoto(index) {
    imagesIds.removeAt(index);
    imagesUrls.removeAt(index);
    bigImagesUrls.removeAt(index);
    setState(() {});
    Completer completer = Completer();

    SocketQuery query =
        SocketQuery('remove_photo').addParam('photo_id', imagesIds[index]);

    TransportumSocket().query(query, callback: () {
      completer.complete();
    });

    return completer.future;
  }

  bool isOrderNotToday() {
    DateTime expireDate = currOrder.date.add(Duration(hours: 16));
    return (today.isAfter(expireDate));
  }

  void removeGalleryPhoto(context, index) async {
    if (isOrderNotToday()) {
      Dialogs.showAlert(context, "Ограничение",
          "Нельзя удалить фото по прошествию 24 часов после заявки");
      return;
    }

    if (await confirm(
      context,
      title: Text('Удалить фото?'),
      content: Text('Точно?'),
      textOK: Text('Да'),
      textCancel: Text('Нет'),
    )) {
      Navigator.of(context).pop();
      await removePhoto(index);
      loadImages();
    }
  }

  Widget buildImageList(BuildContext context, {bool isNetwork = false}) {
    if (imagesUrls.length == 0) return Container();

    List<Widget> _items = [];
    imagesUrls.asMap().forEach((index, url) {
      if (url == 'loading') {
        _items.add(Container(
            padding: EdgeInsets.all(30),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey, width: 3)),
            child: CircularProgressIndicator(
              value: null,
              strokeWidth: 2.0,
            )));
      } else {
        _items.add(
          GestureDetector(
            onTap: () {
              AppFunctions.openGalleryView(context, bigImagesUrls,
                  initialPage: index, removeFunction: () {
                removeGalleryPhoto(context, index);
              });
            },
            child: Container(
                child: Image.network(url, fit: BoxFit.fitWidth, loadingBuilder:
                    (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                }),
                padding: EdgeInsets.all(5)),
          ),
        );
      }
    });

    return SingleChildScrollView(
      child: Column(
        children: [
          GridView.count(
              crossAxisCount: 4,
              children: _items,
              shrinkWrap: true,
              physics: BouncingScrollPhysics())
        ],
      ),
    );
  }

  Widget buildPhotoWidget(BuildContext context) {
    Widget imageListWidget = Container();

    if (imagesUrls.length > 0) {
      imageListWidget = buildImageList(context);
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(children: [
        TextButton.icon(
            onPressed: () async {
              onImageButtonPressed(ImageSource.camera);
            },
            icon: Icon(Icons.photo_camera),
            label: Text("Добавить фото")),
        imageListWidget
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double leftRowWidth = MediaQuery.of(context).size.width * 0.4;
    final double rightRowWidth = MediaQuery.of(context).size.width * 0.6;
    final double fullWidth = MediaQuery.of(context).size.width * 0.9;
    final Color topButtonsColor = Colors.green[800];

    Widget addressButton1;
    Widget addressButton2;
    Widget loadContacts = Container();
    Widget unloadContacts = Container();
    Widget submitButton = Container();
    Widget photoWidget = Container();
    Widget hoursAndPricesBlock1 = Container();
    Widget hoursAndPricesBlock2 = Container();

    // здесь предполагается презагрузка виджетов, данные для которого доступны только после загрузки с сервера
    if (!isLoading) {
      if (currOrder.orderPayMethod == OrderPayMethod.hours) {
        hoursAndPricesBlock1 = Container(
          padding: EdgeInsets.all(10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.timer, color: Colors.blue[900]),
              Container(width: 5),
              Text("${currOrder.getHours()} ч выставления",
                  style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 14,
                      fontWeight: FontWeight.bold))
            ]),
            Row(children: [
              Icon(Icons.timer, color: Colors.blueAccent[700]),
              Container(width: 5),
              Text("${currOrder.getHoursForDriver()} ч водителю",
                  style: TextStyle(
                      color: Colors.blueAccent[700],
                      fontSize: 14,
                      fontWeight: FontWeight.bold))
            ])
          ]),
        );

        hoursAndPricesBlock2 = Container(
            padding: EdgeInsets.all(10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.payments_outlined, color: Colors.green[900]),
                    Container(width: 5),
                    Text("${currOrder.getPricePerHour()} руб/час",
                        style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 14,
                            fontWeight: FontWeight.bold))
                  ]),
                  Row(children: [
                    Icon(Icons.payments, color: Colors.green[900]),
                    Container(width: 5),
                    Text(
                        "${currOrder.getPriceSummary()} (${currOrder.getCashAndNdsLabel()})",
                        style: TextStyle(
                            color: Colors.blueAccent[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold))
                  ])
                ]));
      }

      if (currOrder.orderPayMethod == OrderPayMethod.fixprice) {
        hoursAndPricesBlock1 = Container(
          padding: EdgeInsets.all(10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.payments_outlined, color: Colors.green[900]),
              Container(width: 5),
              Text("${currOrder.getPriceSeller()} цена поставщика",
                  style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 14,
                      fontWeight: FontWeight.bold))
            ]),
            currOrder.hoursForDriver > 0
                ? Row(children: [
                    Icon(Icons.timer, color: Colors.blueAccent[700]),
                    Container(width: 5),
                    Text(
                        "${removeDecimalZeroFormat(currOrder.hoursForDriver)} ч водителю",
                        style: TextStyle(
                            color: Colors.blueAccent[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold))
                  ])
                : Container()
          ]),
        );

        hoursAndPricesBlock2 = Container(
            padding: EdgeInsets.all(10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(Icons.payments_outlined, color: Colors.green[900]),
                    Container(width: 5),
                    Text("${currOrder.getMarjaString()} руб маржа",
                        style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 14,
                            fontWeight: FontWeight.bold))
                  ]),
                  Row(children: [
                    Icon(Icons.payments, color: Colors.green[900]),
                    Container(width: 5),
                    Text(
                        "${removeDecimalZeroFormat(currOrder.priceSummary)} (${currOrder.getCashAndNdsLabel()})",
                        style: TextStyle(
                            color: Colors.blueAccent[700],
                            fontSize: 14,
                            fontWeight: FontWeight.bold))
                  ])
                ]));
      }

      addressButton1 = Container(
          width: fullWidth,
          margin: EdgeInsets.only(top: 5),
          child: Column(children: [
            TextButton(
                onPressed: () async {
                  String geoAddress = currOrder.getGeoFrom();
                  await launch("geo:0,0?q=" + Uri.encodeFull(geoAddress));
                },
                child: Row(children: [
                  Container(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.place_outlined)),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      currOrder.addressFromLong,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: "Monserat",
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900]),
                    ),
                  )
                ]))
          ]));

      addressButton2 = Container();
      if (!currOrder.notDestination()) {
        addressButton2 = Container(
            width: fullWidth,
            margin: EdgeInsets.only(top: 5),
            child: Column(children: [
              TextButton(
                  onPressed: () async {
                    String geoAddress = currOrder.getGeoDest();
                    await launch("geo:0,0?q=" + Uri.encodeFull(geoAddress));
                  },
                  child: Row(children: [
                    Container(
                        padding: EdgeInsets.all(5), child: Icon(Icons.place)),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        currOrder.addressDestLong,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: "Monserat",
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900]),
                      ),
                    )
                  ]))
            ]));
      }

      List<Widget> items = [];

      if (!currOrder.loadContact1.isEmpty) {
        items.add(FlatButtonWithIcon(
            color: Colors.purple[700],
            truncate: false,
            icon: Icons.phone,
            text:
                "${currOrder.loadContact1.name} - ${currOrder.loadContact1.phone}",
            maxWidth: fullWidth * 0.8,
            onclick: () async {
              await FlutterPhoneDirectCaller.callNumber(
                  currOrder.loadContact1.phone);
            },
            fontSize: 16));
      }

      if (!currOrder.loadContact2.isEmpty) {
        items.add(FlatButtonWithIcon(
            color: Colors.purple[700],
            truncate: false,
            icon: Icons.phone,
            text:
                "${currOrder.loadContact2.name} - ${currOrder.loadContact2.phone}",
            maxWidth: fullWidth * 0.8,
            onclick: () async {
              await FlutterPhoneDirectCaller.callNumber(
                  currOrder.loadContact2.phone);
            },
            fontSize: 16));
      }

      if (!currOrder.loadContact3.isEmpty) {
        items.add(FlatButtonWithIcon(
            color: Colors.purple[700],
            truncate: false,
            icon: Icons.phone,
            text:
                "${currOrder.loadContact3.name} - ${currOrder.loadContact3.phone}",
            maxWidth: fullWidth * 0.8,
            onclick: () async {
              await FlutterPhoneDirectCaller.callNumber(
                  currOrder.loadContact3.phone);
            },
            fontSize: 16));
      }

      loadContacts = ExpandablePanel(
          header: FlatButtonWithIcon(
              color: Colors.purple[700],
              truncate: false,
              icon: Icons.person_outline_sharp,
              text: "Контакты погрузки",
              maxWidth: fullWidth * 0.8,
              onclick: null,
              fontSize: 18),
          expanded: Column(children: items));

      /// UNLOAD contacts

      items = [];

      if (!currOrder.unloadContact1.isEmpty) {
        items.add(FlatButtonWithIcon(
            color: Colors.purple[700],
            truncate: false,
            icon: Icons.phone,
            text:
                "${currOrder.unloadContact1.name} - ${currOrder.unloadContact1.phone}",
            maxWidth: fullWidth * 0.8,
            onclick: () async {
              await FlutterPhoneDirectCaller.callNumber(
                  currOrder.unloadContact1.phone);
            },
            fontSize: 16));
      }

      if (!currOrder.unloadContact2.isEmpty) {
        items.add(FlatButtonWithIcon(
            color: Colors.purple[700],
            truncate: false,
            icon: Icons.phone,
            text:
                "${currOrder.unloadContact2.name} - ${currOrder.unloadContact2.phone}",
            maxWidth: fullWidth * 0.8,
            onclick: () async {
              await FlutterPhoneDirectCaller.callNumber(
                  currOrder.unloadContact2.phone);
            },
            fontSize: 16));
      }

      if (!currOrder.unloadContact3.isEmpty) {
        items.add(FlatButtonWithIcon(
            color: Colors.purple[700],
            truncate: false,
            icon: Icons.phone,
            text:
                "${currOrder.unloadContact3.name} - ${currOrder.unloadContact3.phone}",
            maxWidth: fullWidth * 0.8,
            onclick: () async {
              await FlutterPhoneDirectCaller.callNumber(
                  currOrder.unloadContact3.phone);
            },
            fontSize: 16));
      }

      unloadContacts = ExpandablePanel(
          header: FlatButtonWithIcon(
              color: Colors.purple[900],
              truncate: false,
              icon: Icons.person_outline_sharp,
              text: "Контакты выгрузки",
              maxWidth: fullWidth * 0.8,
              onclick: null,
              fontSize: 18),
          expanded: Column(children: items));
    }

    // конец блока предзагрузки виджетов, далее идёт уже билд экрана

    if (isLoading)
      return CenterPreloader();
    else
      return ListView(
        padding: EdgeInsets.all(10),
        children: [
          Container(
              decoration: BoxDecoration(color: Colors.yellow[100]),
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Row(
                    children: [
                      Container(
                          width: 60,
                          height: 60,
                          child: Center(
                              child: Image.asset(
                                  currTransport.getIconAssetName(),
                                  width: 40))),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currTransport.number,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: "Monserat",
                                    color: Colors.black)),
                            Text(currTransport.modelName,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Monserat",
                                    color: Colors.black54))
                          ])
                    ],
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 20),
                      width: 180,
                      child: Text(currDriver.firstLastName(),
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Monserat",
                              color: Colors.blue[900])))
                ],
              )),
          Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Text("Статус: ", style: TextStyle(fontSize: 16)),
                    Text(currOrder.getStatusLabel(),
                        style: currOrder.getStatusLabelStyle(fontSize: 16))
                  ]),
                  Text("Менеджер: ${currOrder.managerLogin}",
                      style: TextStyle(fontSize: 14))
                ],
              )),

          // блок цен и часов
          hoursAndPricesBlock1,

          // блок цен и часов
          hoursAndPricesBlock2,

          Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(specialFormattedDateTime,
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueGrey[800],
                            fontFamily: "Monserat")),
                    Text(currOrder.time,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold)),
                  ])),
          Divider(color: Colors.blueGrey[100], height: 5, thickness: 2),
          Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.2))
              ], color: Colors.white),
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(children: [
                    addressButton1,
                    addressButton2,
                    Container(
                        width: fullWidth,
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                          currOrder.cargoType,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "Monserat",
                              color: Colors.grey[800]),
                        )),
                    Container(
                        width: fullWidth,
                        margin: EdgeInsets.only(top: 10),
                        child: Text(
                          currOrder.cargoDesc,
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        )),
                    loadContacts,
                    unloadContacts,
                  ]))),
          Container(height: 10),
          photoWidget,
          Container(height: 10),
          submitButton
        ],
      );
  }
}
