import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Container(
      width: 300,
      height: 400,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Theme.of(context).primaryColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 50,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCardExtended extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const InfoCardExtended({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 952,
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Theme.of(context).primaryColor, // Color de fondo ajustado
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
                          color: Colors.white, // Color del ícono ajustado
                        ),
                        const SizedBox(width: 16),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Color del título ajustado
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white, // Color del contenido ajustado
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class DeveloperCard extends StatelessWidget {
  final String name;
  final String title;
  final String linkedinUrl;
  final String githubUrl;
  final String profileImage; // Ruta del asset de la imagen de perfil

  const DeveloperCard({
    super.key,
    required this.name,
    required this.title,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.profileImage, // Recibir la imagen de perfil
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, // Usar color principal
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 5.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Desarrollador',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Color blanco para el título
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40, // Tamaño del avatar
                backgroundImage:
                    AssetImage(profileImage), // Usar la imagen del perfil
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Color blanco para el nombre
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors
                            .white70, // Color blanco más claro para el título
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              IconButton(
                icon: const Icon(Ionicons.logo_linkedin),
                color: Colors.white,
                iconSize: 40,
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(linkedinUrl))) {
                    await launchUrl(Uri.parse(linkedinUrl));
                  } else {
                    throw 'Could not launch $linkedinUrl';
                  }
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Ionicons.logo_github),
                color: Colors.white,
                iconSize: 40,
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(githubUrl))) {
                    await launchUrl(Uri.parse(githubUrl));
                  } else {
                    throw 'Could not launch $githubUrl';
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Si encuentras un bug o quieres ayudar a mejorar la app, por favor envía un pull request al repositorio en GitHub.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70, // Texto en blanco claro
            ),
          ),
        ],
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final VoidCallback onTap;

  const ContactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor, // Usar color principal
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 5.0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white, // Color blanco para el ícono
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Color blanco para el texto
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white, // Color blanco para el contenido
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  const MessageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.message_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '¡Nos encantaría saber de ti! Si tienes alguna pregunta, sugerencia o simplemente quieres unirte a nuestras actividades, no dudes en enviarnos un correo electrónico. Estamos aquí para ayudarte y nos encantaría conocerte.',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
