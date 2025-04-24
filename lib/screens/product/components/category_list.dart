import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:furnituresapp/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryList extends StatefulWidget {
  final Function(int) onCategorySelected;
  final int selectedIndex;

  const CategoryList({
    Key? key,
    required this.onCategorySelected,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.dashboard_outlined, "text": "All"},
    {"icon": Icons.weekend_outlined, "text": "Sofa"},
    {"icon": Icons.chair_outlined, "text": "Chair"},
    {"icon": Icons.storefront_outlined, "text": "Cupboard"},
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    // Make container height responsive
    final double containerHeight = size.height * 0.11;
    final double minHeight = 70;
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: kDefaultPadding / 2),
      height: containerHeight > minHeight ? containerHeight : minHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) => buildCategory(index, size),
      ),
    );
  }

  Widget buildCategory(int index, Size size) {
    final isSelected = widget.selectedIndex == index;
    // Adjust icon and text size based on screen width
    final double iconSize = size.width < 360 ? 30 : 35;
    final double fontSize = size.width < 360 ? 11 : 12;
    
    return GestureDetector(
      onTap: () => widget.onCategorySelected(index),
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(
          left: kDefaultPadding,
          right: index == categories.length - 1 ? kDefaultPadding : 0,
        ),
        padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
        decoration: BoxDecoration(
          color: isSelected ? kBlueColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.black12,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? kBlueColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              offset: const Offset(0, 7),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              categories[index]["icon"],
              size: iconSize,
              color: isSelected ? Colors.white : kTextColor.withOpacity(0.8),
            ),
            const SizedBox(height: 5),
            Text(
              categories[index]["text"],
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : kTextColor.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}