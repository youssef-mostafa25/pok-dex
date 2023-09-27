import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/widgets/pokemon_grid.dart';

class PokemonHomeScreen extends StatefulWidget {
  const PokemonHomeScreen({super.key});

  @override
  State<PokemonHomeScreen> createState() => _PokemonHomeScreenState();
}

class _PokemonHomeScreenState extends State<PokemonHomeScreen> {
  var _isGettingPokemonCount = true;
  int? pokemonNumber;
  var _error = false;

  void _getPokemonNumber() async {
    try {
      final url = Uri.https('pokeapi.co', 'api/v2/pokemon-species/');
      final response = await http.get(url);
      pokemonNumber = json.decode(response.body)['count'];
      if (mounted) {
        setState(() {
          _isGettingPokemonCount = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _isGettingPokemonCount = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getPokemonNumber();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_error) {
      content = const Text('pokemon_home error');
    } else if (_isGettingPokemonCount) {
      content = const CircularProgressIndicator();
    } else {
      content = PokemonGrid(pokemonCount: pokemonNumber!);
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            'Pokédex',
            style: GoogleFonts.sedgwickAveDisplay(fontSize: 40),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Column(
                            children: [
                              TextFormField(
                                style: GoogleFonts.handlee(),
                                /*controller: ,*/
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  hintText: 'hint',
                                  labelStyle: GoogleFonts.handlee(),
                                  hintStyle: GoogleFonts.handlee(),
                                ),
                              ),
                              
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.menu,
                )),
          ],
        ),
        body: Center(child: content));
  }
}
