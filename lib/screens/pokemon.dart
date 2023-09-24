import 'dart:convert';

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
      var url = Uri.https('pokeapi.co', 'api/v2/evolution-chain/');
      var response = await http.get(url);
      var result = jsonDecode(response.body);
      var lowerBound = 0;
      var upperBound = result['count'];
      var size = upperBound - lowerBound;
      while (size > 0) {
        final index = (lowerBound + upperBound) ~/ 2;
        url = Uri.https('pokeapi.co', 'api/v2/evolution-chain/$index/');
        response = await http.get(url);
        result = jsonDecode(response.body)['chain'];

        var smallUrl = result['species']['url'];
        List<String> segments = smallUrl.split("/");
        int smallID = int.parse(segments[segments.length - 2]);

        if (result['evolves_to'].isNotEmpty) {
          result = result['evolves_to'];
          while ((result[0]['evolves_to']).isNotEmpty) {
            result = result[0]['evolves_to'];
          }
        }

        String bigUrl;
        if (result is List) {
          bigUrl = result[0]['species']['url'];
        } else {
          bigUrl = result['species']['url'];
        }
        segments = bigUrl.split("/");
        int bigID = int.parse(segments[segments.length - 2]);

        final id = widget.pokemon['id'].toInt();

        if (id < smallID) {
          upperBound = index;
          if (upperBound - lowerBound == size) lowerBound++;
          continue;
        } else if (id > bigID) {
          lowerBound = index;
          if (upperBound - lowerBound == size) lowerBound++;
          continue;
        } else if (id >= smallID && id <= bigID) {
          result = jsonDecode(response.body)['chain'];

          List<Widget> chain = [];

          while (result.isNotEmpty) {
            String currUrl;
            if (result is List) {
              currUrl = result[0]['species']['url'];
            } else {
              currUrl = result['species']['url'];
            }

            segments = currUrl.split("/");
            int currID = int.parse(segments[segments.length - 2]);
            chain.add(
              PokemonItem(
                pokemonIndex: currID,
                fromPokemonHomeScreen: false,
              ),
            );
            chain.add(
              const Icon(Icons.arrow_right_alt_rounded),
            );
            if (result is List) {
              result = result[0]['evolves_to'];
            } else {
              result = result['evolves_to'];
            }
          }

          if (chain.isNotEmpty) chain.removeLast();

          evoloutionChain = Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: chain,
          );
          setState(() {
            _isGettingEvoChain = false;
          });
          return;
        }
      }
    } catch (e) {
      setState(() {
        _error = true;
        _isGettingEvoChain = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getEvoloution();
    Widget content;
    if (!_isGettingEvoChain) {
      if (!_error) {
        content = evoloutionChain ??
            const Text('No evoloution chain exists for this pokemon!');
      } else {
        content = const Text('Something went wrong');
      }
    } else {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 17, 0),
        foregroundColor: Colors.white,
        title: const Text('Pokedéx'),
      ),
      body: Center(
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
                  color: Colors.red, fontSize: 40, fontWeight: FontWeight.bold),
            ),
            Hero(
              tag: widget.pokemon['id'],
              child: Image.network(
                widget.pokemon['sprites']['front_default'],
                height: 300,
                // width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            content,
          ],
        ),
      ),
    );
  }
}
