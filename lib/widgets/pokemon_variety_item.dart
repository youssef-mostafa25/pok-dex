import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/screens/pokemon_variety.dart';

class PokemonVarietyItem extends StatefulWidget {
  const PokemonVarietyItem({super.key, required this.entry});

  final int entry;

  @override
  State<PokemonVarietyItem> createState() => _PokemonVarietyItemState();
}

class _PokemonVarietyItemState extends State<PokemonVarietyItem> {
  Map? _variety;
  bool _error = false;

  void _getPokemon() async {
    try {
      final url = Uri.https('pokeapi.co', 'api/v2/pokemon/${widget.entry}/');
      final response = await http.get(url);
      if (mounted) {
        setState(() {
          _variety = jsonDecode(response.body);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _getPokemon();
    Widget image = CachedNetworkImage(
      imageUrl:
          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${widget.entry}.png",
      placeholder: (context, url) => Image.asset(
        'assets/images/poke_ball_icon.png',
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
    Widget text;
    if (_variety != null) {
      image = Hero(
        tag: _variety!['id'],
        child: SizedBox(
          width: 80,
          height: 80,
          child: image,
        ),
      );
      text = Text(
        _variety!['name'],
        style: GoogleFonts.handlee(),
      );
    } else {
      image = const CircularProgressIndicator();
      text = const Text('loading...');
    }

    if (_error) {
      image = const Icon(Icons.question_mark);
      text = const Text('something\nwent wrong');
    }
    return GestureDetector(
      // onTap: () {
      //   if (_error || _variety == null) return;

      //   Navigator.of(context).push(MaterialPageRoute(
      //       builder: (context) => PokemonVarietyScreen(variety: _variety!)));
      // },
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle, // Make it circular
        ), // Change color as needed
        margin: const EdgeInsets.all(8.0), // Adjust spacing between items
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image,
              text,
            ],
          ),
        ),
      ),
    );
  }
}
