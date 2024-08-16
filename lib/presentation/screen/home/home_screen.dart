import 'package:dance_club_comuna_8/presentation/widgets/carousel_images.dart';
import 'package:dance_club_comuna_8/presentation/widgets/video_player_youtube.dart';
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
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20), // Padding
        const SizedBox(
          width: 300,
          height: 200,
          child: Card(
            child: ListTile(
              title: Text('Objetivo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                  )),
              subtitle: Text(
                  'Invitar a las personas adultas de la tercera edad a hacer parte de nuestras clases de danza en la comuna 8.'),
            ),
          ),
        ),
        const SizedBox(height: 20), // Padding
        CarouselWithControls(
          width: double.infinity,
          height: 250,
          images: images,
        ),
        const SizedBox(height: 20), // Padding
        const SizedBox(
          width: 300,
          height: 200,
          child: Card(
            child: ListTile(
              title: Text('Logros del club',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                  )),
              subtitle: Text(
                  '¿Qué logros del club te enorgullecen? Comparte algunos aspectos destacados a continuación. Puedes incluir un video, un documento o una presentación que resuma el trabajo realizado.'),
            ),
          ),
        ),
        const SizedBox(height: 20), // Padding
        Container(
          width: double.infinity,
          color: Theme.of(context).primaryColor, // Usar color del tema
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.asset(
                'assets/images/0006.webp',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 16), // Espacio entre imagen y texto
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intereses',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vamos enfocados principalmente a las personas de la tercera edad, ya que este es un lugar seguro para que los adultos puedan relacionarse con otras personas y tengan el movimiento que muchas veces requieren.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
