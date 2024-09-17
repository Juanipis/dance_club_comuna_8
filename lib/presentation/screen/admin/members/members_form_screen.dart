import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/member/member_events.dart';
import 'package:dance_club_comuna_8/logic/models/member.dart';

class MemberFormScreen extends StatefulWidget {
  final Member? member; // Miembro opcional para editar

  const MemberFormScreen({super.key, this.member});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _role;
  late String _imageUrl;
  late DateTime _birthDate;
  late String _about;

  @override
  void initState() {
    super.initState();
    // Inicializar los valores del formulario si se está editando
    _name = widget.member?.name ?? '';
    _role = widget.member?.role ?? '';
    _imageUrl = widget.member?.imageUrl ?? '';
    _birthDate = widget.member?.birthDate ?? DateTime.now();
    _about = widget.member?.about ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.member == null ? 'Añadir Miembro' : 'Editar Miembro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (value) => _name = value,
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Rol'),
                onChanged: (value) => _role = value,
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                initialValue: _imageUrl,
                decoration:
                    const InputDecoration(labelText: 'URL de la Imagen'),
                onChanged: (value) => _imageUrl = value,
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              TextFormField(
                initialValue: _about,
                decoration: const InputDecoration(labelText: 'Acerca de'),
                onChanged: (value) => _about = value,
                validator: (value) =>
                    value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.member == null ? 'Añadir' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final member = Member(
        id: widget.member?.id,
        name: _name,
        role: _role,
        imageUrl: _imageUrl,
        birthDate: _birthDate,
        about: _about,
      );

      if (widget.member == null) {
        // Añadir nuevo miembro
        context.read<MemberBloc>().add(AddMemberEvent(
              name: _name,
              role: _role,
              imageUrl: _imageUrl,
              birthDate: _birthDate,
              about: _about,
            ));
      } else {
        // Actualizar miembro existente
        context.read<MemberBloc>().add(UpdateMemberEvent(
              id: widget.member!.id!,
              name: _name,
              role: _role,
              imageUrl: _imageUrl,
              birthDate: _birthDate,
              about: _about,
            ));
      }

      Navigator.of(context).pop();
    }
  }
}
