import 'package:dance_club_comuna_8/presentation/widgets/carousel_images.dart';
import 'package:dance_club_comuna_8/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';

class BuildHomeScreen extends StatefulWidget {
  const BuildHomeScreen({super.key});

  @override
  State<BuildHomeScreen> createState() => _BuildHomeScreenState();
}

class _BuildHomeScreenState extends State<BuildHomeScreen> {
  var images = [
    'assets/images/0001.webp',
    'assets/images/0002.webp',
    'assets/images/0003.webp',
    'assets/images/0004.webp',
    'assets/images/0005.webp',
    'assets/images/0006.webp',
    'assets/images/0007.webp',
    'assets/images/0008.webp',
    'assets/images/0009.webp',
    'assets/images/0010.webp',
    'assets/images/0011.webp',
    'assets/images/0012.webp',
    'assets/images/0013.webp',
    'assets/images/0014.webp',
    'assets/images/0015.webp',
    'assets/images/0016.webp',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20), // Padding
            const Wrap(
              runSpacing: 16.0,
              spacing: 26.0,
              alignment: WrapAlignment.center,
              children: [
                InfoCard(
                  isPrimary: true,
                  icon: Icons.emoji_people_outlined,
                  title: 'Objetivo',
                  content:
                      'Proporcionar un espacio inclusivo para que los adultos mayores de la comuna 8 se expresen a través de la danza, celebrando la diversidad cultural, fomentando la creatividad y promoviendo una vejez digna y activa.',
                ),
                InfoCard(
                  isPrimary: false,
                  icon: Icons.emoji_events_outlined,
                  title: 'Logros del club',
                  content:
                      '¿Qué logros del club te enorgullecen? Comparte algunos aspectos destacados a continuación. Puedes incluir un video, un documento o una presentación que resuma el trabajo realizado.',
                ),
                InfoCard(
                  isPrimary: true,
                  icon: Icons.interests_outlined,
                  title: 'Intereses',
                  content:
                      'Vamos enfocados principalmente a las personas de la tercera edad, ya que este es un lugar seguro para que los adultos puedan relacionarse con otras personas y tengan el movimiento que muchas veces requieren.',
                ),
              ],
            ),
            const SizedBox(height: 20), // Padding
            CarouselWithControls(
              width: double.infinity,
              height: 250,
              images: images,
            ),
          ],
        ),
      ),
    );
  }
}
