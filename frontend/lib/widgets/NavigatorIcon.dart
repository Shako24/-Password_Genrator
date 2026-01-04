import 'package:flutter/material.dart';

class NavigatorIcon extends StatelessWidget {
  const NavigatorIcon({
    super.key, required this.title, required this.icon, this.onTap,
  });

  final String title;
  final IconData icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 25),
        child: Column(
          children: [
            Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey[200],
                ),
                child: Icon(icon)),
            const SizedBox(height: 20,),
            SizedBox(
              width: 66,
              child: Text(
                title,
                style: const TextStyle(color: Colors.black),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}