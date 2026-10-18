import 'package:untitled/services/preferences_service.dart';

class FakePreferencesService implements PreferencesService {
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _bestRemainingPegs = 32;

  @override
  bool get isSoundEnabled => _soundEnabled;

  @override
  bool get isVibrationEnabled => _vibrationEnabled;

  @override
  int get bestRemainingPegs => _bestRemainingPegs;

  @override
  Future<bool> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    return true;
  }

  @override
  Future<bool> setVibrationEnabled(bool enabled) async {
    _vibrationEnabled = enabled;
    return true;
  }

  @override
  Future<bool> checkAndSaveRecord(int remainingPegs) async {
    if (remainingPegs < _bestRemainingPegs) {
      _bestRemainingPegs = remainingPegs;
      return true;
    }
    return false;
  }

  @override
  Future<bool> resetBestScore() async {
    _bestRemainingPegs = 32;
    return true;
  }
}