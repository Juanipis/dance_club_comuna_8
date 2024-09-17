import 'package:dance_club_comuna_8/presentation/screen/admin/members/members_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_states.dart';
import 'package:dance_club_comuna_8/logic/models/member.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los miembros cuando el widget se inicializa
    context.read<MemberBloc>().add(const LoadMembersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Miembros"),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: BlocBuilder<MemberBloc, MemberState>(
        builder: (context, state) {
          if (state is MemberLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MemberLoadedState) {
            return _buildMemberList(state.members);
          } else if (state is MemberErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No hay miembros disponibles.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddEditMemberScreen(
              context); // Navegar al formulario para añadir un miembro
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMemberList(List<Member> members) {
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(member.imageUrl),
          ),
          title: Text(member.name),
          subtitle: Text(member.role),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _navigateToAddEditMemberScreen(context,
                    member: member), // Editar miembro
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () =>
                    _confirmDeleteMember(context, member), // Eliminar miembro
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddEditMemberScreen(BuildContext context, {Member? member}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberFormScreen(member: member),
      ),
    );
  }

  void _confirmDeleteMember(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este miembro?'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<MemberBloc>().add(DeleteMemberEvent(id: member.id!));
              Navigator.of(ctx).pop();
            },
            child: const Text('Sí'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
        ],
      ),
    );
  }
}
