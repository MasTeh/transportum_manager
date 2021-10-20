import 'dart:async';
import 'dart:convert';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share/share.dart';
import 'package:transportumformanager/helper/preloader.dart';
import 'package:transportumformanager/helper/toast.dart';
import 'package:transportumformanager/model/photo.dart';
import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/network/socket.dart';

final log = Logger();

class PhotoHelper {
  static void openGalleryView(BuildContext pageContext, List<PhotoModel> photos,
      {bool canRemove = true,
      Function photoRemoveCallback,
      int initialPage = 0}) {
    final PageController pageController =
        PageController(initialPage: initialPage);

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
                              await ImageDownloader.downloadImage(
                                  photos[index].photoBigURL);

                          var downloadedPath =
                              await ImageDownloader.findPath(downloadedImageId);

                          hidePreloader();

                          Share.shareFiles([downloadedPath]);
                        } catch (error) {
                          log.d(error);
                        }
                      },
                      icon: Icon(Icons.share, color: Colors.black, size: 25),
                      label: Text("Поделиться",
                          style: TextStyle(color: Colors.black, fontSize: 16))),
                  canRemove
                      ? TextButton.icon(
                          onPressed: () async {
                            int index = pageController.page.round();
                            if (await confirm(
                              pageContext,
                              title: Text('Удалить фото?'),
                              content: Text('Точно?'),
                              textOK: Text('Да'),
                              textCancel: Text('Нет'),
                            )) {
                              PhotoHelper.removePhoto(photos[index])
                                  .then((value) {
                                if (value['result'] == 'ok') {
                                  Navigator.pop(pageContext);
                                  Toasts.showShort("Фото было удалено");
                                  if (photoRemoveCallback != null)
                                    photoRemoveCallback();
                                } else {
                                  Toasts.showShort("Не удалось удалить фото");
                                }
                              });
                            }
                          },
                          icon: Icon(Icons.delete_forever,
                              color: Colors.red, size: 25),
                          label: Text("Удалить",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 16)))
                      : Text(""),
                ],
                body: PhotoViewGallery.builder(
                  pageController: pageController,
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                        imageProvider: NetworkImage(photos[index].photoBigURL),
                        initialScale: PhotoViewComputedScale.contained,
                        minScale: PhotoViewComputedScale.contained);
                  },
                  itemCount: photos.length,
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

  static void openPhotoView(BuildContext context, PhotoModel photo) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Просмотр')),
            body: Container(
                child: PhotoView(
              minScale: PhotoViewComputedScale.contained,
              imageProvider: NetworkImage(photo.photoBigURL),
            )),
          ),
        ));
  }

  static void openPhotoViewWithShare(BuildContext context, PhotoModel photo,
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
                          await ImageDownloader.downloadImage(
                              photo.photoBigURL);

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
              imageProvider: NetworkImage(photo.photoBigURL),
            )),
          ),
        ));
  }

  static Future<void> uploadPhoto(
      PhotoOwner owner, int itemId, PickedFile pickedFile) async {
    final bytes = await pickedFile.readAsBytes();

    SocketQuery query = SocketQuery('add_photo')
        .addParam('action', 'add_photo')
        .addParam('item_id', itemId)
        .addParam('owner', PhotoModel.getStringOwner(owner))
        .addParam('base64data', base64.encode(bytes));

    Completer completer = Completer();
    TransportumSocket().query(query, callback: (response) {
      completer.complete(response);
    });

    return completer.future;
  }

  static Future<void> removePhotoWithServer(int photoId) {
    SocketQuery query =
        SocketQuery('remove_photo').addParam('photo_id', photoId.toString());

    Completer completer = Completer();

    TransportumSocket().query(query, callback: () {
      completer.complete();
    });

    return completer.future;
  }

  static Future<dynamic> getPhotos(int itemId, PhotoOwner photoOwner) {
    Completer completer = Completer();
    TransportumSocket().query(
        SocketQuery("get_photos")
            .addParam("item_id", itemId.toString())
            .addParam("owner", PhotoModel.getStringOwner(photoOwner)),
        callback: (dynamic response) {
      var photosJson = List<dynamic>.from(response['items']);
      List<PhotoModel> photos = [];
      photosJson.forEach((element) {
        photos.add(PhotoModel.fromJSON(element));
      });
      completer.complete(photos);
    });
    return completer.future;
  }

  static Future<dynamic> removePhoto(PhotoModel photo) {
    Completer completer = Completer();

    SocketQuery query =
        SocketQuery('remove_photo').addParam('photo_id', photo.id.toString());

    TransportumSocket().query(query, callback: (response) {
      completer.complete(response);
    });

    return completer.future;
  }
}
