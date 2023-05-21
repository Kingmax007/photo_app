import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_fade/image_fade.dart';
import 'package:intl/intl.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:photo_app/constants.dart';

Route animatedNavigation(Widget screen, String pageName, bool fullScreen) {
  return PageRouteBuilder(
    settings: RouteSettings(name: pageName),
    fullscreenDialog: fullScreen,
    pageBuilder: (context, animation, secondaryAnimation) => screen,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(-1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

void push(BuildContext context, Widget destination, String pageName, bool fullScreen) {
  Navigator.of(context).push(animatedNavigation(destination, pageName, fullScreen));
}

bool validateEmail(String value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return false;
  else
    return true;
}

bool validatePassword(String value) {
  String pattern = r'^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?:{}|<>]).*';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return false;
  else
    return true;
}

String capitalizeFirstLetter(String word) {
  return word[0].toUpperCase() + word.substring(1);
}

String avatar(String name) {
  Random random = new Random();
  int index = random.nextInt(avatarColors.length);
  String avatarColor = avatarColors[index];
  return 'https://ui-avatars.com/api/?name=${name}&background=${avatarColor.split('#')[1]}&color=ffffff&size=128';
}

String getRandomString(int length) {
  String chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(_rnd.nextInt(chars.length)),
    ),
  );
}

String timeFromDate(dateTime, {String type = ''}) {
  final date;
  if (dateTime is String) {
    date = DateTime.parse(dateTime);
  } else {
    date = DateTime.parse(dateTime.toDate().toString());
  }
  final date2 = DateTime.now().toLocal();
  final difference = date2.difference(date);
  var year = DateFormat('yyyy').format(date);

  if (difference.inSeconds < 5) {
    return 'Just now';
  } else if (difference.inSeconds <= 60) {
    return '${difference.inSeconds} seconds ago';
  } else if (difference.inMinutes <= 1) {
    return '1 minute ago';
  } else if (difference.inMinutes <= 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours >= 1 && difference.inHours <= 24) {
    return '${difference.inHours} h';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays >= 2 && difference.inDays <= 6) {
    return '${difference.inDays} days ago';
  } else {
    if (year != DateTime.now().year.toString()) {
      return DateFormat('d. MMM ${year}').format(date);
    } else {
      return DateFormat('d. MMM').format(date);
    }
  }
}

Image networkImage(String url, {BoxFit? fit, double? width, double? height, Color? color}) {
  return Image.network(
    url,
    fit: fit,
    width: width,
    height: height,
    color: color,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        width: width,
        height: height,
        child: Image(
          fit: BoxFit.cover,
          height: height,
          width: width,
          image: AssetImage('assets/images/error_image.jpeg'),
        ),
      );
    },
  );
}

Future<Color> getImagePalette(ImageProvider imageProvider) async {
  PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(imageProvider);
  return paletteGenerator.dominantColor!.color;
}

Color hexStringToColor(String hexColor) {
  if (hexColor.isEmpty) {
    hexColor = '#ffffff';
  }
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

Widget displayImage(String picUrl, double size, {bool hasBgColor = false, Color bgColor = Colors.white}) {
  return ImageFade(
    fit: !hasBgColor ? BoxFit.cover : BoxFit.fitWidth,
    width: size,
    height: size,
    placeholder: Container(
      color: !hasBgColor ? Colors.grey.withOpacity(0.3) : bgColor,
      alignment: Alignment.center,
      child: const Icon(Icons.photo, color: Colors.white30, size: 128.0),
    ),
    image: networkImage(picUrl).image,
    errorBuilder: (context, error) => Container(
      width: size,
      height: size,
      child: Image(
        fit: BoxFit.cover,
        height: size,
        width: size,
        image: AssetImage('assets/images/error_image.jpeg'),
      ),
    ),
  );
}

Future showAlertDialog(BuildContext context, String msg, String title, String type) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        content: Text(msg),
        actions: [
          TextButton(
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text(
              type.toUpperCase(),
              style: TextStyle(
                color: type == 'Delete' ? Colors.red : Colors.blue,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

void showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      backgroundColor: color,
      duration: Duration(milliseconds: 4000),
    ),
  );
}

Widget postFileSelectSheet(
  BuildContext context, {
  bool showDeleteMedia = false,
  bool showEditMedia = false,
  bool showChooseFromGallery = false,
  VoidCallback? onDeleteMedia,
  VoidCallback? onEditMedia,
  VoidCallback? onChooseFromGallery,
}) {
  FocusScope.of(context).unfocus();
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Visibility(
        visible: showEditMedia,
        child: Container(
          margin: EdgeInsets.only(top: 10),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(FontAwesomeIcons.pencil, size: 18, color: Colors.white),
            ),
            contentPadding: EdgeInsets.only(left: 20),
            title: Text(
              'Edit',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: onEditMedia,
          ),
        ),
      ),
      Visibility(
        visible: showDeleteMedia,
        child: Container(
          margin: EdgeInsets.only(top: 10),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.trashCan,
                size: 18,
                color: Colors.white,
              ),
            ),
            contentPadding: EdgeInsets.only(left: 20),
            title: Text(
              'Delete',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: onDeleteMedia,
          ),
        ),
      ),
      Visibility(
        visible: showChooseFromGallery,
        child: Container(
          margin: EdgeInsets.only(top: 10),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.file_present, size: 18, color: Colors.white),
            ),
            contentPadding: EdgeInsets.only(left: 20),
            title: Text(
              'Choose from gallery',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: onChooseFromGallery,
          ),
        ),
      ),
      SizedBox(height: 20),
    ],
  );
}
