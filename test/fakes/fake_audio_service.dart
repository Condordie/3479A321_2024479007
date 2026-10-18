import 'package:untitled/services/audio_service.dart';

class FakeAudioService implements AudioService {
  int playSelectCount = 0;
  int playJumpCount = 0;
  int playGameOverCount = 0;

  @override
  Future<void> playSelect() async => playSelectCount++;

  @override
  Future<void> playJump() async => playJumpCount++;

  @override
  Future<void> playGameOver() async => playGameOverCount++;

  @override
  void dispose() {}
}