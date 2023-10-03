import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/API/poke_api.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/Model/pokemon_ability.dart';
import 'package:pokedex/Model/pokemon_move.dart';
import 'package:pokedex/Model/pokemon_stat.dart';
import 'package:pokedex/View/widgets/pokemon_item.dart';
import 'package:pokedex/View/widgets/pokemon_table.dart';
import 'package:pokedex/View/widgets/pokemon_varieties_slider.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({
    super.key,
    required this.pokemon,
  });

  final Pokemon pokemon;

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  var _isGettingEvoChain = true;
  var _errorGettingEvolution = false;
  var _isGettingVarieties = true;
  var _errorGettingVarieties = false;
  Widget? flavourText;
  final api = PokeAPI();

  void loadPokemonVarietiesAndEvoChains() async {
    try {
      widget.pokemon.evoloutionChains =
          await api.getEvoloutionChain(widget.pokemon.evoloutionChainUrl);
      if (mounted) {
        setState(() {
          _isGettingEvoChain = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingEvoChain = false;
          _errorGettingEvolution = true;
        });
      }
    }
    try {
      widget.pokemon.varieties = await api.getVarieties(
          widget.pokemon.varietiesMap, widget.pokemon.color);
      if (mounted) {
        setState(() {
          _isGettingVarieties = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingVarieties = false;
          _errorGettingVarieties = true;
        });
      }
    }
  }

  List<List<Map<String, bool>>> tableMap(
      List entries, List<String> columnNames) {
    List<List<Map<String, bool>>> tableMap = [
      [
        for (final columnName in columnNames) {columnName: true}
      ]
    ];
    for (final entry in entries) {
      if (entry is Ability) {
        tableMap.add([
          {entry.name: false},
          {entry.slot.toString(): false}
        ]);
      } else if (entry is Move) {
        tableMap.add([
          {entry.name: false},
          {entry.learnMethod: false}
        ]);
      } else if (entry is Stat) {
        tableMap.add([
          {entry.name: false},
          {entry.base: false}
        ]);
      }
    }
    return tableMap;
  }

  @override
  void initState() {
    super.initState();
    if (!widget.pokemon.isVariety) {
      loadPokemonVarietiesAndEvoChains();
    }
  }

  @override
  Widget build(BuildContext context) {
    final abilities = widget.pokemon.abilities;
    final moves = widget.pokemon.moves;
    final stats = widget.pokemon.stats;
    List<List<Widget>> evoloutionChains = [];
    if (!widget.pokemon.isVariety) {
      if (_errorGettingEvolution) {
        evoloutionChains = [
          [const Text('Something went wrong')]
        ];
      } else {
        if (_isGettingEvoChain) {
          evoloutionChains = [
            [
              const Center(
                child: CircularProgressIndicator(),
              )
            ]
          ];
        } else {
          evoloutionChains = [];
          for (final chain in widget.pokemon.evoloutionChains) {
            List<Widget> currChain = [];
            for (final pokemon in chain) {
              currChain.add(
                SizedBox(
                  width: 100,
                  child: PokemonItem(
                    isHero: false,
                    isSamePokemon: pokemon.number == widget.pokemon.number,
                    pokemon: pokemon,
                  ),
                ),
              );
              currChain.add(const Icon(Icons.arrow_right_alt_rounded));
            }
            currChain.removeLast();
            evoloutionChains.add(currChain);
          }
        }
      }
    }
    String imageUrl = widget.pokemon.imageUrl;

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.pokemon.color,
        foregroundColor: Colors.white,
        title: Center(
          child: Text(
            widget.pokemon.name,
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
                widget.pokemon.color.withOpacity(0.05),
                widget.pokemon.color.withOpacity(0.2),
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
                  tag: widget.pokemon.number,
                  child: image,
                ),
                if (!widget.pokemon.isVariety)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.pokemon.flavourText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.handlee(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 50),
                PokemonTable(
                    entries: [
                      [
                        const {'Number': true},
                        {widget.pokemon.number.toString(): false},
                      ],
                      if (widget.pokemon.types.isNotEmpty)
                        [
                          {
                            widget.pokemon.types.length > 1 ? 'Types' : 'Type':
                                true
                          },
                          {widget.pokemon.types: false},
                        ]
                    ],
                    pokemonColor: widget.pokemon.color,
                    tableName: 'Pokémon Details'),
                const SizedBox(height: 50),
                if (!widget.pokemon.isVariety)
                  PokemonTable(
                    entries: [
                      [
                        const {'Generation': true},
                        {widget.pokemon.generation: false}
                      ],
                      [
                        const {'Egg Group': true},
                        {widget.pokemon.eggGroup: false}
                      ],
                      [
                        const {'Growth Rate': true},
                        {widget.pokemon.growthRate: false}
                      ],
                      [
                        const {'Habitat': true},
                        {widget.pokemon.habitat: false}
                      ],
                    ],
                    pokemonColor: widget.pokemon.color,
                    tableName: 'Pokémon Info',
                  ),
                if (!widget.pokemon.isVariety) const SizedBox(height: 70),
                if (abilities.isNotEmpty)
                  PokemonTable(
                    entries: tableMap(abilities, ['Name', 'Slot']),
                    pokemonColor: widget.pokemon.color,
                    tableName: 'Abilities',
                  ),
                if (abilities.isNotEmpty) const SizedBox(height: 70),
                if (moves.isNotEmpty)
                  PokemonTable(
                    entries: tableMap(moves, ['Name', 'Learn Method']),
                    pokemonColor: widget.pokemon.color,
                    tableName: 'Moves',
                  ),
                if (moves.isNotEmpty) const SizedBox(height: 70),
                if (stats.isNotEmpty)
                  PokemonTable(
                    entries: tableMap(stats, ['Name', 'Base']),
                    pokemonColor: widget.pokemon.color,
                    tableName: 'Stats',
                  ),
                if (stats.isNotEmpty) const SizedBox(height: 70),
                if (!widget.pokemon.isVariety && !_isGettingEvoChain)
                  GradientText(
                    widget.pokemon.varieties.isEmpty
                        ? 'No Evoloution Chain'
                        : widget.pokemon.varieties.length > 1
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
                if (!widget.pokemon.isVariety)
                  for (final chain in evoloutionChains)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [for (final widget in chain) widget],
                    ),
                if (!widget.pokemon.isVariety) const SizedBox(height: 70),
                if (!widget.pokemon.isVariety && !_isGettingVarieties)
                  GradientText(
                    widget.pokemon.varieties.isNotEmpty
                        ? widget.pokemon.varieties.length > 1
                            ? 'Varities'
                            : 'Variety'
                        : 'No Varities',
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
                if (_isGettingVarieties) const CircularProgressIndicator(),
                if (!widget.pokemon.isVariety &&
                    !_isGettingVarieties &&
                    !_errorGettingVarieties &&
                    widget.pokemon.varieties.isNotEmpty)
                  PokemonVarietiesSliderRow(pokemon: widget.pokemon.varieties),
                const SizedBox(height: 80)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
