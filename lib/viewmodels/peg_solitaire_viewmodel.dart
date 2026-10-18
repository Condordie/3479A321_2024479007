import 'package:flutter/foundation.dart';
import 'package:untitled/core/enums/cell_type.dart';
import 'package:untitled/core/enums/move_result.dart';
import 'package:untitled/core/utils/app_logger.dart';
import 'package:untitled/models/board_position.dart';
import 'package:untitled/models/game_record.dart';
import 'package:untitled/models/move_record.dart';
import 'package:untitled/repositories/game_history_repository.dart';
import 'package:untitled/services/audio_service.dart';
import 'package:untitled/services/preferences_service.dart';

class PegSolitaireViewModel extends ChangeNotifier {
  static const int gridSize = 7;

  late List<List<CellType>> _board;
  BoardPosition? _selectedPosition;
  int _remainingPegs = 0;
  int _moveCount = 0;
  bool _isGameOver = false;
  bool _isVictory = false;

  final List<List<List<CellType>>> _history = [];

  final IGameHistoryRepository _historyRepository;
  final PreferencesService _preferencesService;
  final AudioService? _audioService;
  final List<MoveRecord> _movesHistory = [];

  PegSolitaireViewModel({
    required this._historyRepository,
    required this._preferencesService,
    this._audioService,
  }) {
    initializeBoard();
  }

  List<List<CellType>> get board => _board;
  BoardPosition? get selectedPosition => _selectedPosition;
  int get remainingPegs => _remainingPegs;
  int get moveCount => _moveCount;
  bool get isGameOver => _isGameOver;
  bool get isVictory => _isVictory;
  bool get canUndo => _history.isNotEmpty;

  void initializeBoard() {
    _board = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) {
        if ((row < 2 || row > 4) && (col < 2 || col > 4)) {
          return CellType.voidCell;
        }
        if (row == 3 && col == 3) {
          return CellType.emptyHole;
        }
        return CellType.occupiedPeg;
      });
    });
    _selectedPosition = null;
    _history.clear();
    _movesHistory.clear();
    _remainingPegs = 32;
    _moveCount = 0;
    _isGameOver = false;
    _isVictory = false;
    notifyListeners();
  }

  CellType getCellType(int row, int col) {
    if (row < 0 || row >= gridSize || col < 0 || col >= gridSize) {
      return CellType.voidCell;
    }
    return _board[row][col];
  }

  /// Variante tipada por posición (útil para las pruebas unitarias).
  CellType cellTypeAt(BoardPosition pos) => getCellType(pos.row, pos.col);

  bool isCellSelected(BoardPosition pos) => _selectedPosition == pos;

  /// Reproduce un sonido solo si hay servicio inyectado y el usuario lo permite.
  void _playSound(void Function(AudioService audio) play) {
    final audio = _audioService;
    if (audio == null || !_preferencesService.isSoundEnabled) return;
    play(audio);
  }

  List<BoardPosition> getValidDestinations() {
    final BoardPosition? origin = _selectedPosition;
    if (origin == null) return [];

    const List<List<int>> directions = [
      [-2, 0],
      [2, 0],
      [0, -2],
      [0, 2],
    ];

    final List<BoardPosition> destinations = [];
    for (final dir in directions) {
      final int r = origin.row + dir[0];
      final int c = origin.col + dir[1];
      if (r >= 0 && r < gridSize && c >= 0 && c < gridSize) {
        final to = BoardPosition(r, c);
        if (_board[r][c] != CellType.voidCell && _isValidMove(origin, to)) {
          destinations.add(to);
        }
      }
    }
    return destinations;
  }

  /// FSM de interacción: IDLE <-> SOURCE_SELECTED.
  /// Retorna qué ocurrió para que la UI pueda dar retroalimentación háptica.
  MoveResult onCellTapped(BoardPosition pos) {
    if (_isGameOver) return MoveResult.ignored;

    final CellType tappedType = _board[pos.row][pos.col];
    if (tappedType == CellType.voidCell) return MoveResult.ignored;

    // ESTADO 0: IDLE
    if (_selectedPosition == null) {
      if (tappedType == CellType.occupiedPeg) {
        _selectedPosition = pos;
        _playSound((a) => a.playSelect());
        notifyListeners();
        return MoveResult.selected;
      }
      return MoveResult.ignored;
    }

    // ESTADO 1: SOURCE_SELECTED
    final BoardPosition origin = _selectedPosition!;

    if (origin == pos) {
      _selectedPosition = null;
      notifyListeners();
      return MoveResult.deselected;
    }

    if (tappedType == CellType.occupiedPeg) {
      _selectedPosition = pos;
      _playSound((a) => a.playSelect());
      notifyListeners();
      return MoveResult.selected;
    }

    if (tappedType == CellType.emptyHole) {
      if (_isValidMove(origin, pos)) {
        _executeMove(origin, pos);
        _selectedPosition = null;
        _evaluateGameTermination();

        final MoveResult result;
        if (_isGameOver) {
          _playSound((a) => a.playGameOver());
          _persistCompletedGame();
          result = MoveResult.gameOver;
        } else {
          _playSound((a) => a.playJump());
          result = MoveResult.jumped;
        }
        notifyListeners();
        return result;
      } else {
        AppLogger.warning(
            'Reglas: intento de salto inválido rechazado desde $origin hacia $pos');
        return MoveResult.invalid;
      }
    }
    return MoveResult.ignored;
  }

  void undoMove() {
    if (_history.isEmpty) return;
    _board = _history.removeLast();
    _remainingPegs++;
    _moveCount--;
    if (_movesHistory.isNotEmpty) {
      _movesHistory.removeLast();
    }
    _selectedPosition = null;
    _isGameOver = false;
    _isVictory = false;
    AppLogger.info('Movimiento deshecho | Clavijas restantes: $_remainingPegs');
    notifyListeners();
  }

  bool _isValidMove(BoardPosition from, BoardPosition to) {
    final int rowDelta = (from.row - to.row).abs();
    final int colDelta = (from.col - to.col).abs();

    final bool isOrthogonalTwoStep =
        (rowDelta == 2 && colDelta == 0) || (rowDelta == 0 && colDelta == 2);
    if (!isOrthogonalTwoStep) return false;

    if (_board[to.row][to.col] != CellType.emptyHole) return false;

    final int midRow = (from.row + to.row) ~/ 2;
    final int midCol = (from.col + to.col) ~/ 2;
    if (_board[midRow][midCol] != CellType.occupiedPeg) return false;

    return true;
  }

  void _executeMove(BoardPosition from, BoardPosition to) {
    _history.add(_board.map((row) => List<CellType>.from(row)).toList());

    final int midRow = (from.row + to.row) ~/ 2;
    final int midCol = (from.col + to.col) ~/ 2;

    _board[from.row][from.col] = CellType.emptyHole;
    _board[midRow][midCol] = CellType.emptyHole;
    _board[to.row][to.col] = CellType.occupiedPeg;
    _movesHistory.add(MoveRecord(
      from: from,
      to: to,
      timestamp: DateTime.now(),
    ));

    _remainingPegs--;
    _moveCount++;
    AppLogger.info(
        'Salto ejecutado con éxito: $from -> $to | Clavijas restantes: $_remainingPegs');
  }

  void _evaluateGameTermination() {
    if (_remainingPegs == 1) {
      _isGameOver = true;
      _isVictory = true;
      AppLogger.info('¡VICTORIA! Partida completada en $_moveCount movimientos.');
      return;
    }

    if (!_hasValidMovesRemaining()) {
      _isGameOver = true;
      _isVictory = false;
      AppLogger.warning('Fin de juego por bloqueo. No existen movimientos válidos.');
    }
  }

  bool _hasValidMovesRemaining() {
    const List<List<int>> directions = [
      [-2, 0],
      [2, 0],
      [0, -2],
      [0, 2],
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

  Future<void> _persistCompletedGame() async {
    final record = GameRecord(
      id: 'REC-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      remainingPegs: _remainingPegs,
      totalMoves: _moveCount,
      durationSeconds: 0,
      isVictory: _isVictory,
      moves: List.unmodifiable(_movesHistory),
    );

    try {
      await _historyRepository.saveGame(record);
      await _preferencesService.checkAndSaveRecord(_remainingPegs);
    } catch (e, st) {
      AppLogger.error('Error al guardar resumen en ViewModel', e, st);
    }
  }
}