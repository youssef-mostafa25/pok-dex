import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/API/poke_api.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/Model/static_data.dart';
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
  List<List<Pokemon>>? evoloutionChain;
  var _isGettingVarieties = true;
  var _errorGettingVarieties = false;
  List<Pokemon>? varieties;
  Widget? flavourText;
  final api = PokeAPI();

  void getPokemonVarietiesList()

  @override
  void initState() async {
    super.initState();
    if (!widget.pokemon.isVariety) {
      try {
        evoloutionChain =
            await api.getEvoloutionChain(widget.pokemon.evoloutionChainUrl);
        setState(() {
          _isGettingEvoChain = false;
        });
      } catch (e) {
        setState(() {
          _isGettingEvoChain = false;
          _errorGettingEvolution = true;
        });
      }
      try {
        getPokemonVarietiesList();
        setState(() {
          _isGettingVarieties = false;
        });
      } catch (e) {
        setState(() {
          _isGettingVarieties = false;
          _errorGettingVarieties = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final abilities = widget.pokemon.abilities;
    final moves = widget.pokemon.moves;
    final stats = widget.pokemon.stats;
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
      if (_errorGettingEvolution) {
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
                      pokemon: varieties!, originalColor: pokemonColor),
                const SizedBox(height: 80)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
