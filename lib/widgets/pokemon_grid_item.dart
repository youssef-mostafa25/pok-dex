import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/screens/pokemon.dart';

class PokemonGridItem extends StatefulWidget {
  PokemonGridItem({super.key, required this.pokemonIndex});

  int pokemonIndex;

  @override
  State<PokemonGridItem> createState() => _PokemonGridItemState();
}

class _PokemonGridItemState extends State<PokemonGridItem> {
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
    Widget image = pokemon != null
        ? Image.network(pokemon!['sprites']['front_default'])
        : const CircularProgressIndicator();
    Widget text =
        Text(pokemon != null ? pokemon!['species']['name'] : 'loading...');

    if (_error) {
      image = const Icon(Icons.question_mark);
      text = const Text('!!!!!!!');
    }
    return GestureDetector(
      onTap: () {
        if (_error || pokemon == null) return;
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
