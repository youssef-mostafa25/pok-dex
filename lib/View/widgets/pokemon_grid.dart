import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/Model/pokemon_item_identifier.dart';
import 'package:pokedex/view/widgets/pokemon_item.dart';

class PokemonGrid extends StatelessWidget {
  const PokemonGrid({
    super.key,
    this.pokemonItemIdentifierList,
    this.pokemon,
  });

  final List<PokemonItemIdentifier>? pokemonItemIdentifierList;
  final List<Pokemon>? pokemon;

  @override
  Widget build(BuildContext context) {
    if (pokemonItemIdentifierList != null) {
      return pokemonItemIdentifierList!.isEmpty
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
                itemCount: pokemonItemIdentifierList!.length,
                itemBuilder: (context, index) {
                  return GridTile(
                      child: PokemonItem(
                    pokemonId: pokemonItemIdentifierList![index].number,
                    isHero: true,
                    isSamePokemon: false,
                  ));
                },
              ),
            );
    } else {
      return pokemon!.isEmpty
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
                itemCount: pokemon!.length,
                itemBuilder: (context, index) {
                  return GridTile(
                      child: PokemonItem(
                    isHero: true,
                    isSamePokemon: false,
                    pokemon: pokemon![index],
                  ));
                },
              ),
            );
    }
  }
}
