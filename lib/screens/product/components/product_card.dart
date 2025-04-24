import 'package:flutter/material.dart';
import 'package:furnituresapp/models/product.dart';
import 'package:furnituresapp/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class ProductCard extends StatelessWidget {
  const ProductCard({
    Key? key,
    required this.itemIndex,
    required this.product,
    required this.press,
  }) : super(key: key);

  final int itemIndex;
  final Product product;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // Make card height responsive based on screen size
    final double cardHeight = min(160, size.height * 0.2);
    
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      height: cardHeight,
      child: InkWell(
        onTap: press,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 10),
                blurRadius: 15,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              // Background container
              Container(
                height: cardHeight - 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: itemIndex.isEven
                        ? [kBlueColor.withOpacity(0.8), kBlueColor.withOpacity(0.6)]
                        : [kSecondaryColor.withOpacity(0.8), kSecondaryColor.withOpacity(0.6)],
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 5),
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.05),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Product image
              Positioned(
                top: 0,
                right: 0,
                child: Hero(
                  tag: '${product.id}',
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: kDefaultPadding / 2),
                    height: cardHeight,
                    // Calculate width based on screen size to prevent overflow
                    width: min(200, size.width * 0.4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              
              // Product details
              Positioned(
                bottom: 0,
                left: 0,
                child: SizedBox(
                  height: cardHeight - 24,
                  // Calculate width responsively with a minimum
                  width: max(size.width - min(200, size.width * 0.4) - 40, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: kDefaultPadding,
                        ),
                        child: Text(
                          product.title,
                          style: GoogleFonts.poppins(
                            fontSize: size.width < 360 ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: kTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: kDefaultPadding * 1.5,
                          vertical: kDefaultPadding / 4,
                        ),
                        decoration: BoxDecoration(
                          color: itemIndex.isEven ? kBlueColor : kSecondaryColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                        ),
                        child: Text(
                          "Rs.${product.price}",
                          style: GoogleFonts.poppins(
                            fontSize: size.width < 360 ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}