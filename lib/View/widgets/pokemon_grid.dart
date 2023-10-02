import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/View/widgets/pokemon_item.dart';

class PokemonGrid extends StatelessWidget {
  const PokemonGrid({
    super.key,
    required this.pokemonNamesOrIds,
  });

  final List<String> pokemonNamesOrIds;

  @override
  Widget build(BuildContext context) {
    return pokemonNamesOrIds.isEmpty
        ? SizedBox(
            width: double.infinity,
            child: Center(
              // todo center text
              child: Text(
                '\n\n\n\n\n\n\n\n\n\n\n\n\nNo results :(',
                style: GoogleFonts.handlee(),
              ),
            ),
          )
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
