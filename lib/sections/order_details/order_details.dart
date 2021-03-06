import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:transportumformanager/global/ChangesListener.dart';
import 'package:transportumformanager/global/InsideBuffer.dart';
import 'package:transportumformanager/global/appstorage/AppStorage.dart';
import 'package:transportumformanager/helper/remove_decimal_zero.dart';
import 'package:transportumformanager/helper/routes.dart';
import 'package:transportumformanager/helper/toast.dart';
import 'package:transportumformanager/model/order.dart';
import 'package:transportumformanager/model/photo.dart';
import 'package:transportumformanager/model/transport.dart';
import 'package:transportumformanager/model/user_driver.dart';
import 'package:transportumformanager/profile.dart';
import 'package:transportumformanager/sections/app_data/app_data.dart';
import 'package:transportumformanager/helper/app_functions.dart';
import 'package:transportumformanager/helper/preloader.dart';
import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/sections/order_details/order_details_api.dart';
import 'package:transportumformanager/sections/order_edit/order_edit.dart';
import 'package:transportumformanager/widgets/TextIcon.dart';
import 'package:transportumformanager/widgets/blink_label.dart';
import 'package:transportumformanager/helper/dialogs.dart';
import 'package:transportumformanager/widgets/photo_gallery.dart';
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
              itemBuilder: (BuildContext itemContext) {
                return [
                  PopupMenuItem(
                      child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (itemContext) => OrderEdit(
                                      orderId: orderId,
                                      editMode: OrderEditMode.edit)),
                            );
                          },
                          icon: Icon(Icons.edit),
                          label: Text("??????????????????????????"))),
                  PopupMenuItem(
                      child: TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (itemContext) => OrderEdit(
                                      orderId: orderId,
                                      editMode: OrderEditMode.dublicate)),
                            );
                          },
                          icon: Icon(Icons.copy),
                          label: Text("??????????????????????"))),
                  PopupMenuItem(
                      child: TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            confirm(context,
                                    content: Text(
                                        "?????????????? ????????????? ?????? ?????????????????????? ????????????????."),
                                    title: Text("???????????"))
                                .then((ok) {
                              if (ok) {
                                OrderDetailsApi().removeOrder(orderId);
                                Navigator.pop(context);
                              }
                            });
                          },
                          icon: Icon(Icons.delete),
                          label: Text("??????????????"))),
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

      InsideBuffer().currentOpenedOrder = currOrder;

      specialFormattedDateTime = orderJSON['date_label3'];

      isLoading = false;

      setState(() {});
    }).onError((error, stackTrace) {
      log.e(stackTrace.toString());
      if (error == OrderDetailsApi.errors.orderNotFound) {
        Dialogs.showAlert(pageContext, "????????????", "?????????? ???? ????????????");
      }
    });
  }

  List<String> imagesUrls = [];
  List<String> bigImagesUrls = [];
  List<String> imagesIds = [];
  dynamic pickImageError;
  String retrieveDataError;

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

    // ?????????? ???????????????????????????? ?????????????????????? ????????????????, ???????????? ?????? ???????????????? ???????????????? ???????????? ?????????? ???????????????? ?? ??????????????
    if (!isLoading) {
      if (currOrder.orderPayMethod == OrderPayMethod.hours) {
        hoursAndPricesBlock1 = Container(
          padding: EdgeInsets.all(10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.timer, color: Colors.blue[900]),
              Container(width: 5),
              Text("${currOrder.getHours()} ?? ??????????????????????",
                  style: TextStyle(
                      color: Colors.blue[900],
                      fontSize: 14,
                      fontWeight: FontWeight.bold))
            ]),
            Row(children: [
              Icon(Icons.timer, color: Colors.blueAccent[700]),
              Container(width: 5),
              Text("${currOrder.getHoursForDriver()} ?? ????????????????",
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
                    Text("${currOrder.getPricePerHour()} ??????/??????",
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
              Text("${currOrder.getPriceSeller()} ???????? ????????????????????",
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
                        "${removeDecimalZeroFormat(currOrder.hoursForDriver)} ?? ????????????????",
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
                    Text("${currOrder.getMarjaString()} ?????? ??????????",
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
              text: "???????????????? ????????????????",
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
              text: "???????????????? ????????????????",
              maxWidth: fullWidth * 0.8,
              onclick: null,
              fontSize: 18),
          expanded: Column(children: items));
    }

    // ?????????? ?????????? ???????????????????????? ????????????????, ?????????? ???????? ?????? ???????? ????????????

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
                            Row(
                              children: [
                                Text(currTransport.number,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: "Monserat",
                                        color: Colors.black)),
                                currOrder.haveTrailer
                                    ? Text(currOrder.getTrailerLabelShort(),
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: "Monserat",
                                            color: Colors.black))
                                    : Text("")
                              ],
                            ),
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
                      width: 150,
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
                    Text("????????????: ", style: TextStyle(fontSize: 16)),
                    Text(currOrder.getStatusLabel(),
                        style: currOrder.getStatusLabelStyle(fontSize: 16))
                  ]),
                  Text("????????????????: ${currOrder.managerLogin}",
                      style: TextStyle(fontSize: 14))
                ],
              )),

          // ???????? ?????? ?? ??????????
          hoursAndPricesBlock1,

          // ???????? ?????? ?? ??????????
          hoursAndPricesBlock2,

          // ??????????
          PhotoGallery(owner: PhotoOwner.orders, itemId: currOrder.id),

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
