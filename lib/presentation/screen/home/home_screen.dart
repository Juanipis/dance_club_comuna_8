import 'package:dance_club_comuna_8/presentation/widgets/carousel_images.dart';
import 'package:flutter/material.dart';

Widget buildHomeScreen(BuildContext context) {
  var images = [
    'assets/images/background.jpg',
    'assets/images/background2.jpg',
    'assets/images/background3.jpg',
    'https://images.pexels.com/photos/20063027/pexels-photo-20063027/free-photo-of-arte-edificio-modelo-estampado.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
  ];

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
              'assets/images/background.jpg', // Reemplaza con la ruta de tu imagen
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
