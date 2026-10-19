import 'package:flutter_test/flutter_test.dart';

import 'package:puzzle15/aplicacion.dart';

void main() {
  testWidgets('La presentación muestra el título y "Saltar" lleva al menú', (
    tester,
  ) async {
    await tester.pumpWidget(const AplicacionRompecabezas());
    await tester.pump(const Duration(milliseconds: 1300));

    expect(find.text('15-Puzzle Flutter'), findsOneWidget);

    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    expect(find.text('Jugar'), findsOneWidget);
    expect(find.text('Marcadores'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('¿Cómo jugar?'), findsOneWidget);
  });

  testWidgets('La presentación navega sola al menú pasado el intervalo', (
    tester,
  ) async {
    await tester.pumpWidget(const AplicacionRompecabezas());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Jugar'), findsOneWidget);
  });

  testWidgets('Se puede abrir una sección y volver al menú', (tester) async {
    await tester.pumpWidget(const AplicacionRompecabezas());
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('¿Cómo jugar?'));
    await tester.pumpAndSettle();
    expect(find.text('Volver al menú'), findsOneWidget);

    await tester.tap(find.text('Volver al menú'));
    await tester.pumpAndSettle();
    expect(find.text('Jugar'), findsOneWidget);
  });
}
