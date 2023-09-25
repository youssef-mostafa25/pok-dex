import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/static_data.dart';
import 'package:pokedex/widgets/pokemon_item.dart';
import 'package:pokedex/widgets/pokemon_table.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key, required this.pokemon});

  final Map pokemon;

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  Widget? optionalEvoloutionChain;
  var _isGettingEvoChain = true;
  var _error = false;

  void getEvoloution() async {
    try {
      final evoloutionUrl = widget.pokemon['evolution_chain']['url'];
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
          _error = true;
          _isGettingEvoChain = false;
        });
      }
    }
  }

  Widget? randomText;

  Widget get randomFlavourText {
    final List flavorTextEntries = widget.pokemon['flavor_text_entries'];
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

  List<String> get eggGroups {
    final List eggGroupList = widget.pokemon['egg_groups'];
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

  @override
  void initState() {
    super.initState();
    randomText = randomFlavourText;
  }

  @override
  Widget build(BuildContext context) {
    getEvoloution();
    Widget evoloutionChain;
    if (_error) {
      evoloutionChain = const Text('Something went wrong');
    } else {
      if (_isGettingEvoChain) {
        evoloutionChain = const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        evoloutionChain = optionalEvoloutionChain ??
            const Text('No evoloution chain exists for this pokemon!');
      }
    }
    Widget image = CachedNetworkImage(
      imageUrl:
          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${widget.pokemon['id']}.png",
      placeholder: (context, url) => Image.asset(
        'assets/images/poke_ball_icon.png',
      ),
      height: 300,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorMap[widget.pokemon['color']['name']] ??
            const Color.fromARGB(255, 255, 17, 0),
        foregroundColor: Colors.white,
        title: Text(
          widget.pokemon['name'],
          style: GoogleFonts.sedgwickAveDisplay(
              color: const Color.fromRGBO(255, 255, 255, 1),
              fontSize: 50,
              fontWeight: FontWeight.bold),
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
              randomText!,
              const SizedBox(height: 50),

              PokemonTable(
                entries: {
                  'Gen': widget.pokemon['generation']['name'],
                  eggGroups[0]: eggGroups[1],
                  'Growth Rate': widget.pokemon['growth_rate']['name'],
                  'Habitat': widget.pokemon['habitat']['name'],
                },
                pokemonColor: colorMap[widget.pokemon['color']['name']] ??
                    const Color.fromARGB(255, 255, 17, 0),
              ),

              const SizedBox(height: 30),

              evoloutionChain,

              //varieties

              const SizedBox(height: 80)
            ],
          ),
        ),
      ),
    );
  }
}
