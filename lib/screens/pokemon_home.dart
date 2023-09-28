import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/static_data.dart';
import 'package:pokedex/widgets/pokemon_grid.dart';

class PokemonHomeScreen extends StatefulWidget {
  const PokemonHomeScreen({super.key});

  @override
  State<PokemonHomeScreen> createState() => _PokemonHomeScreenState();
}

class _PokemonHomeScreenState extends State<PokemonHomeScreen> {
  var _isGettingPokemonCount = true;
  List<String> pokemonNames = [];
  List<String> pokemonIds = [];
  var _error = false;
  Sort _sortBy = Sort.idAscending;

  void fillPokemonNamesAndIds(List entries) {
    for (final entry in entries) {
      pokemonNames.add(entry['name']);
      String url = entry['url'];
      List<String> segments = url.split("/");
      pokemonIds.add(segments[segments.length - 2]);
    }
  }

  void _getPokemonNumber() async {
    try {
      final url = Uri.https('pokeapi.co', 'api/v2/pokemon-species', {
        'limit': '100000',
        'offset': '0',
        'queryParamWithQuestionMark': '?'
      });

      final response = await http.get(url);
      final decodedResponse = json.decode(response.body);
      fillPokemonNamesAndIds(decodedResponse['results']);
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
    final deviceWidth = MediaQuery.of(context).size.width;

    final TextEditingController _searchController = TextEditingController();

    if (_error) {
      content = const Text('pokemon_home error');
    } else if (_isGettingPokemonCount) {
      content = const CircularProgressIndicator();
    } else {
      content = PokemonGrid(pokemonNamesOrIds: pokemonIds);
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
                      return SizedBox(
                        height: MediaQuery.of(context).size.height,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Form(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: deviceWidth / 2 - 36,
                                      child: TextFormField(
                                        style: GoogleFonts.handlee(),
                                        keyboardType: TextInputType.name,
                                        controller: _searchController,
                                        decoration: InputDecoration(
                                          labelText: 'Search',
                                          hintText: 'hint',
                                          labelStyle: GoogleFonts.handlee(),
                                          hintStyle: GoogleFonts.handlee(),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          // call search function
                                        },
                                        icon: const Icon(Icons.search)),
                                    Container(
                                      margin: const EdgeInsets.only(left: 25),
                                      width: deviceWidth / 2 - 90,
                                      child: DropdownButtonFormField<Sort>(
                                        value: _sortBy,
                                        onChanged: (value) {
                                          setState(() {
                                            _sortBy = value!;
                                          });
                                        },
                                        items: Sort.values
                                            .map<DropdownMenuItem<Sort>>(
                                                (sortEnum) {
                                          return DropdownMenuItem(
                                            value: sortEnum,
                                            child: Text(
                                              sortEnum.value,
                                              style: GoogleFonts.handlee(),
                                            ),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          labelText: 'Sort by',
                                          labelStyle: GoogleFonts.handlee(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
