import 'package:dance_club_comuna_8/logic/bloc/auth/auth_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _showPassword = false;
  void _togglevisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
            autofillHints: const [AutofillHints.email],
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: GestureDetector(
                    onTap: () => _togglevisibility,
                    child: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ))),
            obscureText: !_showPassword,
            autofillHints: const [AutofillHints.password],
          ),
          ElevatedButton(
            onPressed: () {
              BlocProvider.of<AuthBloc>(context).add(SignInRequested(
                  emailController.text, passwordController.text));
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
