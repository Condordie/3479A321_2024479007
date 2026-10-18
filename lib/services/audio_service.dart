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
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setPlayerMode(PlayerMode.lowLatency);
      _isInitialized = true;
      AppLogger.info('AudioService inicializado en modo Low Latency');
    } catch (e, st) {
      AppLogger.error('Fallo en la inicialización del AudioService', e, st);
    }
  }

  Future<void> _play(String assetPath) async {
    if (!_isInitialized) {
      AppLogger.warning('AudioService no inicializado; se omite $assetPath');
      return;
    }
    try {
      await _player.play(AssetSource(assetPath));
      AppLogger.info('Reproduciendo $assetPath con éxito');
    } catch (e, st) {
      AppLogger.error('No se pudo reproducir $assetPath', e, st);
    }
  }

  Future<void> playSelect() => _play('audio/selection.wav');
  Future<void> playJump() => _play('audio/jump.wav');
  Future<void> playGameOver() => _play('audio/final.wav');

  void dispose() {
    _player.dispose();
  }
}