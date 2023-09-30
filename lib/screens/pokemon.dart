import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/static_data.dart';
import 'package:pokedex/widgets/pokemon_item.dart';
import 'package:pokedex/widgets/pokemon_table.dart';
import 'package:pokedex/widgets/pokemon_varieties_slider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({
    super.key,
    required this.pokemon,
    this.pokemonSpecies,
    required this.isVariety,
    this.originalColor,
  });

  final Map pokemon;
  final Map? pokemonSpecies;
  final bool isVariety;
  final Color? originalColor;

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  Widget? optionalEvoloutionChain;
  var _isGettingEvoChain = true;
  var _errorEvolution = false;
  Widget? randomText;
  List<int>? varieties;

  void _getEvoloution() async {
    try {
      final evoloutionUrl = widget.pokemonSpecies!['evolution_chain']['url'];
      List<String> segments = evoloutionUrl.split("/");
      String evoloutionIndex = segments[segments.length - 2];

      final url =
          Uri.https('pokeapi.co', 'api/v2/evolution-chain/$evoloutionIndex/');
      final response = await http.get(url);
      final result = jsonDecode(response.body)['chain'];

      List<List<Widget>> chains = [];
      for (int i = 0; i < result['evolves_to'].length; i++) {
        List<Widget> chain = [];
        var tempUrl = result['species']['url'];
        List<String> segments = tempUrl.split("/");
        int tempIndex = int.parse(segments[segments.length - 2]);
        chain.add(SizedBox(
          width: 100,
          child: PokemonItem(
            pokemonNameOrId: tempIndex.toString(),
            isHero: false,
            isVariety: widget.isVariety,
            isSamePokemon: widget.pokemon['id'] == tempIndex,
          ),
        ));
        chain.add(const Icon(Icons.arrow_right_alt_rounded));
        var tempResult = result['evolves_to'];
        while (tempResult.isNotEmpty) {
          tempUrl = tempResult[i]['species']['url'];
          segments = tempUrl.split("/");
          tempIndex = int.parse(segments[segments.length - 2]);
          chain.add(
            SizedBox(
              width: 100,
              child: PokemonItem(
                pokemonNameOrId: tempIndex.toString(),
                isHero: false,
                isVariety: widget.isVariety,
                isSamePokemon: widget.pokemon['id'] == tempIndex,
              ),
            ),
          );
          chain.add(const Icon(Icons.arrow_right_alt_rounded));
          tempResult = tempResult[i]['evolves_to'];
        }
        chain.removeLast();
        chains.add(chain);
      }

      optionalEvoloutionChain = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GradientText(
            chains.isEmpty
                ? 'No Evoloution Chain'
                : chains.length > 1
                    ? 'Evoloution Chains'
                    : 'Evoloution Chain',
            textAlign: TextAlign.center,
            style: GoogleFonts.sedgwickAveDisplay(
              fontSize: 30.0,
            ),
            colors: const [
              Color.fromRGBO(117, 117, 117, 1), // Darker gray
              Color.fromRGBO(158, 158, 158, 1), // Dark gray
              Color.fromRGBO(189, 189, 189, 1), // Slightly lighter gray
              Color.fromRGBO(189, 189, 189, 1), // Dark gray
              Color.fromRGBO(158, 158, 158, 1), // Darker gray
            ],
          ),
          for (final chain in chains)
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: chain,
              ),
            )
        ],
      );

      if (mounted) {
        setState(() {
          _isGettingEvoChain = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorEvolution = true;
          _isGettingEvoChain = false;
        });
      }
    }
  }

  Widget get _randomFlavourText {
    final List flavorTextEntries =
        widget.pokemonSpecies!['flavor_text_entries'];
    final int randomIndex = Random().nextInt(flavorTextEntries.length);
    Map randomMap = flavorTextEntries[randomIndex];
    String randomFlavorText = randomMap['flavor_text'].replaceAll('\n', ' ');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        randomFlavorText,
        textAlign: TextAlign.center,
        style: GoogleFonts.handlee(fontSize: 16),
      ),
    );
  }

  List<String> get _eggGroups {
    final List eggGroupList = widget.pokemonSpecies!['egg_groups'];
    List<String> result = [];
    result.add(eggGroupList.length > 1 ? 'Egg Groups' : 'Egg Group');
    if (eggGroupList.isEmpty) {
      result.add('Egg Group');
      result.add('no egg group');
    }
    var groups = '';
    for (final eggGroup in eggGroupList) {
      groups = '${groups + eggGroup['name']}, ';
    }
    groups = groups.substring(0, groups.length - 2);
    result.add(groups);
    return result;
  }

  List<int>? get _varietiesList {
    final List varietiesList = widget.pokemonSpecies!['varieties'];
    List<int> result = [];
    List segments;
    int index;
    for (final variety in varietiesList) {
      String url = variety['pokemon']['url'];
      segments = url.split("/");
      index = int.parse(segments[segments.length - 2]);
      if (variety['is_default'] == false) {
        result.add(index);
      }
    }
    return result.isNotEmpty ? result : null;
  }

  List<List<Map<String, bool>>>? get _abilities {
    final List abilities = widget.pokemon['abilities'];
    if (abilities.isEmpty) return null;
    List<List<Map<String, bool>>> result = [];
    result.add([
      {'Ability Name': true},
      {'Slot': true}
    ]);
    List<Map<String, bool>> list;

    for (final ability in abilities) {
      list = [];
      list.add({ability['ability']['name']: false});
      list.add({ability['slot'].toString(): false});
      result.add(list);
    }

    return result;
  }

  List<List<Map<String, bool>>>? get _moves {
    final List moves = widget.pokemon['moves'];
    if (moves.isEmpty) return null;
    List<List<Map<String, bool>>> result = [];
    result.add([
      {'Move Name': true},
      {'Move Learn Method': true},
      // {'Version Group': true},
      // {'Level Learned At': true}
    ]);
    List<Map<String, bool>> list;

    for (final move in moves) {
      list = [];
      list.add({move['move']['name']: false});
      list.add({
        move['version_group_details'][0]['move_learn_method']['name']: false
      });
      // list.add(
      //     {move['version_group_details'][i]['version_group']['name']: false});
      // list.add({
      //   move['version_group_details'][i]['level_learned_at'].toString(): false
      // });
      result.add(list);
    }

    return result;
  }

  List<List<Map<String, bool>>>? get _stats {
    final List stats = widget.pokemon['stats'];
    if (stats.isEmpty) return null;
    List<List<Map<String, bool>>> result = [];
    result.add([
      {'Stat Name': true},
      {'Base Stat': true},
      // {'Effort': true}
    ]);
    List<Map<String, bool>> list;

    for (final stat in stats) {
      list = [];
      list.add({stat['stat']['name']: false});
      list.add({stat['base_stat'].toString(): false});
      // list.add({stat['effort'].toString(): false});
      result.add(list);
    }

    return result;
  }

  String get _pokemonTypes {
    List types = widget.pokemon['types'];
    var typesResult = '';
    for (final type in types) {
      typesResult += ', ${type['type']['name']}';
    }
    typesResult = typesResult.substring(2);
    return typesResult;
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isVariety) {
      _getEvoloution();
    }
  }

  @override
  Widget build(BuildContext context) {
    final abilities = _abilities;
    final moves = _moves;
    final stats = _stats;
    if (!widget.isVariety) {
      varieties = _varietiesList;
      randomText = _randomFlavourText;
    }
    Widget evoloutionChain = GradientText(
      'No Evoloution Chain',
      textAlign: TextAlign.center,
      style: GoogleFonts.sedgwickAveDisplay(
        fontSize: 30.0,
      ),
      colors: const [
        Color.fromRGBO(117, 117, 117, 1), // Darker gray
        Color.fromRGBO(158, 158, 158, 1), // Dark gray
        Color.fromRGBO(189, 189, 189, 1), // Slightly lighter gray
        Color.fromRGBO(189, 189, 189, 1), // Dark gray
        Color.fromRGBO(158, 158, 158, 1), // Darker gray
      ],
    );
    if (!widget.isVariety) {
      if (_errorEvolution) {
        evoloutionChain = const Text('Something went wrong');
      } else {
        if (_isGettingEvoChain) {
          evoloutionChain = const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          evoloutionChain = optionalEvoloutionChain!;
        }
      }
    }
    String imageUrl = '';

    if (widget.pokemon['sprites']['other']['official-artwork']
            ['front_default'] !=
        null) {
      imageUrl = widget.pokemon['sprites']['other']['official-artwork']
          ['front_default'];
    } else if (widget.pokemon['sprites']['other']['dream_world']
            ['front_default'] !=
        null) {
      imageUrl =
          widget.pokemon['sprites']['other']['dream_world']['front_default'];
    } else if (widget.pokemon['sprites']['other']['home']['front_default'] !=
        null) {
      imageUrl = widget.pokemon['sprites']['other']['home']['front_default'];
    } else if (widget.pokemon['sprites']['front_default'] != null) {
      imageUrl = widget.pokemon['sprites']['front_default'];
    }

    Widget image = imageUrl.isEmpty
        ? Image.asset(
            'assets/images/poke_ball_icon.png',
          )
        : CachedNetworkImage(
            imageUrl: imageUrl,
            placeholder: (context, url) => Image.asset(
              'assets/images/poke_ball_icon.png',
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );

    final pokemonColor = widget.isVariety
        ? widget.originalColor!
        : colorMap[widget.pokemonSpecies!['color']['name']] ?? Colors.red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: pokemonColor,
        foregroundColor: Colors.white,
        title: Center(
          child: Text(
            widget.pokemon['name'],
            style: GoogleFonts.sedgwickAveDisplay(
                color: const Color.fromRGBO(255, 255, 255, 1), fontSize: 40),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                pokemonColor.withOpacity(0.05),
                pokemonColor.withOpacity(0.2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Hero(
                  tag: widget.pokemon['id'],
                  child: image,
                ),
                PokemonTable(entries: [
                  [
                    const {'ID': true},
                    {widget.pokemon['id'].toString(): false},
                  ],
                  if (_pokemonTypes.isNotEmpty)
                    [
                      {_pokemonTypes.length > 1 ? 'Types' : 'Type': true},
                      {_pokemonTypes: false},
                    ]
                ], pokemonColor: pokemonColor, tableName: 'Pokémon Details'),
                const SizedBox(height: 50),
                if (!widget.isVariety) randomText!,
                const SizedBox(height: 50),
                if (widget.pokemonSpecies != null)
                  PokemonTable(
                    entries: [
                      [
                        const {'Generation': true},
                        {
                          widget.pokemonSpecies!['generation'] != null
                              ? widget.pokemonSpecies!['generation']['name']
                              : 'null': false
                        }
                      ],
                      [
                        {_eggGroups[0]: true},
                        {_eggGroups[1]: false}
                      ],
                      [
                        const {'Growth Rate': true},
                        {
                          widget.pokemonSpecies!['growth_rate'] != null
                              ? widget.pokemonSpecies!['growth_rate']['name']
                              : 'null': false
                        }
                      ],
                      [
                        const {'Habitat': true},
                        {
                          widget.pokemonSpecies!['habitat'] != null
                              ? widget.pokemonSpecies!['habitat']['name']
                              : 'null': false
                        }
                      ],
                    ],
                    pokemonColor: pokemonColor,
                    tableName: 'Pokémon Info',
                  ),
                if (widget.pokemonSpecies != null) const SizedBox(height: 70),
                if (abilities != null)
                  PokemonTable(
                    entries: abilities,
                    pokemonColor: pokemonColor,
                    tableName: 'Abilities',
                  ),
                if (abilities != null) const SizedBox(height: 70),
                if (moves != null)
                  PokemonTable(
                    entries: moves,
                    pokemonColor: pokemonColor,
                    tableName: 'Moves',
                  ),
                if (moves != null) const SizedBox(height: 70),
                if (stats != null)
                  PokemonTable(
                    entries: stats,
                    pokemonColor: pokemonColor,
                    tableName: 'Stats',
                  ),
                if (stats != null) const SizedBox(height: 70),
                if (!widget.isVariety) evoloutionChain,
                if (!widget.isVariety) const SizedBox(height: 70),
                if (!widget.isVariety)
                  GradientText(
                    varieties != null ? 'Varities' : 'No Varities',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.sedgwickAveDisplay(
                      fontSize: 30.0,
                    ),
                    colors: const [
                      Color(0xFFff00ff),
                      Color(0xFF00ff00),
                      Color(0xFF0000ff),
                    ],
                  ),
                if (!widget.isVariety && varieties != null)
                  PokemonVarietiesSliderRow(
                      pokemonIndecies: varieties!, originalColor: pokemonColor),
                const SizedBox(height: 80)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
