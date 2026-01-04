import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'Constants.dart';

class CustomWidgetWithBorderAndIcon extends StatelessWidget {
  final Color backgroundColor;
  final String text;
  final String icon;

  const CustomWidgetWithBorderAndIcon({
    super.key,
    required this.backgroundColor,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              icon,
              color: Colors.white,
              height: 50,
              width: 50,
            ),
            // const SizedBox(height: 4), // Space between icon and text
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomThemeButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomThemeButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: TColors.primaryColor,
        foregroundColor: TColors.secondaryColor,// Button color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        textStyle: const TextStyle(fontSize: 15, color: Colors.white),
        // minimumSize: Size(200, 50),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)),)
      ),
      child: Text(text),
    );
  }
}

