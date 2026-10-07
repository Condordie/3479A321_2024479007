import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetectorService {
  final double shakeThreshold;
  final VoidCallback onShake;
  final Duration debounceDuration;
  final Logger _logger = Logger();

  StreamSubscription<UserAccelerometerEvent>? _subscription;
  late final AppLifecycleListener _lifecycleListener;
  DateTime _lastShakeTime = DateTime.now();
  bool _isListening = false;

  ShakeDetectorService({
    required this.onShake,
    this.shakeThreshold = 10.0, // Valor por defecto en m/s²
    this.debounceDuration = const Duration(milliseconds: 1200),
  }) {
    _initLifecycleListener();
  }

  /// Vincula la escucha del hardware a los estados del Sistema Operativo
  void _initLifecycleListener() {
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _logger.i('SO Resumed: Reanudando sensor de aceleración');
        startListening();
      },
      onPause: () {
        _logger.i('SO Paused: Suspendiendo sensor para mitigar consumo de batería');
        stopListening();
      },
      onDetach: () => dispose(),
    );
  }

  /// Inicia la suscripción al stream de eventos del sensor
  void startListening() {
    if (_isListening) return;

    _subscription = userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        final double magnitude = sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );

        if (magnitude > shakeThreshold) {
          final now = DateTime.now();
          if (now.difference(_lastShakeTime) > debounceDuration) {
            _lastShakeTime = now;
            _logger.i('¡Shake detectado! Magnitud: ${magnitude.toStringAsFixed(2)} m/s²');
            onShake();
          }
        }
      },
      onError: (error) {
        _logger.e('Error en el flujo del acelerómetro: $error');
      },
      cancelOnError: false,
    );

    _isListening = true;
    _logger.i('ShakeDetectorService: Escucha activa');
  }

  /// Detiene la suscripción al stream liberando el hilo de eventos
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _logger.i('ShakeDetectorService: Escucha detenida');
  }

  /// Liberación completa de recursos
  void dispose() {
    stopListening();
    _lifecycleListener.dispose();
  }
}