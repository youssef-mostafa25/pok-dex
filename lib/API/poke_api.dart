import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokedex/API/poke_api_interface.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/Model/pokemon_ability.dart';
import 'package:pokedex/Model/pokemon_item_identifier.dart';
import 'package:pokedex/Model/pokemon_move.dart';
import 'package:pokedex/Model/pokemon_stat.dart';
import 'package:pokedex/Model/static_data.dart';

class PokeAPI implements PokeApiInterface {
  @override
  Future<List<String>> getFilter(Uri url) async {
    List<String> list = [];
    final response = await http.get(url);
    final decodedResponse = json.decode(response.body);
    final results = decodedResponse['results'];

    list.add('all');
    for (final result in results) {
      list.add(result['name']);
    }
    return list;
  }

  @override
  Future<List<List<Pokemon>>> getEvoloutionChain(
      String evoloutionChainUrl) async {
    List<String> segments = evoloutionChainUrl.split("/");
    String evoloutionIndex = segments[segments.length - 2];

    var url =
        Uri.https('pokeapi.co', 'api/v2/evolution-chain/$evoloutionIndex/');
    var response = await http.get(url);
    var result = jsonDecode(response.body)['chain'];

    List<List<int>> pokemonIndeciesChains = [];
    for (int i = 0; i < result['evolves_to'].length; i++) {
      List<int> chain = [];
      var tempUrl = result['species']['url'];
      List<String> segments = tempUrl.split("/");
      int tempIndex = int.parse(segments[segments.length - 2]);
      chain.add(tempIndex);
      var tempResult = result['evolves_to'];
      while (tempResult.isNotEmpty) {
        tempUrl = tempResult[i]['species']['url'];
        segments = tempUrl.split("/");
        tempIndex = int.parse(segments[segments.length - 2]);
        chain.add(tempIndex);
        tempResult = tempResult[i]['evolves_to'];
      }
      pokemonIndeciesChains.add(chain);
    }
    List<List<Pokemon>> pokemonChains = [];
    for (final pokemonIndeciesChain in pokemonIndeciesChains) {
      List<Pokemon> pokemonChain = [];
      for (final pokemonIndex in pokemonIndeciesChain) {
        Pokemon pokemon =
            await getPokemon(pokemonIndex.toString(), true, false, null);
        pokemonChain.add(pokemon);
      }
      pokemonChains.add(pokemonChain);
    }
    return pokemonChains;
  }

  @override
  Future<List<Pokemon>> getVarieties(
      List varietiesListMap, Color pokemonColor) async {
    List<int> pokemonIndecies = [];
    List segments;
    int index;
    for (final variety in varietiesListMap) {
      String url = variety['pokemon']['url'];
      segments = url.split("/");
      index = int.parse(segments[segments.length - 2]);
      if (variety['is_default'] == false) {
        pokemonIndecies.add(index);
      }
    }
    List<Pokemon> pokemonVarieties = [];
    for (final pokemonIndex in pokemonIndecies) {
      Pokemon pokemon =
          await getPokemon(pokemonIndex.toString(), true, true, pokemonColor);
      pokemonVarieties.add(pokemon);
    }
    return pokemonVarieties;
  }

  List<Uri> _getFilterUrls(
      String color, String type, String habitat, String pokedex) {
    final List<Uri> result = [];
    if (color != 'all') {
      result.add(
        Uri.https('pokeapi.co', 'api/v2/pokemon-color/$color'),
      );
    }
    if (type != 'all') {
      result.add(
        Uri.https('pokeapi.co', 'api/v2/type/$type'),
      );
    }
    if (habitat != 'all') {
      result.add(
        Uri.https('pokeapi.co', 'api/v2/pokemon-habitat/$habitat'),
      );
    }
    if (pokedex != 'all') {
      result.add(
        Uri.https('pokeapi.co', 'api/v2/pokedex/$pokedex'),
      );
    }
    return result;
  }

  @override
  Future<Map> getPokemonMap(String pokemonNameOrId) async {
    final url = Uri.https('pokeapi.co', 'api/v2/pokemon/$pokemonNameOrId/');
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Future<Map> getPokemonSpeciesMap(String pokemonNameOrId) async {
    final url =
        Uri.https('pokeapi.co', 'api/v2/pokemon-species/$pokemonNameOrId/');
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  String _getPokemonUrl(Map entry) {
    // ignore: prefer_if_null_operators
    return entry['url'] != null
        ? entry['url']
        : entry['pokemon'] != null
            ? entry['pokemon']['url']
            : entry['pokemon_species']['url'];
  }

  String _getPokemonName(Map entry) {
    // ignore: prefer_if_null_operators
    return entry['name'] != null
        ? entry['name']
        : entry['pokemon'] != null
            ? entry['pokemon']['name']
            : entry['pokemon_species']['name'];
  }

  List<PokemonItemIdentifier> _fillPokemonItemIdentifierList(List entries) {
    List<PokemonItemIdentifier> pokemonItemIdentifierList = [];
    for (final entry in entries) {
      String url = _getPokemonUrl(entry);
      List<String> segments = url.split("/");
      if (int.parse(segments[segments.length - 2]) < 10000) {
        pokemonItemIdentifierList.add(PokemonItemIdentifier(
            _getPokemonName(entry), int.parse(segments[segments.length - 2])));
      }
    }
    pokemonItemIdentifierList.sort((a, b) => (a.number).compareTo(b.number));
    return pokemonItemIdentifierList;
  }

  List<int> _getPokemonItemIdentifierNumbers(
      List<PokemonItemIdentifier> pokemonItemIdentifierList) {
    List<int> numbersList = [];
    for (final pokemonItemIdentifier in pokemonItemIdentifierList) {
      numbersList.add(pokemonItemIdentifier.number);
    }
    return numbersList;
  }

  List<PokemonItemIdentifier> _andPokemonItemIdentifierLists(
      List<PokemonItemIdentifier> pokemonItemIdentifierListOne,
      List<PokemonItemIdentifier> pokemonItemIdentifierListTwo) {
    pokemonItemIdentifierListOne = pokemonItemIdentifierListOne
        .where((value) =>
            _getPokemonItemIdentifierNumbers(pokemonItemIdentifierListTwo)
                .contains(value.number))
        .toList();

    return pokemonItemIdentifierListOne;
  }

  List _getResultsMap(Map decodedResponse) {
    return decodedResponse['results'] ??
        decodedResponse['pokemon_species'] ??
        decodedResponse['pokemon'] ??
        decodedResponse['pokemon_entries'];
  }

  void _applySort(
      List<PokemonItemIdentifier> pokemonItemIdentifierList, Sort sortBy) {
    if (sortBy == Sort.idAscending || sortBy == Sort.idDescending) {
      if (sortBy == Sort.idAscending) {
        pokemonItemIdentifierList.sort((a, b) => a.number.compareTo(b.number));
      } else {
        pokemonItemIdentifierList.sort((a, b) => b.number.compareTo(a.number));
      }
    } else {
      if (sortBy == Sort.nameAscending) {
        pokemonItemIdentifierList.sort((a, b) => a.name.compareTo(b.name));
      } else {
        pokemonItemIdentifierList.sort((a, b) => b.name.compareTo(a.name));
      }
    }
  }

  @override
  Future<List<PokemonItemIdentifier>> loadPokemon(String color, String type,
      String habitat, String pokedex, String searchValue, Sort sortBy) async {
    final List<Uri> urls = _getFilterUrls(color, type, habitat, pokedex);
    if (urls.isEmpty) {
      urls.add(
        Uri.https(
          'pokeapi.co',
          'api/v2/pokemon-species',
          {
            'limit': '100000',
            'offset': '0',
            'queryParamWithQuestionMark': '?',
          },
        ),
      );
    }
    var response = await http.get(urls[0]);
    var decodedResponse = json.decode(response.body);
    var pokemonItemIdentifierListOne =
        _fillPokemonItemIdentifierList(_getResultsMap(decodedResponse));
    for (int i = 1; i < urls.length; i++) {
      var response = await http.get(urls[i]);
      var decodedResponse = json.decode(response.body);
      final pokemonItemIdentifierListTwo =
          _fillPokemonItemIdentifierList(_getResultsMap(decodedResponse));
      pokemonItemIdentifierListOne = _andPokemonItemIdentifierLists(
          pokemonItemIdentifierListOne, pokemonItemIdentifierListTwo);
    }
    if (searchValue.isNotEmpty) {
      for (int i = 0; i < pokemonItemIdentifierListOne.length; i++) {
        if (!pokemonItemIdentifierListOne[i].name.contains(searchValue)) {
          pokemonItemIdentifierListOne.removeAt(i);
          i--;
        }
      }
    }
    _applySort(pokemonItemIdentifierListOne, sortBy);
    return pokemonItemIdentifierListOne;
  }

  String _getRandomFlavourText(Map pokemonSpecies) {
    final List flavorTextEntries = pokemonSpecies['flavor_text_entries'];
    final int randomIndex = Random().nextInt(flavorTextEntries.length);
    Map randomMap = flavorTextEntries[randomIndex];
    String randomFlavorText = randomMap['flavor_text'].replaceAll('\n', ' ');
    return randomFlavorText;
  }

  String _getPokemonTypes(Map pokemon) {
    List types = pokemon['types'];
    var typesResult = '';
    for (final type in types) {
      typesResult += ', ${type['type']['name']}';
    }
    typesResult = typesResult.substring(2);
    return typesResult;
  }

  String _getEggGroups(Map pokemonSpecies) {
    final List eggGroupList = pokemonSpecies['egg_groups'];
    var groups = '';
    for (final eggGroup in eggGroupList) {
      groups = '${groups + eggGroup['name']}, ';
    }
    groups = groups.substring(0, groups.length - 2);
    return groups;
  }

  List<Ability> _getAbilities(Map pokemon) {
    final List abilitiesMap = pokemon['abilities'];
    if (abilitiesMap.isEmpty) return [];
    List<Ability> abilities = [];

    for (final abilityMap in abilitiesMap) {
      final name = abilityMap['ability']['name'];
      final slot = abilityMap['slot'].toString();
      final ability = Ability(name, int.parse(slot));
      abilities.add(ability);
    }

    return abilities;
  }

  List<Move> _getMoves(Map pokemon) {
    final List movesMap = pokemon['moves'];
    if (movesMap.isEmpty) return [];
    List<Move> moves = [];

    for (final moveMap in movesMap) {
      final name = moveMap['move']['name'];
      final learnMethod =
          moveMap['version_group_details'][0]['move_learn_method']['name'];
      final move = Move(name, learnMethod);
      moves.add(move);
    }

    return moves;
  }

  List<Stat> _getStats(Map pokemon) {
    final List statsMap = pokemon['stats'];
    if (statsMap.isEmpty) return [];
    List<Stat> stats = [];

    for (final statMap in statsMap) {
      final name = statMap['stat']['name'];
      final base = statMap['base_stat'].toString();
      final stat = Stat(name, base);
      stats.add(stat);
    }

    return stats;
  }

  @override
  Future<Pokemon> getPokemon(String pokemonNameOrId, bool isForPokemonItem,
      bool? isPokemonVariety, Color? varietyColor) async {
    Map pokemon = await getPokemonMap(pokemonNameOrId);
    Map? pokemonSpecies;
    try {
      pokemonSpecies = await getPokemonSpeciesMap(pokemonNameOrId);
      // ignore: empty_catches
    } catch (e) {}

    String imageUrl = 'assets/images/poke_ball_icon.png';
    if (pokemon['sprites']['other']['official-artwork']['front_default'] !=
        null) {
      imageUrl =
          pokemon['sprites']['other']['official-artwork']['front_default'];
    } else if (pokemon['sprites']['other']['dream_world']['front_default'] !=
        null) {
      imageUrl = pokemon['sprites']['other']['dream_world']['front_default'];
    } else if (pokemon['sprites']['other']['home']['front_default'] != null) {
      imageUrl = pokemon['sprites']['other']['home']['front_default'];
    } else if (pokemon['sprites']['front_default'] != null) {
      imageUrl = pokemon['sprites']['front_default'];
    }

    final String name = pokemon['name'];
    final int id = pokemon['id'];
    final bool isVariety = isPokemonVariety ?? false;
    final Color color = varietyColor ??
        (pokemonSpecies != null &&
                colorMap[pokemonSpecies['color']['name']] != null
            ? colorMap[pokemonSpecies['color']['name']]!
            : Colors.red);
    final String evoloutionChainUrl =
        pokemonSpecies == null ? '' : pokemonSpecies['evolution_chain']['url'];
    final List varietiesMap =
        pokemonSpecies == null ? [] : pokemonSpecies['varieties'];
    final List<List<Pokemon>> evoloutionChain =
        isVariety || isForPokemonItem || pokemonSpecies == null
            ? []
            : await getEvoloutionChain(evoloutionChainUrl);
    final List<Pokemon> varieties =
        isVariety || isForPokemonItem || pokemonSpecies == null
            ? []
            : await getVarieties(varietiesMap, color);
    final String flavourText =
        pokemonSpecies == null ? '' : _getRandomFlavourText(pokemonSpecies);
    final String type = _getPokemonTypes(pokemon);
    final String generation = pokemonSpecies == null
        ? ''
        : pokemonSpecies['generation'] != null
            ? pokemonSpecies['generation']['name']
            : 'null';
    final String eggGroup = pokemonSpecies == null
        ? ''
        : pokemonSpecies['egg_groups'] != null &&
                pokemonSpecies['egg_groups'].isNotEmpty
            ? _getEggGroups(pokemonSpecies)
            : 'null';
    final String growthRate = pokemonSpecies == null
        ? ''
        : pokemonSpecies['growth_rate'] != null
            ? pokemonSpecies['growth_rate']['name']
            : 'null';
    final String habitat = pokemonSpecies == null
        ? ''
        : pokemonSpecies['habitat'] != null
            ? pokemonSpecies['habitat']['name']
            : 'null';
    final List<Ability> abilities = _getAbilities(pokemon);
    final List<Move> moves = _getMoves(pokemon);
    final List<Stat> stats = _getStats(pokemon);

    return Pokemon(
      name,
      id,
      imageUrl,
      isVariety,
      color,
      evoloutionChainUrl,
      varietiesMap,
      evoloutionChain,
      varieties,
      flavourText,
      type,
      generation,
      eggGroup,
      growthRate,
      habitat,
      abilities,
      moves,
      stats,
    );
  }
}
