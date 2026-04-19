import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:handle_hero/ui/section.dart';

Color _darkenColor(Color color, double factor){
  return HSLColor.fromColor(color)
      .withLightness(
      (HSLColor.fromColor(color).lightness - factor).clamp(0.0, 1.0))
      .toColor();
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final data = <SectionData>[
    SectionData(
      color: Colors.lightBlueAccent,
      colorOscuro: _darkenColor(Colors.pinkAccent, 0.2),
      etapa: 1,
      seccion: 1,
      title: 'shos1',
    ),
    SectionData(
      color: Colors.lightBlueAccent,
      colorOscuro: _darkenColor(Colors.pinkAccent, 0.2),
      etapa: 1,
      seccion: 1,
      title: 'shos2',
    ),
    SectionData(
      color: Colors.lightBlueAccent,
      colorOscuro: _darkenColor(Colors.pinkAccent, 0.2),
      etapa: 1,
      seccion: 1,
      title: 'shos3',
    ),
    SectionData(
      color: Colors.lightBlueAccent,
      colorOscuro: _darkenColor(Colors.pinkAccent, 0.2),
      etapa: 1,
      seccion: 1,
      title: 'shos4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        // обєкти типу сердець грощей і тд зверу
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('data'),
            //kartinka
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     SvgPicture.asset(assetName, width: , height: ,),
            //     const SizedBox(width: ,)
            //     const Text('100',
            //     style: TextStyle(
            //       fontWeight: FontWeight.w600,
            //       letterSpacing: 2.0,
            //       fontSize: 16.0,
            //       color: Colors.white
            //     ),
            //     )
            //   ],
            // )
          ],
        ),
        backgroundColor: const Color(0xFF6A6995),
      ),

      body: ListView.separated(
        itemBuilder: (_, i) => Section(
          data: data[i],
        ),
        separatorBuilder: (_,i) => const SizedBox(height: 24,),
        itemCount: data.length,
      ),
      backgroundColor: const Color(0xFF373550),
      // іконки знизу navigation bar
      // bottomNavigationBar: Container(
      //   decoration: BoxDecoration(
      //     border: Border(
      //       top: BorderSide(
      //         color: Colors.white
      //       )
      //     )
      //   ),
      //   child: BottomNavigationBar(
      //   backgroundColor: Colors.transparent,
      //   elevation:0, //висота
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      //   type: BottomNavigationBarType.fixed,
      //   items: [
      //     BottomNavigationBarItem(
      //         icon: SvgPicture.asset(
      //           'asstes/назва',
      //           width: 32,
      //           height: 32,
      //         ),
      //       label: '',
      //     )
      //   ]),
      // ),// можна скільки хочеш цих іконок знизу робити
    );
  }
}
