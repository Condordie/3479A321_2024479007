import 'package:audioplayers/audioplayers.dart';
import 'package:untitled/core/utils/app_logger.dart';
class AudioService {
  
  static final AudioService instance = AudioService._internal();
  
  late final AudioPlayer _player;
  bool _isInitialized = false;
  
  AudioService._internal() {
    _player = AudioPlayer();
    _configurePlayer();
  }
  Future<void> _configurePlayer() async {
    try {
      // Optimización: Modo de baja latencia para respuestas acústicas inmediatas
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);
      _isInitialized = true;
      AppLogger.info('AudioService inicializado en modo Low Latency');
    } catch (e) {
      AppLogger.error('Fallo en la inicialización del AudioService: $e');
    }
  }
  Future<void> playSelect() async {
    if (!_isInitialized) return;
    try {
      await _player.play(AssetSource('audio/selection.wav'));
    } catch (e) {
      AppLogger.warning('No se pudo reproducir selection.mp3: $e');
    }
  }
  Future<void> playJump() async {
    if (!_isInitialized) return;
    try {
    await _player.play(AssetSource('audio/jump.wav'));
    } catch (e) {
    AppLogger.warning('No se pudo reproducir jump.mp3: $e');
    }
  }
  Future<void> playGameOver() async {
    if (!_isInitialized) return;
    try {
    await _player.play(AssetSource('audio/final.wav'));
    } catch (e) {
    AppLogger.warning('No se pudo reproducir final.mp3: $e');
    }
  }
  void dispose() {
    _player.dispose();
  }
}
