import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/API/poke_api.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/view/screens/pokemon_screen.dart';

class PokemonItem extends StatefulWidget {
  const PokemonItem({
    super.key,
    this.pokemonId,
    required this.isHero,
    required this.isSamePokemon,
    this.pokemon,
  });

  final int? pokemonId;
  final bool isHero;
  final bool isSamePokemon;
  final Pokemon? pokemon;

  @override
  State<PokemonItem> createState() => _PokemonItemState();
}

class _PokemonItemState extends State<PokemonItem> {
  Pokemon? pokemon;
  var _isGettingPokemon = true;
  var _errorGettingPokemon = false;
  final api = PokeAPI();

  void getPokemon() async {
    try {
      pokemon =
          await api.getPokemon(widget.pokemonId.toString(), true, false, null);
      if (mounted) {
        setState(() {
          _isGettingPokemon = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingPokemon = false;
          _errorGettingPokemon = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.pokemon == null) {
      getPokemon();
    } else {
      pokemon = widget.pokemon;
      if (mounted) {
        setState(() {
          _isGettingPokemon = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGettingPokemon) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorGettingPokemon) {
      return const Column(
        children: [Icon(Icons.error), Text('Something\nwent wrong')],
      );
    }

    String imageUrl = '';
    imageUrl = pokemon!.imageUrl;

    Widget image = imageUrl.isEmpty
        ? Image.asset('assets/images/poke_ball_icon.png')
        : CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => Image.asset(
              'assets/images/poke_ball_icon.png',
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );

    Widget text;
    if (widget.isHero) {
      image = Hero(
        tag: pokemon!.number,
        child: SizedBox(
          width: 100,
          child: image,
        ),
      );
    }
    text = Text(
      pokemon!.name,
      style: GoogleFonts.handlee(fontSize: 15),
    );
    return GestureDetector(
      onTap: !widget.isSamePokemon
          ? () {
              if (widget.isHero) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PokemonScreen(
                      pokemon: pokemon!,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => PokemonScreen(
                      pokemon: pokemon!,
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
