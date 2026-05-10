import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilityHelper {
  static redirectToURL(String urlString) async {
    if (await canLaunch(urlString)) {
      await launch(urlString);
    } else {
      throw 'Could not launch $urlString';
    }
  }
}

class RadiantGradientMask extends StatelessWidget {
  RadiantGradientMask({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return RadialGradient(
          center: Alignment.bottomLeft,
          radius: 0.5,
          colors: <Color>[Colors.purple, Colors.blue],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
