import 'package:flutter/material.dart';
import 'package:pokedex/widgets/pokemon_item.dart';

class PokemonGrid extends StatelessWidget {
  const PokemonGrid({
    super.key,
    required this.pokemonNamesOrIds,
  });

  final List<String> pokemonNamesOrIds;

  @override
  Widget build(BuildContext context) {
    return pokemonNamesOrIds.isEmpty
        ? const SizedBox(
            width: double.infinity,
            child: Center(heightFactor: 35, child: Text('No results')))
        : Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemCount: pokemonNamesOrIds.length,
              itemBuilder: (context, index) {
                return GridTile(
                    child: PokemonItem(
                  pokemonNameOrId: pokemonNamesOrIds[index],
                  isHero: true,
                  isVariety: false,
                  isSamePokemon: false,
                ));
              },
            ),
          );
  }
}
