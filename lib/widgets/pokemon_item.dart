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
    required this.isVariety,
    required this.isSamePokemon,
  });

  final int pokemonIndex;
  final bool isHero;
  final bool isVariety;
  final bool isSamePokemon;

  @override
  State<PokemonItem> createState() => _PokemonItemState();
}

class _PokemonItemState extends State<PokemonItem> {
  Map? _pokemon;
  var _errorPokemon = false;
  var _isGettingPokemon = true;
  Map? _pokemonSpecies;
  var _errorPokemonSpecies = false;
  var _isGettingPokemonSpecies = true;

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
          _errorPokemon = true;
        });
      }
    }
  }

  void _getPokemonSpecies() async {
    try {
      final url = Uri.https(
          'pokeapi.co', 'api/v2/pokemon-species/${widget.pokemonIndex}/');
      final response = await http.get(url);
      if (mounted) {
        setState(() {
          _isGettingPokemonSpecies = false;
          _pokemonSpecies = jsonDecode(response.body);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingPokemonSpecies = false;
          _errorPokemonSpecies = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getPokemon();
    _getPokemonSpecies();
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = '';

    if (!_isGettingPokemon) {
      if (_pokemon!['sprites']['other']['official-artwork']['front_default'] !=
          null) {
        imageUrl =
            _pokemon!['sprites']['other']['official-artwork']['front_default'];
      } else if (_pokemon!['sprites']['other']['dream_world']
              ['front_default'] !=
          null) {
        imageUrl =
            _pokemon!['sprites']['other']['dream_world']['front_default'];
      } else if (_pokemon!['sprites']['other']['home']['front_default'] !=
          null) {
        imageUrl = _pokemon!['sprites']['other']['home']['front_default'];
      } else if (_pokemon!['sprites']['front_default'] != null) {
        imageUrl = _pokemon!['sprites']['front_default'];
      }
    }

    Widget image = !_isGettingPokemon
        ? imageUrl.isEmpty
            ? Image.asset(
                'assets/images/poke_ball_icon.png',
              )
            : CachedNetworkImage(
                imageUrl: imageUrl,
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
            width: 100,
            child: image,
          ),
        );
      }
      text = Text(
        _pokemon!['name'],
        style: GoogleFonts.handlee(fontSize: 15),
      );
    } else {
      image = const CircularProgressIndicator();
      text = const Text('loading...');
    }

    if (_errorPokemon) {
      text = const Text('something\nwent wrong');
    }
    return GestureDetector(
      onTap: !widget.isSamePokemon
          ? () {
              if (_errorPokemon || _pokemon == null) return;

              if (widget.isHero) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PokemonScreen(
                          pokemon: _pokemon!,
                          isVariety: widget.isVariety,
                          pokemonSpecies:
                              !_isGettingPokemonSpecies && !_errorPokemonSpecies
                                  ? _pokemonSpecies
                                  : null,
                        )));
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => PokemonScreen(
                          pokemon: _pokemon!,
                          isVariety: widget.isVariety,
                          pokemonSpecies:
                              !_isGettingPokemonSpecies && !_errorPokemonSpecies
                                  ? _pokemonSpecies
                                  : null,
                        )));
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
