import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DateTimeDisplay extends StatelessWidget {
  final bool isStart;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;

  const DateTimeDisplay({
    super.key,
    this.selectedDate,
    this.selectedTime,
    required this.isStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    initializeDateFormatting('es', null);

    // Formateo de fecha
    String formattedDate = selectedDate != null
        ? DateFormat('EEEE, d/MM', 'es').format(selectedDate!)
        : 'Fecha no seleccionada';

    // Formateo de hora
    String formattedTime = selectedTime != null
        ? selectedTime!.format(context)
        : 'Hora no seleccionada';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedTime != null)
          Text(
            formattedTime,
            style: theme.textTheme.displayMedium?.copyWith(
              color:
                  isStart ? theme.colorScheme.primary : theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        const SizedBox(height: 8),
        if (selectedDate != null)
          Text(
            formattedDate,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: textColor.withOpacity(0.6),
            ),
          ),
      ],
    );
  }
}
