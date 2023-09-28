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
  var _errorGettingPokemonCount = false;
  List<String> pokemonNames = [];
  List<String> pokemonIds = [];
  var _isFillingFilters = true;
  var _errorFillingFilters = false;
  String _searchValue = '';
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
          _errorGettingPokemonCount = true;
          _isGettingPokemonCount = false;
        });
      }
    }
  }

  void _showModalBottomSheet() {
    var tempSearchValue = _searchValue;
    var tempSortBy = _sortBy;
    var tempRegion = _region;
    var tempColor = _color;
    var tempType = _type;
    var tempHabitat = _habitat;
    var tempPokedex = _pokedex;
    final deviceWidth = MediaQuery.of(context).size.width;

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
          height: deviceWidth + MediaQuery.of(context).viewInsets.bottom,
          child: _isFillingFilters
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _errorFillingFilters
                  ? const Center(
                      child: Text('An error occured while filling filters!'),
                    )
                  : Padding(
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
                                    initialValue: _searchValue,
                                    decoration: InputDecoration(
                                      labelText: 'Search',
                                      hintText: 'pokemon name',
                                      labelStyle: GoogleFonts.handlee(),
                                      hintStyle: GoogleFonts.handlee(),
                                    ),
                                    onChanged: (value) {
                                      tempSearchValue = value;
                                    },
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
                                        tempSortBy = value!;
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
                                        tempRegion = value!;
                                      });
                                    },
                                    items: _regions
                                        .map<DropdownMenuItem<String>>((value) {
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
                                        tempColor = value!;
                                      });
                                    },
                                    items: _colors
                                        .map<DropdownMenuItem<String>>((value) {
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
                                        tempType = value!;
                                      });
                                    },
                                    items: _types
                                        .map<DropdownMenuItem<String>>((value) {
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
                                        tempHabitat = value!;
                                      });
                                    },
                                    items: _habitats
                                        .map<DropdownMenuItem<String>>((value) {
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
                                        tempPokedex = value!;
                                      });
                                    },
                                    items: _pokedexes
                                        .map<DropdownMenuItem<String>>((value) {
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
                                  onPressed: () {
                                    setState(() {
                                      _searchValue = tempSearchValue;
                                      _sortBy = tempSortBy;
                                      _region = tempRegion;
                                      _color = tempColor;
                                      _type = tempType;
                                      _habitat = tempHabitat;
                                      _pokedex = tempPokedex;
                                    });
                                    Navigator.pop(context);
                                  },
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
  }

  void _fillFilter(Uri url, List list) async {
    final response = await http.get(url);
    final decodedResponse = json.decode(response.body);
    final results = decodedResponse['results'];

    for (final result in results) {
      setState(() {
        list.add(result['name']);
      });
    }
  }

  void _fillFilters() {
    try {
      final regionUrl = Uri.https('pokeapi.co', 'api/v2/region/');
      final colorUrl = Uri.https('pokeapi.co', 'api/v2/pokemon-color/');
      final typeUrl = Uri.https('pokeapi.co', 'api/v2/type/');
      final habitatUrl = Uri.https('pokeapi.co', 'api/v2/pokemon-habitat/');
      final pokedexUrl = Uri.https('pokeapi.co', 'api/v2/pokedex/');

      _fillFilter(regionUrl, _regions);
      _fillFilter(colorUrl, _colors);
      _fillFilter(typeUrl, _types);
      _fillFilter(habitatUrl, _habitats);
      _fillFilter(pokedexUrl, _pokedexes);

      setState(() {
        _isFillingFilters = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFillingFilters = false;
          _errorFillingFilters = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fillFilters();
    _getPokemonNumber();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_errorGettingPokemonCount) {
      content = const SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text(
            'pokemon_home error',
          ),
        ),
      );
    } else if (_isGettingPokemonCount) {
      content = const SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: SizedBox(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else {
      content = Column(
        children: [
          if (_searchValue != '')
            Container(
                margin: const EdgeInsets.all(24),
                child: Text(
                  'Showing resluts for \'$_searchValue\'',
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
              onPressed: _showModalBottomSheet,
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
