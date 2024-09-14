import 'package:flutter/material.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';

class CaptchaWidget extends StatefulWidget {
  final Function(String)
      onTokenGenerated; // Callback cuando el token es generado
  final Function(String) onError; // Callback para manejar errores
  const CaptchaWidget({
    super.key,
    required this.onTokenGenerated,
    required this.onError,
  });

  @override
  State<CaptchaWidget> createState() => _CaptchaWidgetState();
}

class _CaptchaWidgetState extends State<CaptchaWidget> {
  final String siteKey = const String.fromEnvironment('CAPTCHA_KEY',
      defaultValue: '3x00000000000000000000FF');
  final TurnstileController _controller = TurnstileController();
  final TurnstileOptions _options = TurnstileOptions(
    mode: TurnstileMode.managed,
    size: TurnstileSize.normal,
    theme: TurnstileTheme.light,
    refreshExpired: TurnstileRefreshExpired.manual,
    language: 'es',
    retryAutomatically: false,
  );

  String? _token;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _token != null
            ? const Text(
                'Captcha resuelto correctamente',
                style: TextStyle(color: Colors.green),
              )
            : const Text(
                'Por favor, resuelve el captcha para continuar',
                style: TextStyle(color: Colors.red),
              ),
        const SizedBox(height: 24.0),
        CloudFlareTurnstile(
          siteKey: siteKey, // Cambiar por tu siteKey real
          options: _options,
          controller: _controller,
          onTokenRecived: (token) {
            setState(() {
              _token = token;
            });
            widget.onTokenGenerated(
                token); // Notificar que se ha generado el token
          },
          onTokenExpired: () {
            setState(() {
              _token = null;
            });
          },
          onError: (error) {
            widget.onError(error);
          },
        ),
      ],
    );
  }
}
