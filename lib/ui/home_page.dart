import 'package:flutter/material.dart';
import 'package:handle_hero/utils/my_images.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Silent Sings'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 2000, // висота скролу
          child: Stack(
            children: [
              // Фон
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(MyImages.grass),
                      repeat: ImageRepeat.repeatY, // повтор вниз
                    ),
                  ),
                ),
              ),
//modu;1
              // Кнопка 1
              Positioned(
                left: 280,
                top: 5,
                child: InkWell(
                  onTap: () {
                    print('Кнопка 1');
                  },
                  child: Image.asset(
                    MyImages.easyLevel,
                    width: 100,
                  ),
                ),
              ),

              // Кнопка 1
              Positioned(
                left: 130,
                top: 40,
                child: InkWell(
                  onTap: () {
                    print('Кнопка 1');
                  },
                  child: Image.asset(
                    MyImages.easyLevel,
                    width: 100,
                  ),
                ),
              ),

              Positioned(
                left: 20,
                top: 160,
                child: InkWell(
                  onTap: () {
                    print('Кнопка 1');
                  },
                  child: Image.asset(
                    MyImages.easyLevel,
                    width: 100,
                  ),
                ),
              ),


              // Кнопка 1
              Positioned(
                left: 75,
                top: 300,
                child: InkWell(
                  onTap: () {
                    print('Hard 1');
                  },
                  child: Image.asset(
                    MyImages.hardLevel,
                    width: 110,
                  ),
                ),
              ),
              // Кнопка 1
              Positioned(
                left: 10,
                top: 420,
                child: InkWell(
                  onTap: () {
                    print('Hard 1');
                  },
                  child: Image.asset(
                    MyImages.statue,
                    width: 400,
                  ),
                ),
              ),
//modu;2

              Positioned(
                left: 280,
                top: 740,
                child: InkWell(
                  onTap: () {
                    print('Кнопка 1');
                  },
                  child: Image.asset(
                    MyImages.easyLevel,
                    width: 100,
                  ),
                ),
              ),

              // Кнопка 1
              Positioned(
                left: 130,
                top: 785,
                child: InkWell(
                  onTap: () {
                    print('Кнопка 1');
                  },
                  child: Image.asset(
                    MyImages.easyLevel,
                    width: 100,
                  ),
                ),
              ),

              Positioned(
                left: 20,
                top: 895,
                child: InkWell(
                  onTap: () {
                    print('Кнопка 1');
                  },
                  child: Image.asset(
                    MyImages.easyLevel,
                    width: 100,
                  ),
                ),
              ),


              // Кнопка 1
              Positioned(
                left: 75,
                top: 1035,
                child: InkWell(
                  onTap: () {
                    print('Hard 1');
                  },
                  child: Image.asset(
                    MyImages.hardLevel,
                    width: 110,
                  ),
                ),
              ),
              // Кнопка 1
              Positioned(
                left: 10,
                top: 1150,
                child: InkWell(
                  onTap: () {
                    print('Hard 1');
                  },
                  child: Image.asset(
                    MyImages.statue,
                    width: 400,
                  ),
                ),
              ),
              // modul3
              // Positioned(
              //   left: 290,
              //   top: 900,
              //   child: InkWell(
              //     onTap: () {
              //       print('Кнопка 1');
              //     },
              //     child: Image.asset(
              //       MyImages.easyLevel,
              //       width: 100,
              //     ),
              //   ),
              // ),
              //
              // // Кнопка 1
              // Positioned(
              //   left: 120,
              //   top: 950,
              //   child: InkWell(
              //     onTap: () {
              //       print('Кнопка 1');
              //     },
              //     child: Image.asset(
              //       MyImages.easyLevel,
              //       width: 100,
              //     ),
              //   ),
              // ),
              //
              // Positioned(
              //   left: 10,
              //   top: 1080,
              //   child: InkWell(
              //     onTap: () {
              //       print('Кнопка 1');
              //     },
              //     child: Image.asset(
              //       MyImages.easyLevel,
              //       width: 100,
              //     ),
              //   ),
              // ),
              //
              //
              // // Кнопка 1
              // Positioned(
              //   left: 75,
              //   top: 1210,
              //   child: InkWell(
              //     onTap: () {
              //       print('Hard 1');
              //     },
              //     child: Image.asset(
              //       MyImages.hardLevel,
              //       width: 110,
              //     ),
              //   ),
              // ),
              // // Кнопка 1
              // Positioned(
              //   left: 10,
              //   top: 1600,
              //   child: InkWell(
              //     onTap: () {
              //       print('Hard 1');
              //     },
              //     child: Image.asset(
              //       MyImages.statue,
              //       width: 400,
              //     ),
              //   ),
              // ),

            ],
          ),
        ),
      ),
    );
  }
}