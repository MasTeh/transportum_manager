import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';


void showPreloader(BuildContext context) {
    Loader.show(context,
        isAppbarOverlay: true,
        isBottomBarOverlay: false,
        progressIndicator: CircularProgressIndicator(),
        themeData: Theme.of(context).copyWith(accentColor: Colors.blue[900]),
        overlayColor: Color(0x44FFFFFF));
  }

void hidePreloader() {
    Loader.hide();
  }