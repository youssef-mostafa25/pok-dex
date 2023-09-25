import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/widgets/pokemon_variety_item.dart';

class PokemonVarietiesSlider extends StatelessWidget {
  const PokemonVarietiesSlider({super.key, required this.entries});

  final List<int> entries;

  @override
  Widget build(BuildContext context) {
    return entries.length > 2
        ? CarouselSlider(
            options: CarouselOptions(
              enlargeCenterPage: true,
              viewportFraction: 0.4,
            ),
            items: entries.map((entry) {
              return PokemonVarietyItem(entry: entry);
            }).toList(),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 50,
              ),
              for (final entry in entries)
                Row(
                  children: [
                    PokemonVarietyItem(entry: entry),
                    const SizedBox(
                      width: 50,
                    )
                  ],
                )
            ],
          );
  }
}
