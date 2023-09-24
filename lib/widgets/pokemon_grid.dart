import 'package:flutter/material.dart';
import 'package:pokedex/widgets/pokemon_grid_item.dart';

class PokemonGrid extends StatelessWidget {
  PokemonGrid({
    super.key,
    required this.pokemonNumber,
  });

  int pokemonNumber;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns in the grid
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              // Build each grid item using a container with a colored box
              return PokemonGridItem(
                pokemonIndex: index + 1,
              );
            },
            childCount: pokemonNumber, // Total number of items in the grid
          ),
        ),
      ],
    );
  }
}
