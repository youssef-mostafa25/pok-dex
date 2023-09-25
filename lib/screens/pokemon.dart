import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/widgets/pokemon_item.dart';

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key, required this.pokemon});

  final Map pokemon;

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  Widget? evoloutionChain;
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

      evoloutionChain = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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

  @override
  Widget build(BuildContext context) {
    getEvoloution();
    Widget content;
    if (_error) {
      content = const Text('Something went wrong');
    } else {
      if (_isGettingEvoChain) {
        content = const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        content = evoloutionChain ??
            const Text('No evoloution chain exists for this pokemon!');
      }
    }
    Widget image = CachedNetworkImage(
      imageUrl:
          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${widget.pokemon['id']}.png",
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(value: downloadProgress.progress),
      height: 300,
      fit: BoxFit.cover,
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 17, 0),
        foregroundColor: Colors.white,
        title: const Text('Pokedéx'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                widget.pokemon['name'],
                style: GoogleFonts.sedgwickAveDisplay(
                    color: Colors.red,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              Hero(
                tag: widget.pokemon['id'],
                child: image,
              ),
              content,
            ],
          ),
        ),
      ),
    );
  }
}
