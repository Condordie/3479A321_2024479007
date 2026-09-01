/// Estados de la celda en el tablero.
enum CellType {
  voidCell, // Fuera de límites jugables (Esquinas 2x2)
  emptyHole, // Casilla jugable desocupada
  occupiedPeg, // Casilla jugable con clavija presente
}