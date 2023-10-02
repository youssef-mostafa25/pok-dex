import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pokedex/API/poke_api_interface.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/Model/pokemon.dart';
import 'package:pokedex/Model/pokemon_ability.dart';
import 'package:pokedex/Model/pokemon_move.dart';
import 'package:pokedex/Model/pokemon_stat.dart';
import 'package:pokedex/Model/static_data.dart';

class PokeAPI implements PokeApiInterface {
  @override
  void fillFilter(Uri url, List<String> list) async {
    final response = await http.get(url);
    final decodedResponse = json.decode(response.body);
    final results = decodedResponse['results'];

    for (final result in results) {
      // setState(() {
      list.add(result['name']);
      // });
    }
  }

  @override
  void fillFilters(List<String> colors, List<String> types,
      List<String> habitats, List<String> pokedexes) {
    // try{
    final colorUrl = Uri.https('pokeapi.co', 'api/v2/pokemon-color/');
    final typeUrl = Uri.https('pokeapi.co', 'api/v2/type/');
    final habitatUrl = Uri.https('pokeapi.co', 'api/v2/pokemon-habitat/');
    final pokedexUrl = Uri.https('pokeapi.co', 'api/v2/pokedex/');

    fillFilter(colorUrl, colors);
    fillFilter(typeUrl, types);
    fillFilter(habitatUrl, habitats);
    fillFilter(pokedexUrl, pokedexes);
    //   setState(() {
    //       _isFillingFilters = false;
    //     });
    //   } catch (e) {
    //   if (mounted) {
    //     setState(() {
    //       _isFillingFilters = false;
    //       _errorFillingFilters = true;
    //     });
    //   }
    // }
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
            await createPokemon(pokemonIndex.toString(), true, false, null);
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
      Pokemon pokemon = await createPokemon(
          pokemonIndex.toString(), true, true, pokemonColor);
      pokemonVarieties.add(pokemon);
    }
    return pokemonVarieties;
  }

  @override
  List<Uri> getFilterUrls(
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
    // try {
    final url = Uri.https('pokeapi.co', 'api/v2/pokemon/$pokemonNameOrId/');
    final response = await http.get(url);
    // if (mounted) {
    //   setState(() {
    //     _isGettingPokemon = false;
    return jsonDecode(response.body);
    //   });
    // }
    // } catch (e) {
    //   if (mounted) {
    //     setState(() {
    //       _isGettingPokemon = false;
    //       _errorPokemon = true;
    //     });
    //   }
    // }
  }

  @override
  Future<Map> getPokemonSpeciesMap(String pokemonNameOrId) async {
    // try {
    final url =
        Uri.https('pokeapi.co', 'api/v2/pokemon-species/$pokemonNameOrId/');
    final response = await http.get(url);
    //   if (mounted) {
    //     setState(() {
    //       _isGettingPokemonSpecies = false;
    return jsonDecode(response.body);
    //     });
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     setState(() {
    //       _isGettingPokemonSpecies = false;
    //       _errorPokemonSpecies = true;
    //     });
    //   }
    // }
  }

  @override
  Future<List<Pokemon>> getAllPokemon(
      List<String> pokemonNamesOrIds,
      bool isForPokemonItem,
      bool? isPokemonVariety,
      Color? varietyColor) async {
    List<Pokemon> pokemon = [];
    for (final pokemonNameOrId in pokemonNamesOrIds) {
      pokemon.add(await createPokemon(pokemonNameOrId, true, false, null));
    }
    return pokemon;
  }

  @override
  String getPokemonUrl(Map entry) {
    // ignore: prefer_if_null_operators
    return entry['url'] != null
        ? entry['url']
        : entry['pokemon'] != null
            ? entry['pokemon']['url']
            : entry['pokemon_species']['url'];
  }

  @override
  String getPokemonName(Map entry) {
    // ignore: prefer_if_null_operators
    return entry['name'] != null
        ? entry['name']
        : entry['pokemon'] != null
            ? entry['pokemon']['name']
            : entry['pokemon_species']['name'];
  }

  @override
  Map<int, String> fillPokemonNamesAndIds(List entries) {
    Map<int, String> pokemonNamesAndIdsTempMap = {};
    for (final entry in entries) {
      String url = getPokemonUrl(entry);
      List<String> segments = url.split("/");
      pokemonNamesAndIdsTempMap[int.parse(segments[segments.length - 2])] =
          getPokemonName(entry);
    }
    List keys = pokemonNamesAndIdsTempMap.keys.toList();
    keys.sort((a, b) => (a).compareTo(b));
    Map<int, String> pokemonNamesAndIdsMap = {};
    for (final key in keys) {
      pokemonNamesAndIdsMap[key] = pokemonNamesAndIdsTempMap[key]!;
    }
    return pokemonNamesAndIdsMap;
  }

  @override
  Map<int, String> andPokemonNamesAndNumbersMaps(
      Map<int, String> pokemonNamesAndNumbersMapOne,
      Map<int, String> pokemonNamesAndNumbersMapTwo) {
    Map<int, String> pokemonNamesAndNumbersAfterAnding = {};

    final mapOneKeys = pokemonNamesAndNumbersMapOne.keys.toList();
    final mapTwoKeys = pokemonNamesAndNumbersMapTwo.keys.toList();
    mapOneKeys.map((key) => mapTwoKeys[key]);

    for (final key in mapOneKeys) {
      pokemonNamesAndNumbersAfterAnding[key] =
          pokemonNamesAndNumbersMapOne[key]!;
    }

    return pokemonNamesAndNumbersAfterAnding;
  }

  @override
  List getResultsMap(Map decodedResponse) {
    return decodedResponse['results'] ??
        decodedResponse['pokemon_species'] ??
        decodedResponse['pokemon'] ??
        decodedResponse['pokemon_entries'];
  }

  @override
  void applySort(Map<int, String> pokemonNamesAndNumbers, Sort sortBy) {
    final keys = pokemonNamesAndNumbers.keys.toList();
    final values = pokemonNamesAndNumbers.values.toList();
    if (sortBy == Sort.idAscending || sortBy == Sort.idDescending) {
      if (sortBy == Sort.idAscending) {
        for (int i = 1; i < keys.length; i++) {
          if (keys[i - 1].compareTo(keys[i]) > 0) {
            final tempOne = keys[i - 1];
            keys[i - 1] = keys[i];
            keys[i] = tempOne;
            final tempTwo = values[i - 1];
            values[i - 1] = values[i];
            values[i] = tempTwo;
          }
        }
      } else {
        for (int i = 1; i < keys.length; i++) {
          if (keys[i - 1].compareTo(keys[i]) < 0) {
            final tempOne = keys[i - 1];
            keys[i - 1] = keys[i];
            keys[i] = tempOne;
            final tempTwo = values[i - 1];
            values[i - 1] = values[i];
            values[i] = tempTwo;
          }
        }
      }
    } else {
      if (sortBy == Sort.nameAscending) {
        for (int i = 1; i < values.length; i++) {
          if (values[i - 1].compareTo(values[i]) > 0) {
            final tempOne = values[i - 1];
            values[i - 1] = values[i];
            values[i] = tempOne;
            final tempTwo = keys[i - 1];
            keys[i - 1] = keys[i];
            keys[i] = tempTwo;
          }
        }
      } else {
        for (int i = 1; i < values.length; i++) {
          if (values[i - 1].compareTo(values[i]) < 0) {
            final tempOne = values[i - 1];
            values[i - 1] = values[i];
            values[i] = tempOne;
            final tempTwo = keys[i - 1];
            keys[i - 1] = keys[i];
            keys[i] = tempTwo;
          }
        }
      }
    }
    Map<int, String> pokemonNamesAndNumbersTemp = {};
    for (int i = 0; i < keys.length; i++) {
      pokemonNamesAndNumbersTemp[keys[i]] = values[i];
    }
    pokemonNamesAndNumbers = pokemonNamesAndNumbersTemp;
  }

  @override
  Future<Map<int, String>> loadPokemonNamesAndIdsAfterFilters(
      String color,
      String type,
      String habitat,
      String pokedex,
      String searchValue,
      Sort sortBy) async {
    // setState(() {
    //   _isGettingPokemon = true;
    // });
    // try {
    final List<Uri> urls = getFilterUrls(color, type, habitat, pokedex);
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
    var pokemonNamesAndNumbersOne =
        fillPokemonNamesAndIds(getResultsMap(decodedResponse));
    for (int i = 1; i < urls.length; i++) {
      var response = await http.get(urls[i]);
      var decodedResponse = json.decode(response.body);
      final pokemonNamesAndNumbersTwo =
          fillPokemonNamesAndIds(getResultsMap(decodedResponse));
      pokemonNamesAndNumbersOne = andPokemonNamesAndNumbersMaps(
          pokemonNamesAndNumbersOne, pokemonNamesAndNumbersTwo);
    }
    if (searchValue.isNotEmpty) {
      final keys = pokemonNamesAndNumbersOne.keys.toList();
      for (int i = 0; i < keys.length; i++) {
        final pokemonName = pokemonNamesAndNumbersOne[keys[i]];
        if (!pokemonName!.contains(searchValue)) {
          pokemonNamesAndNumbersOne.remove(keys[i]);
          i--;
        }
      }
    }
    applySort(pokemonNamesAndNumbersOne, sortBy);
    //   if (mounted) {
    //     setState(() {
    //       _isGettingPokemon = false;
    //     });
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     setState(() {
    //       _errorGettingPokemon = true;
    //       _isGettingPokemon = false;
    //     });
    //   }
    // }
    return pokemonNamesAndNumbersOne;
  }

  @override
  Future<Map<int, String>> loadPokemon() async {
    // setState(() {
    //   _isGettingPokemon = true;
    // });
    // try {
    final Uri url = Uri.https(
      'pokeapi.co',
      'api/v2/pokemon-species',
      {'limit': '100000', 'offset': '0', 'queryParamWithQuestionMark': '?'},
    );
    var response = await http.get(url);
    var decodedResponse = json.decode(response.body);
    var pokemonNamesAndNumbers =
        fillPokemonNamesAndIds(getResultsMap(decodedResponse));
    applySort(pokemonNamesAndNumbers, Sort.idAscending);
    //   if (mounted) {
    //     setState(() {
    //       _isGettingPokemon = false;
    //     });
    //   }
    // } catch (e) {
    //   if (mounted) {
    //     setState(() {
    //       _errorGettingPokemon = true;
    //       _isGettingPokemon = false;
    //     });
    //   }
    // }
    return pokemonNamesAndNumbers;
  }

  @override
  String getRandomFlavourText(Map pokemonSpecies) {
    final List flavorTextEntries = pokemonSpecies['flavor_text_entries'];
    final int randomIndex = Random().nextInt(flavorTextEntries.length);
    Map randomMap = flavorTextEntries[randomIndex];
    String randomFlavorText = randomMap['flavor_text'].replaceAll('\n', ' ');
    return randomFlavorText;
  }

  @override
  String getPokemonTypes(Map pokemon) {
    List types = pokemon['types'];
    var typesResult = '';
    for (final type in types) {
      typesResult += ', ${type['type']['name']}';
    }
    typesResult = typesResult.substring(2);
    return typesResult;
  }

  @override
  String getEggGroups(Map pokemonSpecies) {
    final List eggGroupList = pokemonSpecies['egg_groups'];
    var groups = '';
    for (final eggGroup in eggGroupList) {
      groups = '${groups + eggGroup['name']}, ';
    }
    groups = groups.substring(0, groups.length - 2);
    return groups;
  }

  @override
  List<Ability> getAbilities(Map pokemon) {
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

  @override
  List<Move> getMoves(Map pokemon) {
    final List movesMap = pokemon['moves'];
    if (movesMap.isEmpty) return [];
    List<Move> moves = [];

    for (final moveMap in movesMap) {
      // list.add(
      //     {move['version_group_details'][i]['version_group']['name']: false});
      // list.add({
      //   move['version_group_details'][i]['level_learned_at'].toString(): false
      // });
      final name = moveMap['move']['name'];
      final learnMethod =
          moveMap['version_group_details'][0]['move_learn_method']['name'];
      final move = Move(name, learnMethod);
      moves.add(move);
    }

    return moves;
  }

  @override
  List<Stat> getStats(Map pokemon) {
    final List statsMap = pokemon['stats'];
    if (statsMap.isEmpty) return [];
    List<Stat> stats = [];

    for (final statMap in statsMap) {
      // list.add({stat['effort'].toString(): false});
      final name = statMap['stat']['name'];
      final base = statMap['base_stat'].toString();
      final stat = Stat(name, base);
      stats.add(stat);
    }

    return stats;
  }

  @override
  Future<Pokemon> createPokemon(String pokemonNameOrId, bool isForPokemonItem,
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
        pokemonSpecies == null ? '' : pokemonSpecies['varieties'];
    final List<List<Pokemon>> evoloutionChain =
        isVariety || isForPokemonItem || pokemonSpecies == null
            ? []
            : await getEvoloutionChain(evoloutionChainUrl);
    final List<Pokemon> varieties =
        isVariety || isForPokemonItem || pokemonSpecies == null
            ? []
            : await getVarieties(varietiesMap, color);
    final String flavourText =
        pokemonSpecies == null ? '' : getRandomFlavourText(pokemonSpecies);
    final String type = getPokemonTypes(pokemon);
    final String generation = pokemonSpecies == null
        ? ''
        : pokemonSpecies['generation'] != null
            ? pokemonSpecies['generation']['name']
            : 'null';
    final String eggGroup = pokemonSpecies == null
        ? ''
        : pokemonSpecies['egg_groups'] != null &&
                pokemonSpecies['egg_groups'].isNotEmpty
            ? getEggGroups(pokemonSpecies)
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
    final List<Ability> abilities = getAbilities(pokemon);
    final List<Move> moves = getMoves(pokemon);
    final List<Stat> stats = getStats(pokemon);

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
