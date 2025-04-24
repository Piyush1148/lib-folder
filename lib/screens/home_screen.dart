import 'package:flutter/material.dart';
import 'package:furnituresapp/models/product.dart'; // Import product.dart
import 'package:furnituresapp/screens/product/products_screen.dart'; // Import products_screen.dart
import 'package:furnituresapp/utils/constants.dart'; // Import constants.dart

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    ProductsScreen(), // Remove const keyword
    const Generate3D(),
    const ARView(),
    const Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Furniture AR'),
        backgroundColor: kPrimaryColor, // Use kPrimaryColor from constants.dart
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_in_ar),
            label: 'Generate 3D',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'AR View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor, // Use kPrimaryColor from constants.dart
        onTap: _onItemTapped,
      ),
    );
  }
}

class Generate3D extends StatelessWidget {
  const Generate3D({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Generate 3D Models Here',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class ARView extends StatelessWidget {
  const ARView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'View in AR Here',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'User Profile Here',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}