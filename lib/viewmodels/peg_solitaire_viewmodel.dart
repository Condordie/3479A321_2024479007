import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:untitled/core/enums/cell_type.dart';
import 'package:untitled/models/board_position.dart';

class PegSolitaireViewModel extends ChangeNotifier {
  static const int gridSize = 7;
  static final Logger _logger = Logger();

  // Estado interno matricial y contadores
  late List<List<CellType>> _board;
  BoardPosition? _selectedPosition;
  int _remainingPegs = 0;
  int _moveCount = 0;
  bool _isGameOver = false;
  bool _isVictory = false;

  // Getters expuestos hacia la UI
  List<List<CellType>> get board => _board;
  BoardPosition? get selectedPosition => _selectedPosition;
  int get remainingPegs => _remainingPegs;
  int get moveCount => _moveCount;
  bool get isGameOver => _isGameOver;
  bool get isVictory => _isVictory;

  PegSolitaireViewModel() {
    initializeBoard();
  }

  void initializeBoard() {
    _board = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        // Esquinas no jugables (bloques 2x2 en las cuatro esquinas)
        if ((row < 2 || row > 4) && (col < 2 || col > 4)) {
          return CellType.voidCell;
        }
        // Centro estándar desocupado (3, 3)
        if (row == 3 && col == 3) {
          return CellType.emptyHole;
        }
        return CellType.occupiedPeg;
      });
    });
    _selectedPosition = null;
    _remainingPegs = 32;
    _moveCount = 0;
    _isGameOver = false;
    _isVictory = false;
    notifyListeners();
  }

  /// Retorna el tipo de celda en una coordenada segura.
  CellType getCellType(int row, int col) {
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
      return CellType.voidCell;
    }
    return _board[row][col];
  }

  bool isCellSelected(BoardPosition pos) => _selectedPosition == pos;

  /// FSM de interacción: IDLE <-> SOURCE_SELECTED
  void onCellTapped(BoardPosition pos) {
    if (_isGameOver) return;

    final CellType tappedType = _board[pos.row][pos.col];
    if (tappedType == CellType.voidCell) return;

    // ESTADO 0: IDLE (no hay origen seleccionado)
    if (_selectedPosition == null) {
      if (tappedType == CellType.occupiedPeg) {
        _selectedPosition = pos;
        notifyListeners();
      }
      return;
    }

    // ESTADO 1: SOURCE_SELECTED (hay una clavija origen activa)
    final BoardPosition origin = _selectedPosition!;

    // Transición 1.1: misma casilla -> deselección
    if (origin == pos) {
      _selectedPosition = null;
      notifyListeners();
      return;
    }

    // Transición 1.2: otra clavija propia -> alternar selección
    if (tappedType == CellType.occupiedPeg) {
      _selectedPosition = pos;
      notifyListeners();
      return;
    }

    // Transición 1.3: hueco vacío -> evaluar salto y captura
    if (tappedType == CellType.emptyHole) {
      if (_isValidMove(origin, pos)) {
        _executeMove(origin, pos);
        _selectedPosition = null; // regreso automático a IDLE
        _evaluateGameTermination();
        notifyListeners();
      } else {
        _logger.w(
            'Reglas: intento de salto inválido rechazado desde $origin hacia $pos');
      }
    }
  }

  /// Ortogonalidad estricta: salto de exactamente 2 casillas en línea recta.
  bool _isValidMove(BoardPosition from, BoardPosition to) {
    final int rowDelta = (from.row - to.row).abs();
    final int colDelta = (from.col - to.col).abs();

    // 1. Salto ortogonal estricto de distancia 2
    final bool isOrthogonalTwoStep =
        (rowDelta == 2 && colDelta == 0) || (rowDelta == 0 && colDelta == 2);
    if (!isOrthogonalTwoStep) return false;

    // 2. El destino debe ser un hueco vacío
    if (_board[to.row][to.col] != CellType.emptyHole) return false;

    // 3. La celda intermedia debe tener una clavija a capturar
    final int midRow = (from.row + to.row) ~/ 2;
    final int midCol = (from.col + to.col) ~/ 2;
    if (_board[midRow][midCol] != CellType.occupiedPeg) return false;

    return true;
  }

  /// Mutación del tablero: mueve la clavija y captura la intermedia.
  void _executeMove(BoardPosition from, BoardPosition to) {
    final int midRow = (from.row + to.row) ~/ 2;
    final int midCol = (from.col + to.col) ~/ 2;

    _board[from.row][from.col] = CellType.emptyHole;
    _board[midRow][midCol] = CellType.emptyHole;
    _board[to.row][to.col] = CellType.occupiedPeg;

    _remainingPegs--;
    _moveCount++;
    _logger.i(
        'Salto ejecutado con éxito: $from -> $to | Clavijas restantes: $_remainingPegs');
  }

  /// Evalúa victoria (1 clavija) o estancamiento (sin saltos válidos).
  void _evaluateGameTermination() {
    // Victoria: queda exactamente 1 clavija
    if (_remainingPegs == 1) {
      _isGameOver = true;
      _isVictory = true;
      _logger.i('¡VICTORIA! Partida completada en $_moveCount movimientos.');
      return;
    }

    // Estancamiento: no quedan saltos válidos
    if (!_hasValidMovesRemaining()) {
      _isGameOver = true;
      _isVictory = false;
      _logger.w('Fin de juego por bloqueo. No existen movimientos válidos.');
    }
  }

  /// Recorre el tablero buscando al menos un salto válido.
  bool _hasValidMovesRemaining() {
    const List<List<int>> directions = [
      [-2, 0], // Arriba
      [2, 0], // Abajo
      [0, -2], // Izquierda
      [0, 2], // Derecha
    ];

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (_board[r][c] == CellType.occupiedPeg) {
          final from = BoardPosition(r, c);
          for (final dir in directions) {
            final int targetRow = r + dir[0];
            final int targetCol = c + dir[1];
            if (targetRow >= 0 &&
                targetRow < gridSize &&
                targetCol >= 0 &&
                targetCol < gridSize) {
              final to = BoardPosition(targetRow, targetCol);
              if (_board[targetRow][targetCol] != CellType.voidCell &&
                  _isValidMove(from, to)) {
                return true;
              }
            }
          }
        }
      }
    }
    return false;
  }
}