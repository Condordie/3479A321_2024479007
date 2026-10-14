import 'package:flutter/material.dart';
import 'package:untitled/models/game_record.dart';
import 'package:untitled/repositories/game_history_repository.dart';
import 'package:untitled/repositories/json_files_history_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final IGameHistoryRepository _repository = JsonFileHistoryRepository();
  late Future<List<GameRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = _repository.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Partidas')),
      body: FutureBuilder<List<GameRecord>>(
        future: _historyFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }

          final records = asyncSnapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('Aún no hay partidas registradas.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildRecordCard(context, record);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, GameRecord record) {
    final theme = Theme.of(context);
    final minutes = record.durationSeconds ~/ 60;
    final seconds = record.durationSeconds % 60;
    final durationText = '${minutes}m ${seconds.toString().padLeft(2, '0')}s';

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: record.isVictory
              ? Colors.green.withValues(alpha: 0.15)
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
            '${record.date.toString().split('.').first}\n'
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
  }
}