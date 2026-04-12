import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Handle Hero"),
        backgroundColor: const Color(0xFF29186C),
      ),
      body: Center(
        child: Text("ddde8898"),
      ),
      backgroundColor: const Color(0xFF6742E1),
      // іконки знизу
      // bottomNavigationBar: BottomNavigationBar(items: [
      // backgroundColor: const Color(0xFF29186C),
      //   BottomNavigationBarItem(
      //       icon: SvgPicture.asset(
      //         'asstes/назва',
      //         width: 32,
      //         height: 32,
      //       ),
      //     label: '',
      //   )
      // ]),
    );
  }
}
