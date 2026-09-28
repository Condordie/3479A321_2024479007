import 'package:flutter/material.dart';
import 'package:untitled/core/enums/cell_type.dart';

class PegCell extends StatelessWidget {
  final int row;
  final int col;
  final CellType type;
  final bool isSelected;
  final VoidCallback? onTap;

  const PegCell({
    super.key,
    required this.row,
    required this.col,
    required this.type,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap, // ahora sí se usa el callback
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[200] : Colors.grey[400],
          border: Border.all(
            color: isSelected ? Colors.amber[800]! : Colors.grey[600]!,
            width: isSelected ? 3 : 1.5,
          ),
        ),
        child: Center(
          child: type == CellType.occupiedPeg
              ? Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Image.asset('assets/icons/icono.jpg'),
                )
              : type == CellType.emptyHole
                  ? Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
        ),
      ),
    );
  }
}