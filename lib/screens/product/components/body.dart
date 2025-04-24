import 'package:flutter/material.dart';
import 'package:furnituresapp/components/generate_3d_button.dart';
import 'package:furnituresapp/utils/constants.dart';
import 'package:furnituresapp/models/product.dart';
import 'package:furnituresapp/screens/details/details_screen.dart';
import 'package:furnituresapp/screens/meshy_screen.dart';

import 'category_list.dart';
import 'product_card.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int selectedCategoryIndex = 0;
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filterProducts();
  }

  void _filterProducts() {
    setState(() {
      if (selectedCategoryIndex == 0) {
        // Show all products for "All" category
        filteredProducts = products;
      } else {
        // Filter products based on selected category
        String categoryName = _getCategoryName(selectedCategoryIndex);
        filteredProducts = products
            .where((product) => _matchesCategory(product, categoryName))
            .toList();
      }
    });
  }

  // Helper method to match products to the correct category
  bool _matchesCategory(Product product, String categoryName) {
    switch (categoryName) {
      case "Sofa":
        return product.category == "Sofa";
      case "Chair":
        return product.category == "Armchair";
      case "Cupboard":
        return product.category == "Cupboard";
      default:
        return true;
    }
  }

  String _getCategoryName(int index) {
    switch (index) {
      case 1: return "Sofa";
      case 2: return "Chair";
      case 3: return "Cupboard";
      default: return "All";
    }
  }

  void _onCategorySelected(int index) {
    setState(() {
      selectedCategoryIndex = index;
      _filterProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          Generate3DButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MeshyScreen(),
                ),
              );
            },
          ),
          CategoryList(
            onCategorySelected: _onCategorySelected,
            selectedIndex: selectedCategoryIndex,
          ),
          SizedBox(height: kDefaultPadding / 2),
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 70),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                ),
                ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: filteredProducts.length,
                  padding: EdgeInsets.only(
                    top: 25,
                    left: size.width * 0.02,
                    right: size.width * 0.02,
                    bottom: 25,
                  ),
                  itemBuilder: (context, index) => ProductCard(
                    itemIndex: index,
                    product: filteredProducts[index],
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            product: filteredProducts[index],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}