import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PokemonGrid extends StatefulWidget {
  PokemonGrid({
    super.key,
    required this.pokemonNumber,
  });

  int pokemonNumber;

  @override
  State<PokemonGrid> createState() => _PokemonGridState();
}

class _PokemonGridState extends State<PokemonGrid> {
  bool _isGettingPokemon = false;
  bool _error = false;
  Map? currentPokemon;

  void _getPokemon(int pokemonIndex) async {
    try {
      _isGettingPokemon = true;
      final url = Uri.https('pokeapi.co', 'api/v2/pokemon/$pokemonIndex/');
      final response = await http.get(url);
      currentPokemon = jsonDecode(response.body);
      setState(() {
        _isGettingPokemon = false;
      });
    } catch (e) {
      setState(() {
        _error = true;
        _isGettingPokemon = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getPokemon(1);
    print('once only?????');
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (!_isGettingPokemon) {
      if (!_error) {
        // content = Expanded(
        //   child: ListView.builder(
        //     itemCount: 10, // Number of items in the grid
        //     itemBuilder: (BuildContext context, int index) {
        //       // Replace this with your own widget for each grid item
        //       return Container(
        //         color: Colors.blue,
        //         alignment: Alignment.center,
        //         child: Text('Item $index'),
        //       );
        //     },
        //   ),
        // );
        content = Text(currentPokemon!['species']['name']);
      } else {
        content = const Text('pokemon_grid error');
      }
    } else {
      content = const Center(child: CircularProgressIndicator());
    }

    return content;
  }
}
