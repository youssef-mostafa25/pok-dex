import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/widgets/pokemon_table.dart';

class PokemonVarietyScreen extends StatelessWidget {
  const PokemonVarietyScreen({super.key, required this.variety});

  final Map variety;

  List<List<Map<String, bool>>>? get _abilities {
    final List abilities = variety['abilities'];
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
    final List moves = variety['moves'];
    if (moves.isEmpty) return null;
    List<List<Map<String, bool>>> result = [];
    result.add([
      {'Ability Name': true},
      {'Move Learn Method': true},
      {'Version Group': true},
      {'Level Learned At': true}
    ]);
    List<Map<String, bool>> list;

    for (final move in moves) {
      for (int i = 0; i < move['version_group_details'].length; i++) {
        list = [];
        list.add({move['move']['name']: false});
        list.add({
          move['version_group_details'][i]['move_learn_method']['name']: false
        });
        list.add(
            {move['version_group_details'][i]['version_group']['name']: false});
        list.add({
          move['version_group_details'][i]['level_learned_at'].toString(): false
        });
        result.add(list);
      }
    }

    return result;
  }

  List<List<Map<String, bool>>>? get _stats {
    final List stats = variety['stats'];
    if (stats.isEmpty) return null;
    List<List<Map<String, bool>>> result = [];
    result.add([
      {'Stat Name': true},
      {'Base Stat': true},
      {'Effort': true}
    ]);
    List<Map<String, bool>> list;

    for (final stat in stats) {
      list = [];
      list.add({stat['stat']['name']: false});
      list.add({stat['base_stat'].toString(): false});
      list.add({stat['effort'].toString(): false});
      result.add(list);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final abilities = _abilities;
    final moves = _moves;
    final stats = _stats;
    Widget image = CachedNetworkImage(
        imageUrl: variety['sprites']['front_default'],
        placeholder: (context, url) => Image.asset(
              'assets/images/poke_ball_icon.png',
            ),
        height: 300,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => const Icon(Icons.error));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        foregroundColor: Colors.white,
        title: Text(
          variety['name'],
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
                tag: variety['id'],
                child: image,
              ),

              // todo pokemon type with icon

              const SizedBox(height: 50),
              if (abilities != null)
                PokemonTable(
                  entries: abilities,
                  pokemonColor: const Color.fromRGBO(97, 97, 97, 1),
                ),
              if (moves != null)
                PokemonTable(
                  entries: moves,
                  pokemonColor: const Color.fromRGBO(97, 97, 97, 1),
                ),
              if (stats != null)
                PokemonTable(
                  entries: stats,
                  pokemonColor: const Color.fromRGBO(97, 97, 97, 1),
                ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
