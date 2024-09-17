import 'package:dance_club_comuna_8/logic/models/member.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
