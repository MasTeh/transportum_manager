import 'package:flutter/material.dart';

class CenterPreloader extends StatelessWidget {
  const CenterPreloader();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: new SizedBox(
      height: 50.0,
      width: 50.0,
      child: new CircularProgressIndicator(
        value: null,
        strokeWidth: 4.0,
      ),
    ));
  }
}

class ImagePreloader extends StatelessWidget {
  const ImagePreloader();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      child: CircularProgressIndicator(
        value: null,
        strokeWidth: 3.0,
      ),
    );
  }
}
