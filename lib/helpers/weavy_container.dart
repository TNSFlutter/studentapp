import 'package:flutter/material.dart';

class CurveClipperTop extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width * .25, size.height - 20, size.width * .5, size.height - 40);
    path.quadraticBezierTo(size.width * .75, size.height - 60, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class CurveClipperBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 15);
    path.quadraticBezierTo(size.width * .25, size.height - 30, size.width * .5, size.height - 20);
    path.quadraticBezierTo(size.width * .75, size.height - 5, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     path.lineTo(0, size.height);
//     path.quadraticBezierTo(size.width / 4, size.height - 40, size.width / 2, size.height - 20);
//     path.quadraticBezierTo(3 / 4 * size.width, size.height, size.width, size.height - 30);
//     path.lineTo(size.width, 0);

//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }
