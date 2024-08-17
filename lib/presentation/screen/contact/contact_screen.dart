import 'package:dance_club_comuna_8/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BuildContactScreen extends StatefulWidget {
  const BuildContactScreen({super.key});

  @override
  State<BuildContactScreen> createState() => _BuildContactScreenState();
}

class _BuildContactScreenState extends State<BuildContactScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 952),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const MessageCard(),
              const SizedBox(height: 16),
              ContactCard(
                icon: Icons.email_outlined,
                title: 'Correo de Contacto',
                content: 'danzasladera.8@gmail.com',
                onTap: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: 'danzasladera.8@gmail.com',
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  } else {
                    throw 'Could not launch $emailUri';
                  }
                },
              ),
              const SizedBox(height: 16),
              const DeveloperCard(
                name: 'Juan Pablo Díaz Correa',
                title: 'Desarrollador Full-Stack',
                linkedinUrl: 'https://www.linkedin.com/in/juanipis/',
                githubUrl: 'https://github.com/Juanipis/dance_club_comuna_8',
                profileImage: 'assets/images/developer.webp',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
