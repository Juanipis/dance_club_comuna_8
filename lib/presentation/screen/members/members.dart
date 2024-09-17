import 'package:dance_club_comuna_8/logic/bloc/member/member_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_states.dart';
import 'package:dance_club_comuna_8/logic/models/member.dart';
import 'package:dance_club_comuna_8/presentation/widgets/member_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_confetti/flutter_confetti.dart'; // Importa el paquete para el confetti
import 'package:audioplayers/audioplayers.dart';

class Members extends StatefulWidget {
  const Members({super.key});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  List<Member> birthdayMembers = [];
  List<Member> otherMembers = [];

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('es', null);

    // Cargar los miembros cuando el widget se inicialice
    context.read<MemberBloc>().add(const LoadMembersEvent());
  }

  void _filterBirthdayMembers(List<Member> members) {
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
    return BlocBuilder<MemberBloc, MemberState>(
      builder: (context, state) {
        if (state is MemberLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MemberLoadedState) {
          _filterBirthdayMembers(
              state.members); // Filtrar miembros por cumpleaños
          return _buildMembersContent();
        } else if (state is MemberErrorState) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(child: Text('No hay miembros disponibles.'));
        }
      },
    );
  }

  Widget _buildMembersContent() {
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
