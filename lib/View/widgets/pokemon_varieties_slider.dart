import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/View/widgets/pokemon_item.dart';

class PokemonVarietiesSliderRow extends StatelessWidget {
  const PokemonVarietiesSliderRow(
      {super.key, required this.pokemonIndecies, required this.originalColor});

  final List<int> pokemonIndecies;
  final Color originalColor;

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
                pokemonNameOrId: pokemonIndex.toString(),
                isHero: true,
                isVariety: true,
                isSamePokemon: false,
                originalColor: originalColor,
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
                      pokemonNameOrId: pokemonIndex.toString(),
                      isHero: true,
                      isVariety: true,
                      isSamePokemon: false,
                      originalColor: originalColor,
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
