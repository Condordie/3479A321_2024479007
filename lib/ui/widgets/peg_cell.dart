import 'package:flutter/material.dart';
import 'package:untitled/core/enums/cell_type.dart';
import 'package:untitled/models/board_position.dart';

class PegCell extends StatelessWidget {
  final BoardPosition position;
  final CellType cellType;
  final bool isSelected;
  final bool isValidDestination;
  final VoidCallback? onTap;

  const PegCell({
    super.key,
    required this.position,
    required this.cellType,
    this.isSelected = false,
    this.isValidDestination = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber[200] : Colors.grey[400],
          border: Border.all(
            color: isSelected
                ? Colors.amber[800]!
                : isValidDestination
                    ? Colors.green[300]!
                    : Colors.grey[600]!,
            width: (isSelected || isValidDestination) ? 3 : 1.5,
          ),
        ),
        child: Center(
          child: cellType == CellType.occupiedPeg
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
              : cellType == CellType.emptyHole
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