import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('mostra la schermata di login', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Brawls Bets'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Crea un nuovo account'), findsOneWidget);
  });

  test('include i giochi principali della dashboard', () {
    expect(
      casinoGames.map((game) => game.title),
      containsAll(['Roulette', 'Ice Fishing', 'Gate of Olympus', 'Blackjack']),
    );
    expect(
      casinoGames.where((game) => game.apiPath.startsWith('/games/slots/')),
      hasLength(4),
    );
  });

  test('include le nuove puntate della roulette', () {
    expect(
      rouletteChoices.map((choice) => choice.value),
      containsAll(['number_0', 'number_17', 'even', 'odd', 'dozen_1', 'column_3']),
    );
    expect(
      rouletteChoices.where((choice) => choice.value.startsWith('number_')),
      hasLength(37),
    );
  });

  test('include le nuove puntate della roulette', () {
    expect(
      rouletteChoices.map((choice) => choice.value),
      containsAll(['number_0', 'number_17', 'even', 'odd', 'dozen_1', 'column_3']),
    );
    expect(
      rouletteChoices.where((choice) => choice.value.startsWith('number_')),
      hasLength(37),
    );
  });
}
