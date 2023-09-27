import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/widgets/pokemon_item.dart';

class PokemonVarietiesSliderRow extends StatelessWidget {
  const PokemonVarietiesSliderRow({super.key, required this.pokemonIndecies});

  final List<int> pokemonIndecies;

  @override
  Widget build(BuildContext context) {
    return pokemonIndecies.length > 2
        ? CarouselSlider(
            options: CarouselOptions(
              enlargeCenterPage: true,
              viewportFraction: 0.4,
            ),
            items: pokemonIndecies.map((pokemonIndex) {
              return PokemonItem(
                pokemonIndex: pokemonIndex,
                isHero: true,
                isVariety: true,
                isSamePokemon: true,
              );
            }).toList(),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 50,
              ),
              for (final pokemonIndex in pokemonIndecies)
                Row(
                  children: [
                    PokemonItem(
                      pokemonIndex: pokemonIndex,
                      isHero: true,
                      isVariety: true,
                      isSamePokemon: false,
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
