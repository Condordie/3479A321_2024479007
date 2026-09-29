# Solitario Inglés (Peg Solitaire)

Aplicación móvil desarrollada en Flutter. Implementa la interfaz del juego Solitario Inglés (Peg Solitaire) con navegación entre pantallas, un tablero interactivo de 7x7 y un historial de partidas.

## Alcance

El proyecto cubre, hasta esta etapa, la capa de presentación y la navegación de la aplicación:

- Menú principal con acceso a las secciones de la aplicación.
- Pantalla de juego con el tablero de 7x7 (33 casillas jugables y cuatro esquinas de 2x2 no jugables), con selección y deselección de celdas mediante pulsación táctil.
- Pantalla de reglas del juego.
- Pantalla de historial de partidas, construida con una lista desplazable a partir de datos de ejemplo.
- Registro de eventos de interacción y navegación mediante logs.

Quedan fuera del alcance de esta etapa: la ejecución de saltos y captura de clavijas, la persistencia de datos (las partidas del historial son simuladas) y el cronómetro real de la partida.

## Requerimientos funcionales

| Código | Requerimiento |
|--------|---------------|
| RF1 | La aplicación debe mostrar un menú principal con las opciones Jugar, Reglas del Juego e Historial de Partidas. |
| RF2 | La aplicación debe mostrar un tablero de 7x7 con las cuatro esquinas de 2x2 como casillas no jugables, el centro (3, 3) como hueco vacío y el resto de casillas con clavija. |
| RF3 | El usuario debe poder seleccionar una casilla jugable pulsándola, y la selección debe distinguirse visualmente de las demás casillas. |
| RF4 | El usuario debe poder deseleccionar la casilla activa pulsándola nuevamente. |
| RF5 | Las casillas no jugables deben ignorar las pulsaciones sin alterar el estado de la selección. |
| RF6 | El usuario debe poder acceder a las reglas desde el menú principal y desde la pantalla de juego, y volver a la pantalla anterior. |
| RF7 | La aplicación debe mostrar un historial de partidas en una lista desplazable, indicando resultado (victoria o derrota), fecha, fichas restantes, movimientos, duración e identificador. |
| RF8 | La pantalla de juego debe mostrar una barra de estado con el tiempo y las piezas restantes. |

## Restricciones técnicas

- Desarrollo con Flutter y Dart, con interfaz basada en Material Design.
- Navegación mediante rutas nombradas (`/`, `/game`, `/history`, `/rules`) y `Navigator.push` para las reglas desde la pantalla de juego.
- Estado de la pantalla de juego gestionado localmente con `StatefulWidget` y `setState`.
- Tablero de tamaño fijo de 7x7 representado con `GridView.builder`, con desplazamiento bloqueado.
- Historial construido con `ListView.builder` y el modelo inmutable `GameRecord`, con datos simulados en memoria, sin base de datos ni almacenamiento persistente.
- Interacción exclusivamente táctil.
- Registro de eventos mediante el paquete `logger`.
- Recursos gráficos declarados como assets en `pubspec.yaml`.
- Código validado con `flutter analyze` antes de cada commit, y control de versiones con Git mediante ramas de trabajo por funcionalidad.

## Requerimientos no funcionales

- **Usabilidad:** la casilla seleccionada se resalta con un cambio de color, de borde y de ícono, y la navegación es directa desde el menú principal.
- **Rendimiento:** el tablero y el historial se construyen con `GridView.builder` y `ListView.builder`.
- **Mantenibilidad:** el código se organiza en capas y carpetas separadas (enumeraciones, modelos, pantallas y widgets), con widgets reutilizables como `PegCell`.
- **Trazabilidad:** las selecciones, deselecciones y navegaciones se registran con niveles de log adecuados para facilitar la depuración.
- **Calidad de código:** no debe presentar observaciones en `flutter analyze`.
- **Portabilidad:** al estar desarrollada en Flutter, la aplicación es compatible con Android e iOS.
- **Consistencia visual:** las pantallas comparten una misma estructura de barra superior y estilo de componentes.

## Estructura del proyecto

```
lib/
├── core/
│   └── enums/
│       └── cell_type.dart          # Tipos de celda del tablero
├── models/
│   └── GameRecord.dart             # Modelo inmutable de una partida
├── ui/
│   ├── screens/
│   │   ├── menu_screen.dart        # Menú principal
│   │   ├── peg_solitaire_screen.dart  # Pantalla de juego
│   │   ├── RulesScreen.dart        # Reglas del juego
│   │   └── historyScreen.dart      # Historial de partidas
│   └── widgets/
│       └── peg_cell.dart           # Celda del tablero
└── main.dart                       # Punto de entrada y rutas
```

## Ejecución

1. Instalar las dependencias:

   ```
   flutter pub get
   ```

2. Ejecutar la aplicación en un emulador o dispositivo:

   ```
   flutter run
   ```

3. Validar el código:

   ```
   flutter analyze
   ```