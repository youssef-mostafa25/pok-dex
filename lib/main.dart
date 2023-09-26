import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pokedex/screens/pokemon_home.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(
            'Pokédex',
            style: GoogleFonts.sedgwickAveDisplay(
                fontSize: 50, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: const PokemonHomeScreen(),
      ),
    );
  }
}
