import 'package:dance_club_comuna_8/logic/bloc/auth/auth_bloc.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_events.dart';
import 'package:dance_club_comuna_8/logic/bloc/auth/auth_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginWidget extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          // Usuario autenticado,  Mostrar información
          return Scaffold(
            appBar: AppBar(title: const Text("Login")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('You are already logged in!'),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<AuthBloc>(context)
                          .add(SignOutRequested());
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Usuario no autenticado, permitir login
          return buildUpdateEventForm(context);
        }
      },
    );
  }

  Widget buildUpdateEventForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Login Successful! Welcome ${state.user}'),
                  duration: const Duration(seconds: 2)),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Error: ${state.message}'),
                  duration: const Duration(seconds: 2)),
            );
          }
        },
        child: Column(
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
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
      ),
    );
  }
}
