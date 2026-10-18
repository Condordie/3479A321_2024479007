import 'package:untitled/models/game_record.dart';
import 'package:untitled/repositories/game_history_repository.dart';

class FakeGameHistoryRepository implements IGameHistoryRepository {
  final List<GameRecord> _storage = [];

  List<GameRecord> get memoryRecords => List.unmodifiable(_storage);

  @override
  Future<List<GameRecord>> getHistory() async => List.from(_storage);

  @override
  Future<void> saveGame(GameRecord record) async => _storage.insert(0, record);

  @override
  Future<void> clearHistory() async => _storage.clear();
}