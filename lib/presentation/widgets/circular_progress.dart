import 'package:flutter/material.dart';

Widget circularProgressIndicator() {
  return const Column(
    children: [
      SizedBox(
        height: 20,
      ),
      Center(
        child: CircularProgressIndicator(),
      ),
    ],
  );
}
