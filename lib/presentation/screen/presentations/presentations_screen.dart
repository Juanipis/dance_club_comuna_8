import 'package:flutter/material.dart';

class BuildPresentationsScreen extends StatefulWidget {
  const BuildPresentationsScreen({super.key});

  @override
  State<BuildPresentationsScreen> createState() =>
      _BuildPresentationsScreenState();
}

class _BuildPresentationsScreenState extends State<BuildPresentationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text('Presentations Screen'),
    );
  }
}
