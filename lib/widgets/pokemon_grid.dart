import 'package:flutter/material.dart';
import 'package:pokedex/widgets/pokemon_item.dart';

class PokemonGrid extends StatelessWidget {
  const PokemonGrid({
    super.key,
    required this.pokemonCount,
  });

  final int pokemonCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        return GridTile(
            child: PokemonItem(
          pokemonIndex: index + 1,
          isHero: true,
          isVariety: false,
        ));
      },
    );
  }
}
