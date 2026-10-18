import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/core/enums/cell_type.dart';
import 'package:untitled/core/enums/move_result.dart';
import 'package:untitled/models/board_position.dart';
import 'package:untitled/viewmodels/peg_solitaire_viewmodel.dart';

import '../fakes/fake_audio_service.dart';
import '../fakes/fake_game_history_repository.dart';
import '../fakes/fake_preferences_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PegSolitaireViewModel viewModel;
  late FakeGameHistoryRepository fakeRepo;
  late FakePreferencesService fakePrefs;
  late FakeAudioService fakeAudio;

  setUp(() {
    fakeRepo = FakeGameHistoryRepository();
    fakePrefs = FakePreferencesService();
    fakeAudio = FakeAudioService();
    viewModel = PegSolitaireViewModel(
      historyRepository: fakeRepo,
      preferencesService: fakePrefs,
      audioService: fakeAudio,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('PegSolitaireViewModel - Pruebas Unitarias del Motor Lógico', () {
    test('TC-01: Ejecuta salto ortogonal válido y remueve atómicamente la clavija intermedia', () {
      const from = BoardPosition(1, 3);
      const jumped = BoardPosition(2, 3);
      const to = BoardPosition(3, 3);

      expect(viewModel.cellTypeAt(from), CellType.occupiedPeg);
      expect(viewModel.cellTypeAt(jumped), CellType.occupiedPeg);
      expect(viewModel.cellTypeAt(to), CellType.emptyHole);

      viewModel.onCellTapped(from);
      expect(viewModel.selectedPosition, from);
      expect(fakeAudio.playSelectCount, 1);

      viewModel.onCellTapped(to);

      expect(viewModel.cellTypeAt(from), CellType.emptyHole,
          reason: 'El origen debe quedar vacío');
      expect(viewModel.cellTypeAt(jumped), CellType.emptyHole,
          reason: 'La clavija saltada debe ser removida');
      expect(viewModel.cellTypeAt(to), CellType.occupiedPeg,
          reason: 'El destino debe alojar la clavija');
      expect(viewModel.selectedPosition, isNull,
          reason: 'La FSM debe retornar a estado IDLE');
      expect(fakeAudio.playJumpCount, 1,
          reason: 'Debe emitirse el sonido de salto');
    });

    test('TC-02: Rechaza categóricamente saltos diagonales y preserva invariantes', () {
      // (2,2) -> (3,3): diagonal hacia el único hueco vacío del tablero inicial
      const from = BoardPosition(2, 2);
      const invalidDiagonal = BoardPosition(3, 3);

      viewModel.onCellTapped(from);
      final result = viewModel.onCellTapped(invalidDiagonal);

      expect(result, MoveResult.invalid);
      expect(viewModel.remainingPegs, 32);
      expect(viewModel.moveCount, 0);
      expect(viewModel.cellTypeAt(from), CellType.occupiedPeg);
      expect(viewModel.cellTypeAt(invalidDiagonal), CellType.emptyHole);
      expect(viewModel.selectedPosition, from,
          reason: 'Mantiene la selección ante destino inválido');
    });

    test('TC-03: Rechaza desplazamientos simples de distancia 1 hacia hueco vacío', () {
      const from = BoardPosition(3, 2);
      const adjacentHole = BoardPosition(3, 3);

      viewModel.onCellTapped(from);
      final result = viewModel.onCellTapped(adjacentHole);

      expect(result, MoveResult.invalid);
      expect(viewModel.remainingPegs, 32);
      expect(viewModel.moveCount, 0);
      expect(viewModel.cellTypeAt(from), CellType.occupiedPeg);
    });

    test('TC-04: Mantiene la consistencia de los contadores de piezas y turnos jugados', () {
      const from = BoardPosition(1, 3);
      const to = BoardPosition(3, 3);

      expect(viewModel.remainingPegs, 32);
      expect(viewModel.moveCount, 0);

      viewModel.onCellTapped(from);
      viewModel.onCellTapped(to);

      expect(viewModel.remainingPegs, 31,
          reason: 'Debe decrementar exactamente 1 clavija');
      expect(viewModel.moveCount, 1,
          reason: 'Debe incrementar exactamente 1 turno');
    });

    test('TC-05: Estado inicial coherente con tablero inglés estándar', () {
      expect(viewModel.isGameOver, isFalse);
      expect(viewModel.isVictory, isFalse);
      expect(viewModel.remainingPegs, 32);
      expect(viewModel.moveCount, 0);
      expect(viewModel.selectedPosition, isNull);
    });

    test('TC-06: Un salto válido retorna MoveResult.jumped y seleccionar retorna selected', () {
      expect(viewModel.onCellTapped(const BoardPosition(1, 3)), MoveResult.selected);
      expect(viewModel.onCellTapped(const BoardPosition(3, 3)), MoveResult.jumped);
    });

    test('TC-07: Tocar la misma clavija dos veces deselecciona sin sonido de salto', () {
      const pos = BoardPosition(1, 3);

      viewModel.onCellTapped(pos);
      final result = viewModel.onCellTapped(pos);

      expect(result, MoveResult.deselected);
      expect(viewModel.selectedPosition, isNull);
      expect(fakeAudio.playJumpCount, 0);
    });

    test('TC-08: Deshacer restaura el tablero, los contadores y el historial de la jugada', () {
      const from = BoardPosition(1, 3);
      const jumped = BoardPosition(2, 3);
      const to = BoardPosition(3, 3);

      viewModel.onCellTapped(from);
      viewModel.onCellTapped(to);
      expect(viewModel.canUndo, isTrue);

      viewModel.undoMove();

      expect(viewModel.cellTypeAt(from), CellType.occupiedPeg);
      expect(viewModel.cellTypeAt(jumped), CellType.occupiedPeg);
      expect(viewModel.cellTypeAt(to), CellType.emptyHole);
      expect(viewModel.remainingPegs, 32);
      expect(viewModel.moveCount, 0);
      expect(viewModel.canUndo, isFalse);
    });

    test('TC-09: Con el sonido desactivado en preferencias no se emiten sonidos', () async {
      await fakePrefs.setSoundEnabled(false);

      viewModel.onCellTapped(const BoardPosition(1, 3));
      viewModel.onCellTapped(const BoardPosition(3, 3));

      expect(fakeAudio.playSelectCount, 0);
      expect(fakeAudio.playJumpCount, 0);
    });
  });
}