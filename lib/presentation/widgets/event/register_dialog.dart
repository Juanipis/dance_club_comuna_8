import 'package:dance_club_comuna_8/logic/bloc/event/event_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_register_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/event/event_states.dart';
import 'package:dance_club_comuna_8/presentation/widgets/captcha.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

class RegisterDialog extends StatefulWidget {
  final String title;
  final String eventId;

  const RegisterDialog({super.key, required this.title, required this.eventId});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController name = TextEditingController();
  bool isLoading = false;
  bool isPolicyAccepted = false;
  bool isCaptchaValid = false; // Nueva variable para el estado del CAPTCHA
  String? error;
  Logger logger = Logger();
  String? captchaToken; // Token del captcha

  bool isValidPhoneNumber(String number) {
    RegExp regex = RegExp(r'^(\+?\d{1,3}?)?[1-9][0-9]{7,14}$');
    return regex.hasMatch(number);
  }

  void showPolicyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Política de Tratamiento de Datos'),
        content: const SingleChildScrollView(
          child: Text('### Política de Tratamiento de Datos Personales\n\n'
              '**El club de danzas la ladera** se compromete a garantizar la protección de la privacidad de los datos personales de nuestros usuarios. Esta política detalla los procedimientos y principios que aplicamos en el manejo de dichos datos.\n\n'
              '#### 1. Información que recopilamos\n\n'
              'Para el registro y participación en eventos, recopilamos los siguientes datos personales:\n\n'
              '- Nombre completo\n'
              '- Número de teléfono\n\n'
              '#### 2. Uso de la información\n\n'
              'Los datos recopilados se utilizan exclusivamente para los siguientes fines:\n\n'
              '- Registrar y confirmar su participación en los eventos.\n'
              '- Facilitar la organización y logística de los eventos, incluyendo la llamada a lista para verificar asistencia.\n'
              '- Comunicaciones relacionadas con el evento para el cual se ha registrado.\n\n'
              '#### 3. Protección de datos\n\n'
              'Nos comprometemos a proteger sus datos personales mediante la implementación de medidas técnicas y organizativas adecuadas para prevenir la pérdida, mal uso, alteración, acceso no autorizado y robo de los datos suministrados. Solo el personal autorizado tendrá acceso a sus datos personales, y no se compartirán con terceros sin su consentimiento expreso, salvo por obligación legal.\n\n'
              '#### 4. Derechos del titular de los datos\n\n'
              'De acuerdo con la normativa vigente en Colombia sobre protección de datos personales, usted tiene derecho a:\n\n'
              '- Conocer, actualizar y rectificar sus datos personales frente a Club de danzas comuna 8.\n'
              '- Solicitar prueba de la autorización otorgada.\n'
              '- Ser informado respecto al uso que se ha dado a sus datos personales.\n'
              '- Presentar quejas ante la Superintendencia de Industria y Comercio por infracciones a lo dispuesto en la normativa vigente.\n'
              '- Revocar la autorización y/o solicitar la supresión del dato cuando en el tratamiento no se respeten los principios, derechos y garantías constitucionales y legales.\n'
              '- Acceder en forma gratuita a sus datos personales que hayan sido objeto del tratamiento.\n\n'
              '#### 5. Vigencia\n\n'
              'La presente política de tratamiento de datos personales está vigente desde 8/4/204 y permanecerá efectiva hasta que se realice una actualización que será comunicada a los usuarios.\n\n'
              'Para más información, preguntas o preocupaciones acerca de nuestras políticas de privacidad, por favor, póngase en contacto con nosotros a través de danzasladera.8@gmail.com.'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventRegisterBloc, EventState>(
      listener: (context, state) {
        if (state is UserRegisteredState) {
          Navigator.pop(context); // Close the dialog
          _showSnackBar('Registrado correctamente', true);
          Navigator.pop(context); // Close the expanded event
        } else if (state is EventErrorState) {
          _showSnackBar(
              'No se logró realizar el registro. ${state.message}', false);
          setState(() {
            isLoading = false;
            error = state.message;
          });
        }
      },
      child: AlertDialog(
        title: Text("Te estás registrando en ${widget.title}"),
        content: isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: name,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: phoneNumber,
                      decoration: const InputDecoration(
                          labelText: 'Número de teléfono'),
                    ),
                    if (error != null)
                      Text(error!, style: const TextStyle(color: Colors.red)),
                    Row(
                      children: [
                        Checkbox(
                          value: isPolicyAccepted,
                          onChanged: (bool? value) {
                            setState(() {
                              isPolicyAccepted = value ?? false;
                            });
                          },
                        ),
                        const Expanded(
                          child: Text(
                              'Acepto la política de tratamiento de datos'),
                        ),
                        GestureDetector(
                          onTap: showPolicyDialog,
                          child: const Text(
                            'Saber más',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    CaptchaWidget(
                      onTokenGenerated: (token) {
                        setState(() {
                          isCaptchaValid = true;
                          captchaToken = token;
                        });
                      },
                      onError: (error) {
                        _showSnackBar('Error del CAPTCHA: $error', false);
                      },
                    ),
                  ],
                ),
              ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: isCaptchaValid &&
                    isValidPhoneNumber(phoneNumber.text) &&
                    isPolicyAccepted
                ? () {
                    setState(() {
                      isLoading = true;
                    });
                    logger.d(
                        'Registrando usuario, evento: ${widget.eventId}, teléfono: ${phoneNumber.text}, nombre: ${name.text}');
                    BlocProvider.of<EventRegisterBloc>(context).add(
                      RegisterUserEvent(
                        eventId: widget.eventId,
                        phoneNumber: phoneNumber.text,
                        name: name.text,
                      ),
                    );
                  }
                : null, // Deshabilitado hasta que se resuelva el captcha
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
