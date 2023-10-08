import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PokemonTable extends StatefulWidget {
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
  State<PokemonTable> createState() => _PokemonTableState();
}

class _PokemonTableState extends State<PokemonTable> {
  var _showTable = false;
  @override
  Widget build(BuildContext context) {
    //todo fix the wide table
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.tableName,
              style: GoogleFonts.sedgwickAveDisplay(
                color: widget.pokemonColor,
                fontSize: 30,
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _showTable = !_showTable;
              }),
              icon: Icon(
                _showTable ? Icons.arrow_drop_down : Icons.arrow_right,
                color: widget.pokemonColor,
                // size: 50,
              ),
            )
          ],
        ),
        if (_showTable)
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
                for (int i = 0; i < widget.entries.length; i++)
                  TableRow(
                    children: [
                      for (final map in widget.entries[i])
                        for (final entry in map.keys.toList())
                          TableCell(
                            child: _PokemonTableCellContainer(
                              color: i % 2 == 0
                                  ? widget.pokemonColor.withOpacity(0.2)
                                  : widget.pokemonColor.withOpacity(0.8),
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
