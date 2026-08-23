import 'package:flutter/material.dart';

class PegSolitaireScreen extends StatelessWidget {
  const PegSolitaireScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solitario')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  'STATUS: 349 segundos | Piezas restantes: 33',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _gameBoard(), // <- antes era el Text('Tablero de Juego')
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameBoard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 1.0, // Cuadrado perfecto
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(), // Bloquea el scroll
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, // 7 columnas
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
            ),
            itemCount: 49, // 7x7 = 49 celdas
            itemBuilder: (context, index) {
            return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  border: Border.all(color: Colors.grey[600]!, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$index', // Muestra el índice de la celda
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}