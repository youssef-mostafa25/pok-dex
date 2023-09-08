import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PokemonGrid extends StatelessWidget {
  PokemonGrid({
    super.key,
    required this.pokedexName,
    required this.pokedexNumber,
  });

  String pokedexName;
  String pokedexNumber;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(pokedexName),
        // GridView.builder(
        //   // Change the grid properties as needed
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //     crossAxisCount: 2, // Number of columns
        //     crossAxisSpacing: 10.0, // Spacing between columns
        //     mainAxisSpacing: 10.0, // Spacing between rows
        //   ),
        //   itemCount: 10, // Number of items in the grid
        //   itemBuilder: (BuildContext context, int index) {
        //     // Replace this with your own widget for each grid item
        //     return Container(
        //       color: Colors.blue,
        //       alignment: Alignment.center,
        //       child: Text('Item $index'),
        //     );
        //   },
        // ),
      ],
    );
  }
}
