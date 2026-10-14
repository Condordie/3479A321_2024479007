import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/models/game_record.dart';
import 'package:untitled/repositories/game_history_repository.dart';

/// Implementación del repositorio respaldada en el sistema de archivos (JSON).
class JsonFileHistoryRepository implements IGameHistoryRepository {
  static const String _fileName = 'games_history.json';
  final Logger _logger = Logger();

  Future<File> _resolveLocalFile() async {
    // Resuelve la ruta segura en el sandbox de la aplicación (Documents Directory)
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  @override
  Future<List<GameRecord>> getHistory() async {
    try {
      final file = await _resolveLocalFile();
      if (!await file.exists()) {
        _logger.i('Historial inexistente en disco. Retornando colección vacía.');
        return [];
      }

      final String content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final List<dynamic> decodedList = jsonDecode(content) as List<dynamic>;
      return decodedList
          .map((item) => GameRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FileSystemException catch (e) {
      _logger.e('Error de bajo nivel en el sistema de archivos: ${e.message}');
      return [];
    } on FormatException catch (e) {
      _logger.e('Corrupción detectada en games_history.json: ${e.message}');
      return [];
    } catch (e) {
      _logger.e('Excepción no controlada al leer historial: $e');
      return [];
    }
  }

  @override
  Future<void> saveGame(GameRecord record) async {
    try {
      final file = await _resolveLocalFile();
      final List<GameRecord> currentList = await getHistory();

      // Inserción al inicio de la lista (orden cronológico descendente)
      currentList.insert(0, record);

      final String encoded =
          jsonEncode(currentList.map((g) => g.toJson()).toList());

      // Escritura atómica
      await file.writeAsString(encoded, mode: FileMode.write, flush: true);
      _logger.i('Partida ${record.id} persistida con éxito en disco.');
    } catch (e) {
      _logger.e('Fallo al persistir partida en archivo local: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearHistory() async {
    try {
      final file = await _resolveLocalFile();
      if (await file.exists()) {
        await file.delete();
        _logger.i('Archivo de historial purgado exitosamente.');
      }
    } catch (e) {
      _logger.e('Error al purgar historial: $e');
    }
  }
}