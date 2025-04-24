import 'package:flutter/material.dart';
import '../screens/meshy_screen.dart';
import 'package:furnituresapp/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class Generate3DButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const Generate3DButton({
    Key? key, 
    required this.onPressed
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kSecondaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              kSecondaryColor,
              Color(0xFFFF8A48),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.view_in_ar_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Generate 3D Model',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}