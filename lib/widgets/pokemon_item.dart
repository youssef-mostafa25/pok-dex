import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/screens/pokemon.dart';

class PokemonItem extends StatefulWidget {
  const PokemonItem({
    super.key,
    required this.pokemonIndex,
    required this.fromPokemonHomeScreen,
  });

  final int pokemonIndex;
  final bool fromPokemonHomeScreen;

  @override
  State<PokemonItem> createState() => _PokemonItemState();
}

class _PokemonItemState extends State<PokemonItem> {
  Map? pokemon;
  var _error = false;

  void _getPokemon() async {
    try {
      final url =
          Uri.https('pokeapi.co', 'api/v2/pokemon/${widget.pokemonIndex}/');
      final response = await http.get(url);
      setState(() {
        pokemon = jsonDecode(response.body);
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _getPokemon();
    Widget image;
    Widget text;
    if (pokemon != null) {
      if (widget.fromPokemonHomeScreen) {
        image = Hero(
            tag: pokemon!['id'],
            child: Image.network(pokemon!['sprites']['front_default']));
      } else {
        image = Image.network(pokemon!['sprites']['front_default']);
      }
      text = Text(pokemon!['species']['name']);
    } else {
      image = const CircularProgressIndicator();
      text = const Text('loading...');
    }

    if (_error) {
      image = const Icon(Icons.question_mark);
      text = const Text('something went wrong');
    }
    return GestureDetector(
      onTap: () {
        if (_error || pokemon == null) return;
        if (!widget.fromPokemonHomeScreen) Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PokemonScreen(pokemon: pokemon!)),
        );
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
