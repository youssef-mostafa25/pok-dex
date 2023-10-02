import 'package:flutter/material.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/Model/pokemon_ability.dart';
import 'package:pokedex/Model/pokemon_move.dart';
import 'package:pokedex/Model/pokemon_stat.dart';

abstract class PokeApiInterface {
  List<Uri> getFilterUrls(
      String color, String type, String habitat, String pokedex);
  Future<List<Pokemon>> getPokemonAfterFilter(
      String color, String type, String habitat, String pokedex);
  void fillFilter(Uri url, List<String> list);
  void fillFilters(List<String> colors, List<String> types,
      List<String> habitats, List<String> pokedexes);
  Future<Map> getPokemon(String pokemonNameOrId);
  Future<Map> getPokemonSpecies(String pokemonNameOrId);
  Future<Pokemon> createPokemon(String pokemonNameOrId, bool isForPokemonItem,
      bool? isPokemonVariety, Color? varietyColor);
  Future<List<List<Pokemon>>> getEvoloutionChain(Map pokemonSpecies);
  Future<List<Pokemon>> getVarieties(Map pokemonSpecies);
  String getRandomFlavourText(Map pokemonSpecies);
  String getPokemonTypes(Map pokemon);
  String getEggGroups(Map pokemonSpecies);
  List<Ability> getAbilities(Map pokemon);
  List<Move> getMoves(Map pokemon);
  List<Stat> getStats(Map pokemon);
}
