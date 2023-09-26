import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PokemonTable extends StatelessWidget {
  const PokemonTable({
    super.key,
    required this.entries,
    required this.pokemonColor,
    required this.tableName,
  });

  final List<List<Map<String, bool>>> entries;
  final Color pokemonColor;
  final String tableName;

  @override
  Widget build(BuildContext context) {
    //todo fix the wide table
    return Column(
      children: [
        Text(
          tableName,
          style: GoogleFonts.sedgwickAveDisplay(
            color: pokemonColor,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            border: TableBorder.all(),
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FlexColumnWidth(),
              2: FixedColumnWidth(double.minPositive),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (int i = 0; i < entries.length; i++)
                TableRow(
                  children: [
                    for (final map in entries[i])
                      for (final entry in map.keys.toList())
                        TableCell(
                          child: _PokemonTableCellContainer(
                            color: i % 2 == 0
                                ? pokemonColor.withOpacity(0.2)
                                : pokemonColor.withOpacity(0.8),
                            isKey: map[entry]!,
                            entry: entry,
                          ),
                        ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PokemonTableCellContainer extends StatelessWidget {
  const _PokemonTableCellContainer({
    required this.color,
    required this.isKey,
    required this.entry,
  });

  final Color color;
  final bool isKey;
  final String entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16.0),
          child: Text(
            entry,
            textAlign: TextAlign.center,
            style: GoogleFonts.handlee(
              fontSize: 15,
              fontWeight: isKey ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
