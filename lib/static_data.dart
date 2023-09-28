import 'package:flutter/material.dart';

enum Sort {
  idAscending('id ascending'),
  idDescending('id dscending'),
  nameAscending('name ascending'),
  nameDescending('name dscending');

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
  'white': Colors.white,
  'pink': Colors.pink,
  'black': Colors.black,
};

// Map<String, Icon> typeMap = {
//   'normal': Icon(Icons.category),
//   'fighting': Icon(Icons.fitness_center),
//   'flying': Icon(Icons.airplanemode_active),
//   'poison': Icon(Icons.pets),
//   'ground': Icon(Icons.public),
//   'rock': Icon(Icons.terrain),
//   'bug': Icon(Icons.bug_report),
//   'ghost': Icon(Icons.gesture),
//   'steel': Icon(Icons.settings),
//   'fire': Icon(Icons.whatshot),
//   'water': Icon(Icons.invert_colors),
//   'grass': Icon(Icons.nature),
//   'electric': Icon(Icons.flash_on),
//   'psychic': Icon(Icons.spa),
//   'ice': Icon(Icons.ac_unit),
//   'dragon': Icon(Icons.dragon),
//   'dark': Icon(Icons.brightness_3),
//   'fairy': Icon(Icons.favorite),
// };
