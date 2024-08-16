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
          InfoCard(
            icon: Icons.flag_outlined,
            title: 'Misión',
            content:
                'En un mundo donde las expresiones artísticas trascienden fronteras y conectan corazones, el Grupo de Danza "danzas la ladera 8" emerge como un faro de diversidad, creatividad y pasión. Fundado con el propósito de celebrar la riqueza cultural a través del movimiento, este conjunto de artistas fusiona elementos tradicionales y contemporáneos para tejer un tapiz vibrante de experiencias sensoriales.',
          ),
          SizedBox(height: 16),
          InfoCard(
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

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
