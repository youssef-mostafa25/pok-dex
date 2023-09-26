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
  const PokemonScreen(
      {super.key,
      required this.pokemon,
      this.pokemonSpecies,
      required this.isVariety});

  final Map pokemon;
  final Map? pokemonSpecies;
  final bool isVariety;

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
        chain.add(PokemonItem(
          pokemonIndex: tempIndex,
          isHero: false,
          isVariety: widget.isVariety,
        ));
        chain.add(const Icon(Icons.arrow_right_alt_rounded));
        var tempResult = result['evolves_to'];
        while (tempResult.isNotEmpty) {
          tempUrl = tempResult[i]['species']['url'];
          segments = tempUrl.split("/");
          tempIndex = int.parse(segments[segments.length - 2]);
          chain.add(PokemonItem(
            pokemonIndex: tempIndex,
            isHero: false,
            isVariety: widget.isVariety,
          ));
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
            Row(
              // todo pichu placeholder causes A RenderFlex overflowed by 1840 pixels on the right.
              mainAxisAlignment: MainAxisAlignment.center,
              children: chain,
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
      result.add('NULL');
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

  Widget get _pokemonTypes {
    List types = widget.pokemon['types'];
    var typesResult = '';
    for (final type in types) {
      typesResult += ', ${type['type']['name']}';
    }
    typesResult = typesResult.substring(2);
    return !widget.isVariety
        ? Text(
            (types.isEmpty ? '' : 'Type: ') + typesResult,
            textAlign: TextAlign.center,
            style: GoogleFonts.sedgwickAveDisplay(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: colorMap[widget.pokemonSpecies!['color']['name']] ??
                    Colors.red),
          )
        : SizedBox(
            height: 45,
            child: GradientText(
              (types.isEmpty ? '' : 'Type: ') + typesResult,
              textAlign: TextAlign.center,
              style: GoogleFonts.sedgwickAveDisplay(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
              ),
              colors: const [
                Color(0xFFff00ff), // Pink
                Color(0xFF00ff00), // Green
                Color(0xFF0000ff), // Blue
              ],
            ),
          );
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
    const varietyColors = [
      Color(0xFFff00ff), // Pink
      Color(0xFF00ff00), // Green
      Color(0xFF0000ff), // Blue
    ];
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
    Widget image = CachedNetworkImage(
      imageUrl: widget.pokemon['sprites']['front_default'],
      placeholder: (context, url) => Image.asset(
        'assets/images/poke_ball_icon.png',
      ),
      height: 300,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    final pokemonColor = widget.isVariety
        ? null
        : colorMap[widget.pokemonSpecies!['color']['name']] ?? Colors.red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: pokemonColor ?? varietyColors[2],
        foregroundColor: !widget.isVariety ? Colors.white : varietyColors.first,
        title: Center(
          child: !widget.isVariety
              ? Text(
                  widget.pokemon['name'],
                  style: GoogleFonts.sedgwickAveDisplay(
                      color: const Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 42,
                      fontWeight: FontWeight.bold),
                )
              : GradientText(
                  widget.pokemon['name'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sedgwickAveDisplay(
                    fontSize: 42.0,
                    fontWeight: FontWeight.bold,
                  ),
                  colors: [varietyColors[0], varietyColors[1]],
                ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Hero(
                tag: widget.pokemon['id'],
                child: image,
              ),
              _pokemonTypes,
              const SizedBox(height: 50),
              if (!widget.isVariety) randomText!,
              const SizedBox(height: 50),
              if (widget.pokemonSpecies != null)
                PokemonTable(
                  entries: [
                    [
                      const {'Gen': true},
                      {widget.pokemonSpecies!['generation']['name']: false}
                    ],
                    [
                      {_eggGroups[0]: true},
                      {_eggGroups[1]: false}
                    ],
                    [
                      const {'Growth Rate': true},
                      {widget.pokemonSpecies!['growth_rate']['name']: false}
                    ],
                    [
                      const {'Habitat': true},
                      {widget.pokemonSpecies!['habitat']['name']: false}
                    ],
                  ],
                  pokemonColor: pokemonColor,
                  varietyColors: varietyColors,
                  tableName: 'Pokémon Info',
                ),
              if (widget.pokemonSpecies != null) const SizedBox(height: 70),
              if (abilities != null)
                PokemonTable(
                  entries: abilities,
                  pokemonColor: pokemonColor,
                  tableName: 'Abilities',
                  varietyColors: varietyColors,
                ),
              if (moves != null)
                PokemonTable(
                  entries: moves,
                  pokemonColor: pokemonColor,
                  tableName: 'Moves',
                  varietyColors: varietyColors,
                ),
              if (stats != null)
                PokemonTable(
                  entries: stats,
                  pokemonColor: pokemonColor,
                  tableName: 'Stats',
                  varietyColors: varietyColors,
                ),
              const SizedBox(height: 70),
              if (!widget.isVariety) evoloutionChain,
              if (!widget.isVariety) const SizedBox(height: 70),
              if (!widget.isVariety)
                GradientText(
                  varieties != null ? 'Varities' : 'No Varities',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sedgwickAveDisplay(
                    fontSize: 30.0,
                  ),
                  colors: varietyColors,
                ),
              if (!widget.isVariety && varieties != null)
                PokemonVarietiesSliderRow(pokemonIndecies: varieties!),
              const SizedBox(height: 80)
            ],
          ),
        ),
      ),
    );
  }
}
