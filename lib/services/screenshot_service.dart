import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:untitled/core/utils/app_logger.dart';

/// Extrae buffers visuales del Render Tree y los convierte en archivos PNG.
class ScreenshotService {
  static Future<String?> captureWidgetToImage(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        AppLogger.warning(
            'No se encontró RenderRepaintBoundary asociado a la GlobalKey');
        return null;
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ui.ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        AppLogger.warning('No se pudo serializar la imagen a PNG');
        return null;
      }

      final buffer = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/peg_solitaire_record_${DateTime.now().millisecondsSinceEpoch}.png';
      await File(filePath).writeAsBytes(buffer, flush: true);

      AppLogger.info('Evidencia gráfica capturada con éxito en: $filePath');
      return filePath;
    } catch (e, st) {
      AppLogger.error('Error al capturar evidencia gráfica del tablero', e, st);
      return null;
    }
  }
}