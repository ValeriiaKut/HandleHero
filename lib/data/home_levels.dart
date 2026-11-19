import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/utils/my_images.dart';

class HomeLevels {
  static const List<LevelData> all = [
    LevelData(left: 280, top: 5, bg: MyImages.easyLevel, number: MyImages.num1, title: 'Level 1'),
    LevelData(left: 130, top: 40, bg: MyImages.easyLevel, number: MyImages.num2, title: 'Level 2'),
    LevelData(left: 10, top: 160, bg: MyImages.easyLevel, number: MyImages.num3, title: 'Level 3'),
    LevelData(left: 75, top: 300, bg: MyImages.hardLevel, number: null, title: 'Hard 1'),
    LevelData(left: 280, top: 740, bg: MyImages.easyLevel, number: MyImages.num4, title: 'Level 4'),
    LevelData(left: 140, top: 790, bg: MyImages.easyLevel, number: MyImages.num5, title: 'Level 5'),
    LevelData(left: 20, top: 895, bg: MyImages.easyLevel, number: MyImages.num6, title: 'Level 6'),
    LevelData(left: 75, top: 1035, bg: MyImages.hardLevel, number: null, title: 'Hard 2'),
    LevelData(left: 290, top: 1470, bg: MyImages.easyLevel, number: MyImages.num7, title: 'Level 7'),
    LevelData(left: 130, top: 1510, bg: MyImages.easyLevel, number: MyImages.num8, title: 'Level 8'),
    LevelData(left: 20, top: 1630, bg: MyImages.easyLevel, number: MyImages.num9, title: 'Level 9'),
    LevelData(left: 75, top: 1765, bg: MyImages.hardLevel, number: null, title: 'Hard 3'),
  ];
}
