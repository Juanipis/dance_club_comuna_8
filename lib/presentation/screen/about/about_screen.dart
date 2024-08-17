import 'package:dance_club_comuna_8/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';

class BuildAboutScreen extends StatefulWidget {
  const BuildAboutScreen({super.key});

  @override
  State<BuildAboutScreen> createState() => _BuildAboutScreenState();
}

class _BuildAboutScreenState extends State<BuildAboutScreen> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InfoCardExtended(
            icon: Icons.flag_outlined,
            title: 'Misión',
            content:
                'En un mundo donde las expresiones artísticas trascienden fronteras y conectan corazones, el Grupo de Danza "danzas la ladera 8" emerge como un faro de diversidad, creatividad y pasión. Fundado con el propósito de celebrar la riqueza cultural a través del movimiento, este conjunto de artistas fusiona elementos tradicionales y contemporáneos para tejer un tapiz vibrante de experiencias sensoriales.',
          ),
          SizedBox(height: 16),
          InfoCardExtended(
            icon: Icons.visibility_outlined,
            title: 'Visión',
            content:
                'Guiados por la visión de la unidad a través del arte, los bailarines de "danzas la ladera 8" personifican la belleza de la colaboración y la cooperación. Cada miembro aporta su propio bagaje cultural y experiencia única, creando un mosaico de estilos y perspectivas que enriquecen cada presentación.',
          ),
        ],
      ),
    );
  }
}
