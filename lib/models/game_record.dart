import 'package:flutter/foundation.dart';
import 'package:untitled/models/move_record.dart';

@immutable
class GameRecord {
  final String id;
  final DateTime date;
  final int remainingPegs;
  final int totalMoves;
  final int durationSeconds;
  final bool isVictory;
  final List<MoveRecord> moves;

  const GameRecord({
    required this.id,
    required this.date,
    required this.remainingPegs,
    required this.totalMoves,
    required this.durationSeconds,
    required this.isVictory,
    this.moves = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'remainingPegs': remainingPegs,
        'totalMoves': totalMoves,
        'durationSeconds': durationSeconds,
        'isVictory': isVictory,
        'moves': moves.map((m) => m.toJson()).toList(),
      };

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      remainingPegs: json['remainingPegs'] as int,
      totalMoves: json['totalMoves'] as int,
      durationSeconds: json['durationSeconds'] as int,
      isVictory: json['isVictory'] as bool,
      moves: (json['moves'] as List<dynamic>?)
              ?.map((m) => MoveRecord.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}