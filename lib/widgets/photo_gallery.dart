import 'dart:async';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:transportumformanager/helper/dialogs.dart';
import 'package:transportumformanager/helper/photo_helper.dart';
import 'package:transportumformanager/model/photo.dart';
import 'package:transportumformanager/network/query.dart';
import 'package:transportumformanager/network/socket.dart';
import 'package:transportumformanager/widgets/preloaders.dart';

final log = Logger();

class PhotoGallery extends StatefulWidget {
  @required
  final PhotoOwner owner;
  @required
  final int itemId;
  final bool canDelete;
  final bool canShare;

  PhotoGallery(
      {Key key,
      this.owner,
      this.itemId,
      this.canDelete = true,
      this.canShare = true})
      : super(key: key);

  @override
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  List<PhotoModel> allPhotos = [];
  List<Widget> photosWidgets = [];
  Completer completer = Completer();
  bool isLoading = true;
  DateTime today = DateTime.now();
  final ImagePicker _picker = ImagePicker();

  BuildContext pageContext;

  Future<void> loadData() {
    Completer completer = Completer();
    PhotoHelper.getPhotos(widget.itemId, widget.owner).then((photos) {
      allPhotos = photos;
      isLoading = false;
      completer.complete();
    });
    return completer.future;
  }

  void onAddImageButtonPressed(BuildContext context) async {
    Dialogs.cameraChooseDialog(context, () {
      choosePhoto(ImageSource.camera);
    }, () {
      choosePhoto(ImageSource.gallery);
    });
  }

  void choosePhoto(ImageSource source) async {
    try {
      final pickedFile = await _picker.getImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      await PhotoHelper.uploadPhoto(widget.owner, widget.itemId, pickedFile);
      await loadData();

      setState(() {});
    } catch (e) {}
  }

  void loadItemsWidgets(BuildContext context) {
    photosWidgets = [];
    allPhotos.asMap().forEach((index, photoItem) {
      photosWidgets.add(Container(
          padding: EdgeInsets.all(5),
          child: GestureDetector(
            onTap: () {
              PhotoHelper.openGalleryView(context, allPhotos,
                  initialPage: index,
                  canRemove: widget.canDelete, photoRemoveCallback: () {
                setState(() {
                  allPhotos.removeAt(index);
                });
              });
            },
            child: Image.network(photoItem.photoSmallURL, loadingBuilder:
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
          )));
    });

    photosWidgets.add(Container(
        decoration:
            BoxDecoration(border: Border.all(width: 1, color: Colors.green)),
        margin: EdgeInsets.all(10),
        child: InkWell(
            onTap: () {
              this.onAddImageButtonPressed(pageContext);
            },
            child: Center(
                child: Icon(Icons.add, color: Colors.green, size: 30)))));
  }

  @override
  void initState() {
    super.initState();

    loadData().then((value) {
      setState(() {});
    });
  }

  bool isOrderNotToday(PhotoModel photo) {
    DateTime expireDate = photo.created.add(Duration(hours: 16));
    return (today.isAfter(expireDate));
  }

  @override
  Widget build(BuildContext context) {
    pageContext = context;

    if (isLoading) {
      return Container(
          decoration: BoxDecoration(color: Colors.white.withAlpha(150)),
          padding: EdgeInsets.all(20),
          child: CenterPreloader());
    }

    if (allPhotos.length == 0) {
      return Container(
        decoration: BoxDecoration(color: Colors.white.withAlpha(150)),
        padding: EdgeInsets.all(20),
        child: Text("Фото отсутствуют"),
        alignment: Alignment.center,
      );
    }

    loadItemsWidgets(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          GridView.count(
              crossAxisCount: 4,
              children: photosWidgets,
              shrinkWrap: true,
              physics: BouncingScrollPhysics())
        ],
      ),
    );
  }
}
