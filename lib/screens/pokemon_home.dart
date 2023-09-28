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
  final TextEditingController _searchController = TextEditingController();
  Sort _sortBy = Sort.idAscending;
  List _regions = ['all'];
  String _region = 'all';
  List _colors = ['all'];
  String _color = 'all';
  List _types = ['all'];
  String _type = 'all';
  List _habitats = ['all'];
  String _habitat = 'all';
  List _pokedexes = ['all'];
  String _pokedex = 'all';

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

  void _fillFilters() async {}

  @override
  void initState() {
    super.initState();
    _getPokemonNumber();
    _fillFilters();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    var sortBy = _sortBy;
    var region = _region;
    var color = _color;
    var type = _type;
    var habitat = _habitat;
    var pokedex = _pokedex;
    final deviceWidth = MediaQuery.of(context).size.width;

    if (_error) {
      content = const Text('pokemon_home error');
    } else if (_isGettingPokemonCount) {
      content = const CircularProgressIndicator();
    } else {
      content = Column(
        children: [
          if (_searchController.text != '')
            Container(
                margin: const EdgeInsets.all(24),
                child: Text(
                  'Showing resluts for \'${_searchController.text}\'',
                  style: GoogleFonts.handlee(fontSize: 17),
                )),
          PokemonGrid(pokemonNamesOrIds: pokemonIds),
        ],
      );
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
                  useSafeArea: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.withOpacity(0.05),
                            Colors.red.withOpacity(0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      height: deviceWidth +
                          MediaQuery.of(context).viewInsets.bottom,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Form(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: deviceWidth / 2 - 20,
                                    child: TextFormField(
                                      style: GoogleFonts.handlee(),
                                      keyboardType: TextInputType.name,
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        labelText: 'Search',
                                        hintText: 'pokemon name',
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
                                    width: deviceWidth / 2 - 77,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: deviceWidth / 3 - 21,
                                    child: DropdownButtonFormField<String>(
                                      value: _region,
                                      onChanged: (value) {
                                        setState(() {
                                          _region = value!;
                                        });
                                      },
                                      items: _regions
                                          .map<DropdownMenuItem<String>>(
                                              (value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.handlee(),
                                          ),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'Region',
                                        labelStyle: GoogleFonts.handlee(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 19),
                                    width: deviceWidth / 3 - 21,
                                    child: DropdownButtonFormField<String>(
                                      value: _color,
                                      onChanged: (value) {
                                        setState(() {
                                          _color = value!;
                                        });
                                      },
                                      items: _colors
                                          .map<DropdownMenuItem<String>>(
                                              (value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.handlee(),
                                          ),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'Color',
                                        labelStyle: GoogleFonts.handlee(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: deviceWidth / 3 - 21,
                                    child: DropdownButtonFormField<String>(
                                      value: _type,
                                      onChanged: (value) {
                                        setState(() {
                                          _type = value!;
                                        });
                                      },
                                      items: _types
                                          .map<DropdownMenuItem<String>>(
                                              (value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.handlee(),
                                          ),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'Type',
                                        labelStyle: GoogleFonts.handlee(),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: deviceWidth / 2 - 25,
                                    child: DropdownButtonFormField<String>(
                                      value: _habitat,
                                      onChanged: (value) {
                                        setState(() {
                                          _habitat = value!;
                                        });
                                      },
                                      items: _habitats
                                          .map<DropdownMenuItem<String>>(
                                              (value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.handlee(),
                                          ),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'Habitat',
                                        labelStyle: GoogleFonts.handlee(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 25),
                                    width: deviceWidth / 2 - 25,
                                    child: DropdownButtonFormField<String>(
                                      value: _pokedex,
                                      onChanged: (value) {
                                        setState(() {
                                          _pokedex = value!;
                                        });
                                      },
                                      items: _pokedexes
                                          .map<DropdownMenuItem<String>>(
                                              (value) {
                                        return DropdownMenuItem(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: GoogleFonts.handlee(),
                                          ),
                                        );
                                      }).toList(),
                                      decoration: InputDecoration(
                                        labelText: 'Pokedex',
                                        labelStyle: GoogleFonts.handlee(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: Text(
                                      'apply',
                                      style: GoogleFonts.handlee(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      _sortBy = sortBy;
                                      _region = region;
                                      _color = color;
                                      _type = type;
                                      _habitat = habitat;
                                      _pokedex = pokedex;
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'cancel',
                                      style: GoogleFonts.handlee(
                                          color: Colors.red, fontSize: 16),
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
      body: Center(
        child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.05),
                  Colors.red.withOpacity(0.15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: content),
      ),
    );
  }
}
