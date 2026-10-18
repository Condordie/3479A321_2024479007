import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled/core/enums/cell_type.dart';
import 'package:untitled/core/enums/move_result.dart';
import 'package:untitled/core/utils/app_logger.dart';
import 'package:untitled/models/board_position.dart';
import 'package:untitled/services/preferences_service.dart';
import 'package:untitled/services/screenshot_service.dart';
import 'package:untitled/services/shake_detector_service.dart';
import 'package:untitled/ui/screens/rules_screen.dart';
import 'package:untitled/ui/widgets/peg_cell.dart';
import 'package:untitled/viewmodels/peg_solitaire_viewmodel.dart';

class PegSolitaireScreen extends StatefulWidget {
  const PegSolitaireScreen({super.key});

  @override
  State<PegSolitaireScreen> createState() => _PegSolitaireScreenState();
}

class _PegSolitaireScreenState extends State<PegSolitaireScreen> {
  /// Llave global que identifica la capa de pintado del tablero.
  final GlobalKey _boardBoundaryKey = GlobalKey();

  ShakeDetectorService? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetectorService(onShake: _handleShakeEvent);
    _shakeDetector?.startListening();
  }

  void _handleShakeEvent() {
    if (!mounted) return;
    final vm = context.read<PegSolitaireViewModel>();

    if (vm.isGameOver) {
      AppLogger.info(
          'Shake validado: Partida finalizada. Reiniciando tablero automáticamente.');
      vm.initializeBoard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Tablero reiniciado por movimiento físico!'),
          duration: Duration(seconds: 5),
        ),
      );
    } else {
      AppLogger.debug('Shake ignorado: La partida se encuentra activa.');
    }
  }

  @override
  void dispose() {
    _shakeDetector?.dispose();
    super.dispose();
  }

  /// Despacha el toque al ViewModel y emite háptica según el resultado.
  void _onCellTapped(BuildContext context, BoardPosition position) {
    final vm = context.read<PegSolitaireViewModel>();
    final prefs = context.read<PreferencesService>();

    final MoveResult result = vm.onCellTapped(position);
    if (!prefs.isVibrationEnabled) return;

    switch (result) {
      case MoveResult.selected:
        HapticFeedback.lightImpact();
        break;
      case MoveResult.jumped:
        HapticFeedback.mediumImpact();
        break;
      case MoveResult.gameOver:
        HapticFeedback.heavyImpact();
        break;
      case MoveResult.deselected:
      case MoveResult.invalid:
      case MoveResult.ignored:
        break; // Sin vibración "a ciegas" en acciones inválidas
    }
  }

  Future<void> _shareResult(PegSolitaireViewModel vm) async {
    final String message =
        '¡He completado una partida de Peg Solitaire en ${vm.moveCount} movimientos dejando solo ${vm.remainingPegs} piezas!';

    final String? imagePath =
        await ScreenshotService.captureWidgetToImage(_boardBoundaryKey);
    if (imagePath == null) {
      AppLogger.warning('Se comparte solo texto: no hubo captura del tablero');
    }

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        files: imagePath != null ? [XFile(imagePath)] : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PegSolitaireViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solitario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Deshacer movimiento',
            onPressed: vm.canUndo
                ? () => context.read<PegSolitaireViewModel>().undoMove()
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reiniciar Tablero',
            onPressed: () => context.read<PegSolitaireViewModel>().initializeBoard(),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Reglas del juego',
            onPressed: () {
              AppLogger.info('Navegando a RulesScreen desde PegSolitaireScreen');
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
            _buildScoreBoard(context, vm),
            const Divider(height: 1),
            Expanded(
              // Capa de pintado aislada: solo el tablero se captura como imagen
              child: RepaintBoundary(
                key: _boardBoundaryKey,
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: _gameBoard(context, vm),
                ),
              ),
            ),
            if (vm.isGameOver) _buildGameOverBanner(context, vm),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBoard(BuildContext context, PegSolitaireViewModel vm) {
    return Container(
      height: 60,
      color: Colors.grey[300],
      child: Center(
        child: Text(
          'Piezas restantes: ${vm.remainingPegs} | Movimientos: ${vm.moveCount}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _gameBoard(BuildContext context, PegSolitaireViewModel vm) {
    final validDestinations = vm.getValidDestinations();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: PegSolitaireViewModel.gridSize,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
            ),
            itemCount:
                PegSolitaireViewModel.gridSize * PegSolitaireViewModel.gridSize,
            itemBuilder: (context, index) {
              final int row = index ~/ PegSolitaireViewModel.gridSize;
              final int col = index % PegSolitaireViewModel.gridSize;
              final position = BoardPosition(row, col);
              final CellType cellType = vm.getCellType(row, col);

              return PegCell(
                position: position,
                cellType: cellType,
                isSelected: vm.isCellSelected(position),
                isValidDestination: validDestinations.contains(position),
                onTap: () => _onCellTapped(context, position),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverBanner(BuildContext context, PegSolitaireViewModel vm) {
    final theme = Theme.of(context);
    final bool isVictory = vm.isVictory;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: isVictory ? Colors.green[100] : theme.colorScheme.errorContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isVictory ? '¡Victoria!' : 'Fin del juego: sin movimientos válidos',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Movimientos: ${vm.moveCount} | Piezas restantes: ${vm.remainingPegs}'),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Jugar de nuevo'),
            onPressed: () => context.read<PegSolitaireViewModel>().initializeBoard(),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.share_rounded),
            label: const Text('Compartir resultado'),
            onPressed: () => _shareResult(vm),
          ),
        ],
      ),
    );
  }
}