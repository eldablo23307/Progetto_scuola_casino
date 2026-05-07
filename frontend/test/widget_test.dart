import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('mostra la schermata di login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Brawls Bets'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Crea un nuovo account'), findsOneWidget);
  });
}
