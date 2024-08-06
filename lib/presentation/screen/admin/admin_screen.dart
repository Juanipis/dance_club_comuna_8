import 'package:dance_club_comuna_8/logic/bloc/auth/auth_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_states.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/blog_post_screen.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/add_event.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/events_viewer.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/login_form.dart';
import 'package:dance_club_comuna_8/presentation/screen/admin/upload_images_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Administración"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => BlocProvider.of<AuthBloc>(context)
                      .add(SignOutRequested()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return const AdminPanelContent();
          } else if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const LoginForm();
          }
        },
      ),
    );
  }
}

class AdminPanelContent extends StatelessWidget {
  const AdminPanelContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "¡Bienvenido al Panel de Administración!",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "¿Qué desea hacer hoy?",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              const SizedBox(height: 32),
              AdminOptionCard(
                title: "Crear evento",
                subtitle: "Agregar un nuevo evento al calendario",
                icon: Icons.event_available,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddEventScreen())),
              ),
              AdminOptionCard(
                title: "Editar eventos y asistentes",
                subtitle: "Gestionar eventos existentes y lista de asistentes",
                icon: Icons.edit_calendar,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EventsViewerScreen())),
              ),
              AdminOptionCard(
                title: "Subir imágenes",
                subtitle: "Añadir nuevas imágenes a la galería",
                icon: Icons.add_photo_alternate,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UploadImagesScreen())),
              ),
              AdminOptionCard(
                title: "Administrar blog",
                subtitle:
                    "Escribe, actualiza, borra posts para el blog de presentaciones",
                icon: Icons.add_comment,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BlogPostScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const AdminOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon,
                    size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
