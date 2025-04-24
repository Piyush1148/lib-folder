import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:furnituresapp/utils/constants.dart';
import 'package:furnituresapp/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/body.dart';

class ProductsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kPrimaryColor,
              kPrimaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Body(),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double fontSize = size.width < 360 ? 18 : 22;
    
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.weekend_outlined, color: kBlueColor),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              "Explore ARniture!",
              style: GoogleFonts.poppins(
                color: kTextColor,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: kTextColor),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.logout_outlined, color: kTextColor),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LogIn()),
            );
          },
        ),
      ],
    );
  }
}// products_screen.dart