import 'dart:io';

import 'package:flutter/widgets.dart';

class PokemonGridItem extends StatelessWidget {
  PokemonGridItem({super.key, required this.name, required this.image});

  String name;
  File image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(name),
      ],
    );
  }
}
