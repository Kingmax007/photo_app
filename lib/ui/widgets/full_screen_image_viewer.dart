import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_app/services/helper.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  FullScreenImageViewer({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0.0,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          splashColor: Colors.transparent,
          icon: Icon(
            Icons.clear,
            color: Colors.white,
          ),
          onPressed: () {
            FocusScope.of(context).unfocus();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        child: networkImage(
          imageUrl,
          fit: BoxFit.contain,
          height: double.infinity,
          width: double.infinity,
        ),
      ),
    );
  }
}
