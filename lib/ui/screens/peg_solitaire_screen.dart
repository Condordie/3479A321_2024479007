import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:untitled/core/enums/cell_type.dart';
import 'package:untitled/models/board_position.dart';
import 'package:untitled/ui/screens/rules_screen.dart';
import 'package:untitled/ui/widgets/peg_cell.dart';
import 'package:untitled/services/shake_detector_service.dart';
import 'package:untitled/viewmodels/peg_solitaire_viewmodel.dart';

class PegSolitaireScreen extends StatefulWidget {
  const PegSolitaireScreen({super.key});

  @override
  State<PegSolitaireScreen> createState() => _PegSolitaireScreenState();
}

class _PegSolitaireScreenState extends State<PegSolitaireScreen> {
  static final Logger _logger = Logger();

  ShakeDetectorService? _shakeDetector;

  @override
  void initState() {
    super.initState();
    // Inicialización del detector de agitación
    _shakeDetector = ShakeDetectorService(
      onShake: _handleShakeEvent,
    );
    _shakeDetector?.startListening();
  }

  void _handleShakeEvent() {
    final vm = context.read<PegSolitaireViewModel>();

    // REGLA DE NEGOCIO: Solo actuar si la partida ha terminado
    if (vm.isGameOver) {
      _logger.i(
          'Shake validado: Partida finalizada. Reiniciando tablero automáticamente.');
      vm.initializeBoard();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Tablero reiniciado por movimiento físico!'),
          duration: Duration(seconds: 5),
        ),
      );
    } else {
      _logger.d('Shake ignorado: La partida se encuentra activa.');
    }
  }

  @override
  void dispose() {
    // Liberación estricta para evitar fugas de memoria al salir de la pantalla
    _shakeDetector?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // watch: se suscribe al ViewModel y redibuja cuando este notifica cambios
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
            // read: solo despacha una acción, no se suscribe
            onPressed: () => context.read<PegSolitaireViewModel>().initializeBoard(),
          ),
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
            // Área de status
            _buildScoreBoard(context, vm),
            const Divider(height: 1),
            // Área de juego
            Expanded(
              child: _gameBoard(context, vm),
            ),
            // Mensaje de finalización
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
    _logger.i('Construyendo el tablero de juego');
    // Destinos válidos calculados una sola vez por redibujado
    final validDestinations = vm.getValidDestinations();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 1.0, // Cuadrado perfecto
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // Bloquea el scroll
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: PegSolitaireViewModel.gridSize, // 7 columnas
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
            ),
            itemCount:
                PegSolitaireViewModel.gridSize * PegSolitaireViewModel.gridSize, // 49 celdas
            itemBuilder: (context, index) {
              // Convertir el índice en coordenadas matriciales
              final int row = index ~/ PegSolitaireViewModel.gridSize;
              final int col = index % PegSolitaireViewModel.gridSize;
              final position = BoardPosition(row, col);
              final CellType cellType = vm.getCellType(row, col);

              return PegCell(
                position: position,
                cellType: cellType,
                isSelected: vm.isCellSelected(position), // estado reactivo
                isValidDestination: validDestinations.contains(position),
                onTap: () => context.read<PegSolitaireViewModel>().onCellTapped(position),
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
        ],
      ),
    );
  }
}