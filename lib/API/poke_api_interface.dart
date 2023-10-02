import 'package:flutter/material.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/Model/pokemon_ability.dart';
import 'package:pokedex/Model/pokemon_move.dart';
import 'package:pokedex/Model/pokemon_stat.dart';
import 'package:pokedex/Model/static_data.dart';

abstract class PokeApiInterface {
  List<Uri> getFilterUrls(
      String color, String type, String habitat, String pokedex);
  Future<List<Pokemon>> loadPokemonAfterFilters(String color, String type,
      String habitat, String pokedexString, String searchValue, Sort sortBy);
  Future<List<Pokemon>> loadPokemon();
  void fillFilter(Uri url, List<String> list);
  void fillFilters(List<String> colors, List<String> types,
      List<String> habitats, List<String> pokedexes);
  Future<Map> getPokemonMap(String pokemonNameOrId);
  Future<Map> getPokemonSpeciesMap(String pokemonNameOrId);
  Future<Pokemon> createPokemon(String pokemonNameOrId, bool isForPokemonItem,
      bool? isPokemonVariety, Color? varietyColor);
  Future<List<List<Pokemon>>> getEvoloutionChain(String evoloutionChainUrl);
  Future<List<Pokemon>> getVarieties(List varietiesList, Color pokemonColor);
  String getRandomFlavourText(Map pokemonSpecies);
  String getPokemonTypes(Map pokemon);
  String getEggGroups(Map pokemonSpecies);
  List<Ability> getAbilities(Map pokemon);
  List<Move> getMoves(Map pokemon);
  List<Stat> getStats(Map pokemon);
  String getPokemonUrl(Map entry);
  List<int> fillPokemonIds(List entries);
  List<int> andPokemonIndexLists(
      List<int> pokemonIndexListOne, List<int> pokemonIndexListTwo);
  List getResultsMap(Map decodedResponse);
  Future<List<Pokemon>> getAllPokemon(List<String> pokemonNamesOrIds,
      bool isForPokemonItem, bool? isPokemonVariety, Color? varietyColor);
}
