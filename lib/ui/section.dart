import 'package:flutter/cupertino.dart';

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
  const Section({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
