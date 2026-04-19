import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SectionData {
  final Color color;
  final Color colorOscuro;
  final int etapa;
  final int seccion;
  final String title;

  const SectionData({
    required this.color,
  required this.colorOscuro,
  required this.etapa,
  required this.seccion,
  required this.title
});

}

class Section extends StatelessWidget {
  final SectionData data;

  const Section({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child:
            Divider(
              color: Colors.pinkAccent,
            )),
            const SizedBox(
              width: 16,
            ),
            Text(data.title,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 18
            ),),
            Expanded(child:
            Divider(
              color: Colors.pinkAccent,
            )),
          ],
        ),
        const SizedBox(height: 24,),
        ...List.generate(9, (i) => Container(
          margin: EdgeInsets.only(
            bottom: i != 8 ? 24 :0,
            left: 24,
            right: 0
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
              color: data.colorOscuro,
                width: 6
              )
            ),
            borderRadius: BorderRadius.circular(90)
          ),
          child: ElevatedButton(
              onPressed: (){},
            style: ElevatedButton.styleFrom(
              backgroundColor: data.color,
              fixedSize: const Size(76, 78),
              elevation: 0,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: Size.zero,
            ),
              child: Image.asset( 'assets/images/door.jpg',  width: 44,
          height: 44),
             ),
        ))
      ],
    );

  }
}
