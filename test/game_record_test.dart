//ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/models/board_position.dart';
import 'package:untitled/models/game_record.dart';
import 'package:untitled/models/move_record.dart';

void main() {
  test('MoveRecord: creación, toJson y fromJson', () {
    final move = MoveRecord(
      from: const BoardPosition(1, 3),
      to: const BoardPosition(3, 3),
      timestamp: DateTime(2026, 10, 14, 10, 30),
    );

    final json = move.toJson();
    
    print('MoveRecord toJson: $json');
    final restored = MoveRecord.fromJson(json);
    print('MoveRecord fromJson: $restored');

    expect(restored.from, move.from);
    expect(restored.to, move.to);
    expect(restored.timestamp, move.timestamp);
  });

  test('GameRecord: toJson y fromJson con lista de movimientos', () {
    final record = GameRecord(
      id: 'REC-TEST',
      date: DateTime(2026, 10, 14, 11, 0),
      remainingPegs: 1,
      totalMoves: 31,
      durationSeconds: 0,
      isVictory: true,
      moves: [
        MoveRecord(
          from: const BoardPosition(1, 3),
          to: const BoardPosition(3, 3),
          timestamp: DateTime(2026, 10, 14, 10, 30),
        ),
      ],
    );

    final encoded = jsonEncode(record.toJson());
    print('GameRecord JSON: $encoded');

    final restored =
        GameRecord.fromJson(jsonDecode(encoded) as Map<String, dynamic>);

    expect(restored.id, record.id);
    expect(restored.isVictory, true);
    expect(restored.moves.length, 1);
    expect(restored.moves.first.to, const BoardPosition(3, 3));
  });
}