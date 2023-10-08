import 'package:flutter/material.dart';

enum Sort {
  idAscending('id ascending'),
  idDescending('id descending'),
  nameAscending('name ascending'),
  nameDescending('name descending');

  final String value;

  const Sort(this.value);
}

final Map<String, Color> colorMap = {
  'red': Colors.red,
  'blue': Colors.blue,
  'green': Colors.green,
  'yellow': Colors.yellow,
  'brown': Colors.brown,
  'purple': Colors.purple,
  'gray': Colors.grey,
  'white': Colors.red,
  'pink': Colors.pink,
  'black': Colors.black,
};
