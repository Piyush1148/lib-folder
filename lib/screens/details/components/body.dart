import 'package:flutter/material.dart';
import 'package:furnituresapp/utils/constants.dart';
import 'package:furnituresapp/models/product.dart';
import 'package:furnituresapp/screens/view_in_3d_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'view_in_3d_button.dart'; 
import 'product_image.dart';

class Body extends StatelessWidget {
  final Product product;

  const Body({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // Adjust font sizes based on screen width
    final double titleFontSize = size.width < 360 ? 18 : 22;
    final double priceFontSize = size.width < 360 ? 16 : 18;
    final double descFontSize = size.width < 360 ? 13 : 14;
    
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: kDefaultPadding,
                vertical: kDefaultPadding / 2,
              ),
              decoration: BoxDecoration(
                color: kBackgroundColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Hero(
                      tag: '${product.id}',
                      child: ProductPoster(
                        size: size,
                        image: product.image,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: kDefaultPadding / 2),
                    child: Text(
                      product.title,
                      style: GoogleFonts.poppins(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: kTextColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  Text(
                    'Rs.${product.price}/-',
                    style: GoogleFonts.poppins(
                      fontSize: priceFontSize,
                      fontWeight: FontWeight.w600,
                      color: kBlueColor,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
                    child: Text(
                      product.description,
                      style: GoogleFonts.poppins(
                        fontSize: descFontSize,
                        color: kTextColor.withOpacity(0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 5,
                    ),
                  ),
                  SizedBox(height: kDefaultPadding / 2),
                ],
              ),
            ),
            ViewIn3DButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewIn3DScreen(
                      product: product,
                    ), 
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
