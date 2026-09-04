import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:untitled/core/enums/cell_type.dart';
import 'package:untitled/ui/screens/RulesScreen.dart';
import 'package:untitled/ui/widgets/peg_cell.dart';
import 'package:untitled/models/GameRecord.dart';

class PegSolitaireScreen extends StatelessWidget {
  PegSolitaireScreen({Key? key}) : super(key: key);
  
  // ignore: prefer_final_fields
  GameRecord _lastGameRecord = GameRecord(
    id: '1',
    date: DateTime.now(),
    remainingPegs: 33,
    totalMoves: 0,
    durationSeconds: 349,
    isVictory: false,
  );
  
  static const int gridSize = 7; // Tamaño del tablero (7x7)
  static const int totalCells = gridSize * gridSize; // Total de celdas (49)

  static final Logger _logger = Logger();// placeholder eliminado abajo

  CellType _getCellType(int row, int col) {
    final bool isCorner = (row < 2 || row > 4) && (col < 2 || col > 4);
    if (isCorner) return CellType.voidCell; // Casilla no jugable
    if (row == 3 && col == 3) return CellType.emptyHole; // Casilla jugable vacía
    return CellType.occupiedPeg; // Casilla jugable con clavija presente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solitario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Reglas del juego',
            onPressed: () {
              _logger.i('Navegando a RulesScreen desde PegSolitaireScreen');
              _logger.i('Último registro de juego: $_lastGameRecord');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RulesScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  'STATUS: 349 segundos | Piezas restantes: 33',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _gameBoard(), // <- antes era el Text('Tablero de Juego')
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameBoard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 1.0, // Cuadrado perfecto
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // Bloquea el scroll
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 columnas
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
            ),
            itemCount: 49, // 7x7 = 49 celdas
            itemBuilder: (context, index) {
              // Convertir el índice en coordenadas matriciales
              final int row = index ~/ gridSize;
              final int col = index % gridSize;
              final CellType cellType = _getCellType(row, col);

              return PegCell(
                row: row,
                col: col,
                type: cellType,
              );
            },
          ),
        ),
      ),
    );
  }
}
