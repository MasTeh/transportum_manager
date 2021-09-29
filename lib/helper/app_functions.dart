import 'dart:async';
import 'dart:convert';

import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share/share.dart';
import 'package:transportumformanager/helper/preloader.dart';
import 'package:transportumformanager/network/socket.dart';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_service_plugin/flutter_foreground_service_plugin.dart';

class AppFunctions {
  static void startForegroud(String title, String text) async {
    stopForeground();

    await FlutterForegroundServicePlugin.startForegroundService(
      notificationContent: NotificationContent(
        iconName: 'ic_launcher',
        titleText: title,
        color: Colors.red,
        priority: NotificationPriority.high,
      ),
      notificationChannelContent: NotificationChannelContent(
        id: 'transportum',
        nameText: title,
        descriptionText: text,
      ),
      isStartOnBoot: true,
    );
  }

  static void stopForeground() {
    FlutterForegroundServicePlugin.stopForegroundService();
  }

  static void setNotificationTitle(String title, String text) async {
    await FlutterForegroundServicePlugin.refreshForegroundServiceContent(
      notificationContent: NotificationContent(
        iconName: 'ic_launcher',
        titleText: title,
        bodyText: text,
        subText: 'Транспортуп',
        color: Colors.green[800],
      ),
    );
  }

  static void openGalleryView(BuildContext pageContext, List<String> urls,
      {Function removeFunction, int initialPage = 0}) {
    Widget removeButton = Text("");
    if (removeFunction != null) {
      removeButton = TextButton.icon(
          onPressed: () async {
            removeFunction();
          },
          icon: Icon(Icons.delete_forever, color: Colors.red, size: 25),
          label: Text("Удалить",
              style: TextStyle(color: Colors.red, fontSize: 16)));
    }

    final PageController pageController = PageController(initialPage: initialPage);

    Navigator.push(
        pageContext,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                appBar: AppBar(title: Text('Просмотр фото')),
                persistentFooterButtons: [
                  TextButton.icon(
                      onPressed: () async {
                        try {
                          
                          int index = pageController.page.round();

                          showPreloader(pageContext);

                          var downloadedImageId =
                              await ImageDownloader.downloadImage(urls[index]);

                          var downloadedPath =
                              await ImageDownloader.findPath(downloadedImageId);

                          hidePreloader();

                          Share.shareFiles([downloadedPath]);
                        } catch (error) {
                          log.e(error);
                        }
                      },
                      icon: Icon(Icons.share, color: Colors.black, size: 25),
                      label: Text("Поделиться",
                          style: TextStyle(color: Colors.black, fontSize: 16))),
                  removeButton,
                ],
                body: PhotoViewGallery.builder(
                  pageController: pageController,
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(urls[index]),
                      initialScale: PhotoViewComputedScale.contained,
                      minScale: PhotoViewComputedScale.contained
                    );
                  },
                  itemCount: urls.length,
                  loadingBuilder: (context, event) => Center(
                    child: Container(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                event.expectedTotalBytes,
                      ),
                    ),
                  ),
                ))));
  }

  static void openPhotoView(BuildContext context, String url) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Просмотр')),
            body: Container(
                child: PhotoView(
              minScale: PhotoViewComputedScale.contained,
              imageProvider: NetworkImage(url),
            )),
          ),
        ));
  }

  static void openPhotoViewWithShare(BuildContext context, String imageUrl,
      {Function removeFunction}) {
    Widget removeButton = Text("");
    if (removeFunction != null) {
      removeButton = TextButton.icon(
          onPressed: () async {
            removeFunction();
          },
          icon: Icon(Icons.delete_forever, color: Colors.red, size: 25),
          label: Text("Удалить",
              style: TextStyle(color: Colors.red, fontSize: 16)));
    }

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            persistentFooterButtons: [
              TextButton.icon(
                  onPressed: () async {
                    try {
                      showPreloader(context);

                      var downloadedImageId =
                          await ImageDownloader.downloadImage(imageUrl);

                      var downloadedPath =
                          await ImageDownloader.findPath(downloadedImageId);

                      hidePreloader();

                      Share.shareFiles([downloadedPath]);
                    } catch (error) {
                      log.e(error);
                    }
                  },
                  icon: Icon(Icons.share, color: Colors.black, size: 25),
                  label: Text("Поделиться",
                      style: TextStyle(color: Colors.black, fontSize: 16))),
              removeButton,
            ],
            appBar: AppBar(title: Text('Просмотр фото')),
            body: Container(
                child: PhotoView(
              minScale: PhotoViewComputedScale.contained,
              imageProvider: NetworkImage(imageUrl),
            )),
          ),
        ));
  }

  static Future<void> uploadPhoto(
      String owner, int itemId, PickedFile pickedFile) async {
    final bytes = await pickedFile.readAsBytes();
    Map<String, dynamic> query = {};
    query['action'] = 'add_photo';
    query['item_id'] = "$itemId";
    query['owner'] = owner;
    query['base64data'] = base64.encode(bytes);

    Completer completer = Completer();
    // TransportumSocket().query(query, callback: (response) {
    //   completer.complete(response);
    // });

    return completer.future;
  }

  static Future<void> removePhotoWithServer(photo_id) {
    Map<String, dynamic> query = {};
    query['action'] = 'remove_photo';
    query['photo_id'] = photo_id.toString();

    Completer completer = Completer();

    // TransportumSocket().query(query, callback: () {
    //   completer.complete();
    // });

    return completer.future;
  }
}
