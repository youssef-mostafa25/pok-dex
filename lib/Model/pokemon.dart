import 'package:flutter/material.dart';
import 'package:pokedex/Model/pokemon_ability.dart';
import 'package:pokedex/Model/pokemon_move.dart';
import 'package:pokedex/Model/pokemon_stat.dart';
import 'package:pokedex/Model/static_data.dart';

class Pokemon {
  Pokemon(
      this.name,
      this.number,
      this.imageUrl,
      this.isVariety,
      this.color,
      this.evoloutionChainUrl,
      this.varietiesMap,
      this.evoloutionChain,
      this.varieties,
      this.flavourText,
      this.types,
      this.generation,
      this.eggGroup,
      this.growthRate,
      this.habitat,
      this.abilities,
      this.moves,
      this.stats);

  final String name;
  final int number;
  final String imageUrl;
  final bool isVariety;
  final Color color;
  final String evoloutionChainUrl;
  final List varietiesMap;
  List<List<Pokemon>> evoloutionChain;
  List<Pokemon> varieties;
  final String flavourText;
  final String types;
  final String generation;
  final String eggGroup;
  final String growthRate;
  final String habitat;
  final List<Ability> abilities;
  final List<Move> moves;
  final List<Stat> stats;
}
