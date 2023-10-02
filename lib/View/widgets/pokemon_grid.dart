import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/View/widgets/pokemon_item.dart';

class PokemonGrid extends StatelessWidget {
  const PokemonGrid({
    super.key,
    this.pokemonNamesAndNumbers,
    this.pokemon,
  });

  final List<int>? pokemonNamesAndNumbers;
  final List<Pokemon>? pokemon;

  @override
  Widget build(BuildContext context) {
    if (pokemonNamesAndNumbers != 0) {
      return pokemonNamesAndNumbers!.isEmpty
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
                itemCount: pokemonNamesAndNumbers!.length,
                itemBuilder: (context, index) {
                  return GridTile(
                      child: PokemonItem(
                    pokemonId: pokemonNamesAndNumbers![index],
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
