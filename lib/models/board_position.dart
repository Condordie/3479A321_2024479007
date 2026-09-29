import 'package:flutter/foundation.dart';

@immutable
class BoardPosition {
  final int row;
  final int col;

  const BoardPosition(this.row, this.col)
      : assert(row >= 0 && row < 7, 'La fila debe estar confinada en el intervalo [0, 6]'),
        assert(col >= 0 && col < 7, 'La columna debe estar confinada en el intervalo [0, 6]');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => 'BoardPosition(r: $row, c: $col)';
}