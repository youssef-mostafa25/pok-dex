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
  var _isGettingPokemon = true;
  var _errorGettingPokemon = false;
  List<String> pokemonNames = [];
  List<String> pokemonIds = [];
  var _isFillingFilters = true;
  var _errorFillingFilters = false;
  String _searchValue = '';
  Sort _sortBy = Sort.idAscending;
  final List _colors = ['all'];
  String _color = 'all';
  final List _types = ['all'];
  String _type = 'all';
  final List _habitats = ['all'];
  String _habitat = 'all';
  final List _pokedexes = ['all'];
  String _pokedex = 'all';

  String _getPokemonNameByEntry(Map entry) {
    // ignore: prefer_if_null_operators
    return entry['name'] != null
        ? entry['name']
        : entry['pokemon'] != null
            ? entry['pokemon']['name']
            : entry['pokemon_species']['name'];
  }

  String _getPokemonUrlByEntry(Map entry) {
    // ignore: prefer_if_null_operators
    return entry['url'] != null
        ? entry['url']
        : entry['pokemon'] != null
            ? entry['pokemon']['url']
            : entry['pokemon_species']['url'];
  }

  void _fillPokemonNamesAndIds(List entries, List<String> pokemonNamesList,
      List<String> pokemonIdsList) {
    for (final entry in entries) {
      pokemonNamesList.add(_getPokemonNameByEntry(entry));
      String url = _getPokemonUrlByEntry(entry);
      List<String> segments = url.split("/");
      pokemonIdsList.add(segments[segments.length - 2]);
    }
  }

  List<Uri> get _filterUrls {
    final List<Uri> result = [];
    if (_color != 'all') {
      result.add(
        Uri.https('pokeapi.co', 'api/v2/pokemon-color/$_color'),
      );
    }
    if (_type != 'all') {
      result.add(
        Uri.https('pokeapi.co', 'api/v2/type/$_type'),
      );
    }
    if (_habitat != 'all') {
      result.add(
        Uri.https('pokeapi.co', 'api/v2/pokemon-habitat/$_habitat'),
      );
    }
    if (_pokedex != 'all') {
      result.add(
        Uri.https('pokeapi.co', 'api/v2/pokedex/$_pokedex'),
      );
    }
    return result;
  }

  void _andWithPokemonNamesAndIds(
      List<String> pokemonNamesTemp, List<String> pokemonIdsTemp) {
    List<String> pokemonNamesAfterAnding = [];
    List<String> pokemonIdsAfterAnding = [];
    for (final pokemonId in pokemonIds) {
      for (final pokemonIdTemp in pokemonIdsTemp) {
        if (pokemonId.compareTo(pokemonIdTemp) == 0) {
          pokemonNamesAfterAnding.add(pokemonIdTemp);
          pokemonIdsAfterAnding.add(pokemonId);
        }
      }
    }
    pokemonNames = pokemonNamesAfterAnding;
    pokemonIds = pokemonIdsAfterAnding;
  }

  void _filterBySearchValue() {
    for (int i = 0; i < pokemonNames.length; i++) {
      if (!pokemonNames[i].contains(_searchValue)) {
        // todo sort by id and search by value not working together
        pokemonNames.removeAt(i);
        pokemonIds.removeAt(i);
        i--;
      }
    }
  }

  void _applySort() {
    if (_sortBy == Sort.idAscending || _sortBy == Sort.idDescending) {
      if (_sortBy == Sort.idAscending) {
        pokemonIds.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
      } else {
        pokemonIds.sort((a, b) => int.parse(b).compareTo(int.parse(a)));
      }
    } else {
      if (_sortBy == Sort.nameAscending) {
        pokemonNames.sort((a, b) => a.compareTo(b));
      } else {
        pokemonNames.sort((a, b) => b.compareTo(a));
      }
    }
  }

  List _getResult(Map decodedResponse) {
    return decodedResponse['results'] ??
        decodedResponse['pokemon_species'] ??
        decodedResponse['pokemon'] ??
        decodedResponse['pokemon_entries'];
  }

  void _loadPokemon() async {
    setState(() {
      _isGettingPokemon = true;
    });
    pokemonIds = [];
    pokemonNames = [];
    try {
      final List<Uri> urls = _filterUrls;
      if (urls.isEmpty) {
        urls.add(
          Uri.https(
            'pokeapi.co',
            'api/v2/pokemon-species',
            {
              'limit': '100000',
              'offset': '0',
              'queryParamWithQuestionMark': '?',
            },
          ),
        );
      }
      var response = await http.get(urls[0]);
      var decodedResponse = json.decode(response.body);
      _fillPokemonNamesAndIds(
          _getResult(decodedResponse), pokemonNames, pokemonIds);
      for (int i = 1; i < urls.length; i++) {
        List<String> pokemonNamesTemp = [];
        List<String> pokemonIdsTemp = [];
        var response = await http.get(urls[i]);
        var decodedResponse = json.decode(response.body);
        _fillPokemonNamesAndIds(
            _getResult(decodedResponse), pokemonNamesTemp, pokemonIdsTemp);
        _andWithPokemonNamesAndIds(pokemonNamesTemp, pokemonIdsTemp);
      }
      if (_searchValue.isNotEmpty) _filterBySearchValue();
      _applySort();
      if (mounted) {
        setState(() {
          _isGettingPokemon = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorGettingPokemon = true;
          _isGettingPokemon = false;
        });
      }
    }
  }

  void _showModalBottomSheet() {
    var tempSearchValue = _searchValue;
    var tempSortBy = _sortBy;
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
                                Container(
                                  margin: const EdgeInsets.only(right: 25),
                                  width: deviceWidth / 2 - 25,
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
                                  width: deviceWidth / 2 - 25,
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
                                      _color = tempColor;
                                      _type = tempType;
                                      _habitat = tempHabitat;
                                      _pokedex = tempPokedex;
                                    });
                                    _loadPokemon();
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
      final colorUrl = Uri.https('pokeapi.co', 'api/v2/pokemon-color/');
      final typeUrl = Uri.https('pokeapi.co', 'api/v2/type/');
      final habitatUrl = Uri.https('pokeapi.co', 'api/v2/pokemon-habitat/');
      final pokedexUrl = Uri.https('pokeapi.co', 'api/v2/pokedex/');

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

  String get _queryResultText {
    String result = '\nShowing resluts for\n\n';
    if (_searchValue.isNotEmpty) {
      result += 'search value: \'$_searchValue\'';
    }
    if (_color != 'all' ||
        _type != 'all' ||
        _habitat != 'all' ||
        _pokedex != 'all') {
      if (_searchValue.isNotEmpty) result += '\n';
      if (_color != 'all') result += 'color: \'$_color\'\n';
      if (_type != 'all') result += 'type: \'$_type\'\n';
      if (_habitat != 'all') result += 'habitat: \'$_habitat\'\n';
      if (_pokedex != 'all') result += 'pokédex: \'$_pokedex\'\n';
    }
    return result.substring(0, result.length - 1);
  }

  @override
  void initState() {
    super.initState();
    _fillFilters();
    _loadPokemon();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_errorGettingPokemon) {
      content = const SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text(
            'pokemon_home error',
          ),
        ),
      );
    } else if (_isGettingPokemon) {
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
          if (_searchValue.isNotEmpty ||
              _color != 'all' ||
              _type != 'all' ||
              _habitat != 'all' ||
              _pokedex != 'all')
            Container(
                margin: const EdgeInsets.all(24),
                child: Text(
                  _queryResultText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.handlee(fontSize: 17),
                )),
          PokemonGrid(
            pokemonNamesOrIds:
                _sortBy == Sort.idAscending || _sortBy == Sort.idDescending
                    ? pokemonIds
                    : pokemonNames,
          ),
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
                Icons.filter_alt,
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
          child: content,
        ),
      ),
    );
  }
}
