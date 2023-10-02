import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/API/poke_api.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/Model/static_data.dart';
import 'package:pokedex/View/widgets/pokemon_grid.dart';

class PokemonHomeScreen extends StatefulWidget {
  const PokemonHomeScreen({super.key});

  @override
  State<PokemonHomeScreen> createState() => _PokemonHomeScreenState();
}

class _PokemonHomeScreenState extends State<PokemonHomeScreen> {
  var _isGettingPokemon = true;
  var _errorGettingPokemon = false;
  List<Pokemon> pokemon = [];
  var _isFillingFilters = true;
  var _errorFillingFilters = false;
  String _searchValue = '';
  Sort _sortBy = Sort.idAscending;
  final List<String> _colors = ['all'];
  String _color = 'all';
  final List<String> _types = ['all'];
  String _type = 'all';
  final List<String> _habitats = ['all'];
  String _habitat = 'all';
  final List<String> _pokedexes = ['all'];
  String _pokedex = 'all';

  void _showModalBottomSheet() {
    var tempSearchValue = _searchValue;
    var tempSortBy = _sortBy;
    var tempColor = _color;
    var tempType = _type;
    var tempHabitat = _habitat;
    var tempPokedex = _pokedex;
    final deviceWidth = MediaQuery.of(context).size.width;
    final api = PokeAPI();

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
                                    try {
                                      setState(() {
                                        _isGettingPokemon = true;
                                      });
                                      api.loadPokemon();
                                      setState(() {
                                        _isGettingPokemon = false;
                                      });
                                    } catch (e) {
                                      _isGettingPokemon = false;
                                      _errorGettingPokemon = true;
                                    }
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
    final api = PokeAPI();
    try {
      setState(() {});
      api.fillFilters(_colors, _types, _habitats, _pokedexes);
      setState(() {
        _isFillingFilters = false;
      });
    } catch (e) {
      _isFillingFilters = false;
      _errorFillingFilters = true;
    }

    try {
      setState(() {
        _isGettingPokemon = true;
      });
      api.loadPokemon();
      setState(() {
        _isGettingPokemon = false;
      });
    } catch (e) {
      _isGettingPokemon = false;
      _errorGettingPokemon = true;
    }
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
            pokemon: pokemon,
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
