import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar_item.dart';
import 'package:test_location/pages/addPage.dart';
import 'package:test_location/pages/map.dart';
import 'package:test_location/pages/profile.dart';
import 'package:test_location/tileManager/TileProviderModel.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TileProviderModel(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeNavPage(),
    );
  }
}

class HomeNavPage extends StatefulWidget {
  const HomeNavPage({Key? key}) : super(key: key);
  @override
  _HomeNavPageState createState() => _HomeNavPageState();
}

class _HomeNavPageState extends State<HomeNavPage> {
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: const <Widget>[
          MapPage(),
          addPointPage(),
          ProfilePage(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: RollingBottomBar(
        controller: _controller,
        flat: true,
        useActiveColorByDefault: false,
        color: const Color(0xFF262626), // the color of the bar
        items: const [
          RollingBottomBarItem(Icons.map,
              label: 'home', activeColor: Colors.white),
          RollingBottomBarItem(Icons.add,
              label: 'add', activeColor: Colors.white),
          RollingBottomBarItem(Icons.person,
              label: 'profile', activeColor: Colors.white),
        ],
        enableIconRotation: true,
        onTap: (index) {
          _controller.animateToPage(
            index,
            duration: const Duration(microseconds: 300),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}
