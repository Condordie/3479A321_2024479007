import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/main.dart';

void main() {
  testWidgets('Smoke test: la app arranca y muestra el menú principal',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Menú Principal'), findsOneWidget);
    expect(find.text('Jugar'), findsOneWidget);
    expect(find.text('Reglas del Juego'), findsOneWidget);
    expect(find.text('Historial de Partidas'), findsOneWidget);
  });
}