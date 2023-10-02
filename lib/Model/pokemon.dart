import 'package:flutter/material.dart';
import 'package:pokedex/Model/pokemon_ability.dart';
import 'package:pokedex/Model/pokemon_move.dart';
import 'package:pokedex/Model/pokemon_stat.dart';
import 'package:pokedex/Model/static_data.dart';

class Pokemon {
  const Pokemon(
      this.name,
      this.number,
      this.imageUrl,
      this.isVariety,
      this.color,
      this.evoloutionChain,
      this.varieties,
      this.flavourText,
      this.type,
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
  final List<List<Pokemon>> evoloutionChain;
  final List<Pokemon> varieties;
  final String flavourText;
  final String type;
  final String generation;
  final String eggGroup;
  final String growthRate;
  final String habitat;
  final List<Ability> abilities;
  final List<Move> moves;
  final List<Stat> stats;

  void filterBySearchValue(List<Pokemon> pokemon, String searchValue) {
    for (int i = 0; i < pokemon.length; i++) {
      if (!pokemon[i].name.contains(searchValue)) {
        pokemon.removeAt(i);
        i--;
      }
    }
  }

  void applySort(List<Pokemon> pokemon, Sort sortBy) {
    if (sortBy == Sort.idAscending || sortBy == Sort.idDescending) {
      if (sortBy == Sort.idAscending) {
        pokemon.sort((a, b) => (a.number).compareTo(b.number));
      } else {
        pokemon.sort((a, b) => (b.number).compareTo(a.number));
      }
    } else {
      if (sortBy == Sort.nameAscending) {
        pokemon.sort((a, b) => a.name.compareTo(b.name));
      } else {
        pokemon.sort((a, b) => b.name.compareTo(a.name));
      }
    }
  }
}
