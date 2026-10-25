import 'package:flutter_test/flutter_test.dart';
import 'package:rompecabezas/aplicacion.dart';

void main() {
  testWidgets('Jugar pide la dificultad y abre el tablero correspondiente',
      (tester) async {
    await tester.pumpWidget(const AplicacionRompecabezas());
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jugar'));
    await tester.pumpAndSettle();
    expect(find.text('Elige la dificultad'), findsOneWidget);

    await tester.tap(find.text('Fácil'));
    await tester.pumpAndSettle();
    expect(find.text('Jugar · Fácil (3×3)'), findsOneWidget);
  });

  testWidgets('cerrar el selector sin elegir no abre el juego',
      (tester) async {
    await tester.pumpWidget(const AplicacionRompecabezas());
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jugar'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // toca fuera de la hoja
    await tester.pumpAndSettle();

    expect(find.text('Elige la dificultad'), findsNothing);
    expect(find.textContaining('Jugar ·'), findsNothing);
  });
}
