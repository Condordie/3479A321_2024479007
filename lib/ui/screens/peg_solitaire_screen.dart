import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:untitled/core/enums/cell_type.dart';
import 'package:untitled/ui/screens/RulesScreen.dart';

class PegSolitaireScreen extends StatelessWidget {
  const PegSolitaireScreen({Key? key}) : super(key: key);
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

class PegCell extends StatelessWidget {
  final int row;
  final int col;
  final CellType type;
  final bool isSelected;
  final VoidCallback? onTap;

  const PegCell({
    super.key,
    required this.row,
    required this.col,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        border: Border.all(color: Colors.grey[600]!, width: 1.5),
      ),
      child: Center(
        child: type == CellType.occupiedPeg
            ? Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Image.asset('assets/icons/icono.jpg'),
              )
            : type == CellType.emptyHole
                ? Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
      ),
    );
  }
}