import 'package:dance_club_comuna_8/logic/models/member.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_confetti/flutter_confetti.dart'; // Importa el paquete para el confetti
import 'package:audioplayers/audioplayers.dart';

class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  final List<Member> members = [];
  List<Member> birthdayMembers = [];
  List<Member> otherMembers = [];
  @override
  void initState() {
    super.initState();

    initializeDateFormatting('es', null);
    _filterBirthdayMembers();
  }

  void _filterBirthdayMembers() {
    DateTime today = DateTime.now();
    birthdayMembers = members
        .where((member) =>
            member.birthDate.day == today.day &&
            member.birthDate.month == today.month)
        .toList();

    otherMembers = members
        .where((member) =>
            member.birthDate.day != today.day ||
            member.birthDate.month != today.month)
        .toList();

    // Si hay miembros cumpleañeros, lanzar el confetti
    if (birthdayMembers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _launchConfetti();
      });
    }
  }

  void _launchConfetti() {
    // Reproducir el sonido de "pop" al lanzar el confetti
    final player = AudioPlayer();
    player.play(AssetSource(
        'sounds/congratulations.mp3')); // Asegúrate de tener este archivo en tu proyecto

    // Lanza el confetti
    Confetti.launch(
      context,
      options: const ConfettiOptions(
        particleCount: 100,
        spread: 70,
        y: 0.6,
        colors: [Colors.red, Colors.green, Colors.blue, Colors.purple],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (birthdayMembers.isNotEmpty) ...[
            _buildMulticolorTitle('Miembros cumpleañeros'),
            const SizedBox(height: 16.0),
            _buildMembersWrap(birthdayMembers),
            const SizedBox(height: 32.0),
          ],
          Text(
            'Miembros',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16.0),
          _buildMembersWrap(otherMembers),
        ],
      ),
    );
  }

  Widget _buildMulticolorTitle(String title) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
          tileMode: TileMode.mirror,
        ).createShader(bounds);
      },
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white, // Necesario para el ShaderMask
            ),
      ),
    );
  }

  Widget _buildMembersWrap(List<Member> members) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16.0,
      runSpacing: 16.0,
      children: members
          .map(
            (member) => MemberCard(
              member: member,
            ),
          )
          .toList(),
    );
  }
}

class MemberCard extends StatelessWidget {
  final Member member;

  const MemberCard({
    super.key,
    required this.member,
  });

  String formatDate(DateTime date) {
    return DateFormat("d 'de' MMMM", 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        width: 220, // Limitar el ancho de la tarjeta
        constraints: const BoxConstraints(
          maxHeight: 350, // Limitar el alto de la tarjeta
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(member.imageUrl),
              radius: 60.0, // Aumentado el tamaño del avatar
            ),
            const SizedBox(height: 16.0),
            Text(
              member.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Incremento del tamaño de texto
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            Text(
              member.role,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16, // Incremento del tamaño de texto
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cake,
                    size: 22,
                    color: Theme.of(context)
                        .colorScheme
                        .primary), // Icono más grande
                const SizedBox(width: 6.0),
                Text(
                  formatDate(member.birthDate),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16, // Incremento del tamaño de texto
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  member.about,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16, // Incremento del tamaño de texto
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 4, // Limitar el número de líneas visibles
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
