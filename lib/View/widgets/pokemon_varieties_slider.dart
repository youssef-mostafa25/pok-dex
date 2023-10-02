import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/View/widgets/pokemon_item.dart';

class PokemonVarietiesSliderRow extends StatelessWidget {
  const PokemonVarietiesSliderRow({super.key, required this.pokemon});

  final List<Pokemon> pokemon;

  @override
  Widget build(BuildContext context) {
    return pokemon.length > 2
        ? CarouselSlider(
            options: CarouselOptions(
              enlargeCenterPage: true,
              viewportFraction: 0.4,
            ),
            items: pokemon.map((currPokemon) {
              return PokemonItem(
                isHero: true,
                isSamePokemon: false,
                pokemon: currPokemon,
              );
            }).toList(),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 50,
              ),
              for (final currPokemon in pokemon)
                Row(
                  children: [
                    PokemonItem(
                      isHero: true,
                      isSamePokemon: false,
                      pokemon: currPokemon,
                    ),
                    const SizedBox(
                      width: 50,
                    )
                  ],
                )
            ],
          );
  }
}
