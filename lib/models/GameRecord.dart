import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class GameRecord {
  final String id;
  final DateTime date;
  final int remainingPegs;
  final int totalMoves;
  final int durationSeconds;
  final bool isVictory;
  const GameRecord({
    required this.id,
    required this.date,
    required this.remainingPegs,
    required this.totalMoves,
    required this.durationSeconds,
    required this.isVictory,
  });
}