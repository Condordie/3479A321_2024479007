import 'package:flutter/material.dart';
import 'package:untitled/models/GameRecord.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  List<GameRecord> _getMockRecords() {
    return [
      GameRecord(
        id: 'REC-101',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        remainingPegs: 1,
        totalMoves: 31,
        durationSeconds: 145,
        isVictory: true,
      ),
      GameRecord(
        id: 'REC-102',
        date: DateTime.now().subtract(const Duration(days: 1)),
        remainingPegs: 3,
        totalMoves: 29,
        durationSeconds: 215,
        isVictory: false,
      ),
      GameRecord(
        id: 'REC-103',
        date: DateTime.now().subtract(const Duration(days: 2)),
        remainingPegs: 1,
        totalMoves: 33,
        durationSeconds: 198,
        isVictory: true,
      ),
      GameRecord(
        id: 'REC-104',
        date: DateTime.now().subtract(const Duration(days: 3)),
        remainingPegs: 5,
        totalMoves: 22,
        durationSeconds: 176,
        isVictory: false,
      ),
      GameRecord(
        id: 'REC-105',
        date: DateTime.now().subtract(const Duration(days: 4)),
        remainingPegs: 2,
        totalMoves: 30,
        durationSeconds: 210,
        isVictory: false,
      ),
      GameRecord(
        id: 'REC-106',
        date: DateTime.now().subtract(const Duration(days: 5)),
        remainingPegs: 1,
        totalMoves: 32,
        durationSeconds: 189,
        isVictory: true,
      ),
      GameRecord(
        id: 'REC-107',
        date: DateTime.now().subtract(const Duration(days: 6)),
        remainingPegs: 4,
        totalMoves: 25,
        durationSeconds: 160,
        isVictory: false,
      ),
      GameRecord(
        id: 'REC-108',
        date: DateTime.now().subtract(const Duration(days: 7)),
        remainingPegs: 1,
        totalMoves: 34,
        durationSeconds: 230,
        isVictory: true,
      ),
      GameRecord(
        id: 'REC-109',
        date: DateTime.now().subtract(const Duration(days: 8)),
        remainingPegs: 6,
        totalMoves: 19,
        durationSeconds: 140,
        isVictory: false,
      ),
      GameRecord(
        id: 'REC-110',
        date: DateTime.now().subtract(const Duration(days: 9)),
        remainingPegs: 1,
        totalMoves: 31,
        durationSeconds: 205,
        isVictory: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final records = _getMockRecords();
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Partidas')),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];

          final minutes = record.durationSeconds ~/ 60;
          final seconds = record.durationSeconds % 60;
          final durationText = '${minutes}m ${seconds.toString().padLeft(2, '0')}s';

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: record.isVictory
                    ? Colors.green.withOpacity(0.15)
                    : theme.colorScheme.errorContainer,
                child: Icon(
                  record.isVictory ? Icons.emoji_events : Icons.close,
                  color: record.isVictory ? Colors.green : theme.colorScheme.error,
                ),
              ),
              title: Text(
                record.isVictory ? '¡Victoria!' : 'Derrota',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${record.date}\n'
                  'Fichas restantes: ${record.remainingPegs} · '
                  'Movimientos: ${record.totalMoves} · '
                  'Duración: $durationText',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              isThreeLine: true,
              trailing: Text(
                '#${record.id}',
                style: theme.textTheme.labelSmall,
              ),
            ),
          );
        },
      ),
    );
  }
}