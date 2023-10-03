import 'package:flutter/material.dart';
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/Model/pokemon_ability.dart';
import 'package:pokedex/Model/pokemon_item_identifier.dart';
import 'package:pokedex/Model/pokemon_move.dart';
import 'package:pokedex/Model/pokemon_stat.dart';
import 'package:pokedex/Model/static_data.dart';

abstract class PokeApiInterface {
  List<Uri> getFilterUrls(
      String color, String type, String habitat, String pokedex);
  void applySort(
      List<PokemonItemIdentifier> pokemonNamesAndNumbers, Sort sortBy);
  Future<List<PokemonItemIdentifier>> loadPokemonNamesAndIdsAfterFilters(
      String color,
      String type,
      String habitat,
      String pokedexString,
      String searchValue,
      Sort sortBy);
  Future<List<PokemonItemIdentifier>> loadPokemon();
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
  String getPokemonName(Map entry);
  List<PokemonItemIdentifier> fillPokemonItemIdentifierList(List entries);
  List<int> getPokemonItemIdentifierNumbers(
      List<PokemonItemIdentifier> pokemonItemIdentifierList);
  List<PokemonItemIdentifier> andPokemonItemIdentifierLists(
      List<PokemonItemIdentifier> pokemonIndexListOne,
      List<PokemonItemIdentifier> pokemonIndexListTwo);
  List getResultsMap(Map decodedResponse);
  Future<List<Pokemon>> getAllPokemon(List<String> pokemonNamesOrIds,
      bool isForPokemonItem, bool? isPokemonVariety, Color? varietyColor);
}
