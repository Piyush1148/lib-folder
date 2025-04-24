import 'package:flutter/material.dart';
import 'package:furnituresapp/utils/constants.dart';

class ViewIn3DButton extends StatelessWidget {
  const ViewIn3DButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(kDefaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFFCBF1E),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent, // Keeps the button background transparent
            shadowColor: Colors.transparent,
          ),
          child: Text(
            "View in 3D",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}