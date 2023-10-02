import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/View/screens/pokemon_screen.dart';

class PokemonItem extends StatelessWidget {
  const PokemonItem({
    super.key,
    required this.pokemon,
    required this.isHero,
    required this.isSamePokemon,
  });

  final Pokemon pokemon;
  final bool isHero;
  final bool isSamePokemon;

  @override
  Widget build(BuildContext context) {
    String imageUrl = '';
    imageUrl = pokemon.imageUrl;

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => Image.asset(
        'assets/images/poke_ball_icon.png',
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    Widget text;
    if (isHero) {
      image = Hero(
        tag: pokemon.number,
        child: SizedBox(
          width: 100,
          child: image,
        ),
      );
    }
    text = Text(
      pokemon.name,
      style: GoogleFonts.handlee(fontSize: 15),
    );
    return GestureDetector(
      onTap: !isSamePokemon
          ? () {
              if (isHero) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PokemonScreen(
                      pokemon: pokemon,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PokemonScreen(
                      pokemon: pokemon,
                    ),
                  ),
                );
              }
            }
          : null,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle, // Make it circular
        ), // Change color as needed
        margin: const EdgeInsets.all(8.0), // Adjust spacing between items
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image,
              text,
            ],
          ),
        ),
      ),
    );
  }
}
