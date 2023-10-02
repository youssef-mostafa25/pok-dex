import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/View/widgets/pokemon_item.dart';

class PokemonGrid extends StatelessWidget {
  const PokemonGrid({
    super.key,
    required this.pokemon,
  });

  final List<Pokemon> pokemon;

  @override
  Widget build(BuildContext context) {
    return pokemon.isEmpty
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
              itemCount: pokemon.length,
              itemBuilder: (context, index) {
                return GridTile(
                    child: PokemonItem(
                  pokemon: pokemon[index],
                  isHero: true,
                  isSamePokemon: false,
                ));
              },
            ),
          );
  }
}
