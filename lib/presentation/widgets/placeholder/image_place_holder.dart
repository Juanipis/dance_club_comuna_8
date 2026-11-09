import 'package:flutter/material.dart';

var expandedEventPlaceHolderImageSrc = 'assets/images/placeholder.webp';

Widget expandedEventPlaceHolderImage() {
  return Image.asset(
    expandedEventPlaceHolderImageSrc,
    fit: BoxFit.cover,
    width: double.infinity,
    height: 200,
  );
}

Widget eventCardPlaceHolderImage() {
  return Image.asset(
    expandedEventPlaceHolderImageSrc,
    fit: BoxFit.cover,
    width: 300,
    height: 200,
  );
}
