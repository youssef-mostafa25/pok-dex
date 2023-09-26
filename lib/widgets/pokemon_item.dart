import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/screens/pokemon.dart';

class PokemonItem extends StatefulWidget {
  const PokemonItem({
    super.key,
    required this.pokemonIndex,
    required this.isHero,
  });

  final int pokemonIndex;
  final bool isHero;

  @override
  State<PokemonItem> createState() => _PokemonItemState();
}

class _PokemonItemState extends State<PokemonItem> {
  Map? _pokemon;
  var _error = false;
  var _isGettingPokemon = true;

  void _getPokemon() async {
    try {
      final url =
          Uri.https('pokeapi.co', 'api/v2/pokemon/${widget.pokemonIndex}/');
      final response = await http.get(url);
      if (mounted) {
        setState(() {
          _isGettingPokemon = false;
          _pokemon = jsonDecode(response.body);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingPokemon = false;
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _getPokemon();
    Widget image = !_isGettingPokemon
        ? _pokemon!['sprites']['front_default'] == null
            ? Image.asset(
                'assets/images/poke_ball_icon.png',
              )
            : CachedNetworkImage(
                imageUrl: _pokemon!['sprites']['front_default'],
                placeholder: (context, url) => Image.asset(
                  'assets/images/poke_ball_icon.png',
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )
        : Image.asset('assets/images/poke_ball_icon.png');
    Widget text;
    if (_pokemon != null) {
      if (widget.isHero) {
        image = Hero(
          tag: _pokemon!['id'],
          child: SizedBox(
            width: 80,
            child: image,
          ),
        );
      }
      text = Text(
        _pokemon!['name'],
        style: GoogleFonts.handlee(),
      );
    } else {
      image = const CircularProgressIndicator();
      text = const Text('loading...');
    }

    if (_error) {
      text = const Text('something\nwent wrong');
    }
    return GestureDetector(
      onTap: () {
        if (_error || _pokemon == null) return;

        if (widget.isHero) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PokemonScreen(
                    pokemon: _pokemon!,
                    isVarient: false,
                  )));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => PokemonScreen(
                    pokemon: _pokemon!,
                    isVarient: false,
                  )));
        }
      },
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
