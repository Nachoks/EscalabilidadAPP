import 'package:flutter/material.dart';

class LogoAppbar extends StatelessWidget {
  const LogoAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      height: kToolbarHeight,
      child: Image.asset('assets/images/LOGO.png', fit: BoxFit.contain),
    );
  }
}
