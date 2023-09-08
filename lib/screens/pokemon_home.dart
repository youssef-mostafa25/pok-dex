import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/widgets/pokemon_grid.dart';

class PokemonHomeScreen extends StatefulWidget {
  const PokemonHomeScreen({super.key});

  @override
  State<PokemonHomeScreen> createState() => _PokemonHomeScreenState();
}

class _PokemonHomeScreenState extends State<PokemonHomeScreen> {
  var _isGettingPokemon = true;
  List? pokedexes;
  // String? _pokedexName;
  // String? _pokedexNumber;
  var _error = false;

  void _getPokemon() async {
    try {
      final url = Uri.https('pokeapi.co', 'api/v2/pokedex/');
      final response = await http.get(url);
      pokedexes = json.decode(response.body)['results'];
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
  Widget build(BuildContext context) {
    _getPokemon();
    Widget content;

    if (_isGettingPokemon) {
      content = const CircularProgressIndicator();
    } else if (_error) {
      content = const Text('Something went terribly wrong');
    } else {
      content = Column(
        children: [
          for (final pokedex in pokedexes!)
            PokemonGrid(
                pokedexName: pokedex["name"]!,
                pokedexNumber: pokedex["url"]!
                    .split('/')[pokedex["url"]!.split('/').length - 2]),
        ],
      );
    }

    return SingleChildScrollView(child: Center(child: content));
  }
}
