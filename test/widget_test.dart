import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meu_app/login.dart';
import 'package:meu_app/main.dart';

void main() {
  testWidgets('Login screen renders email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
  });

  testWidgets('Pending tasks appear at the top and completed tasks move to the bottom', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    Future<void> addTask(String name) async {
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), name);
      await tester.tap(find.text('Adicionar'));
      await tester.pumpAndSettle();
    }

    await addTask('Tarefa 1');
    await addTask('Tarefa 2');

    expect(
      tester.getTopLeft(find.text('Tarefa 1')).dy,
      lessThan(tester.getTopLeft(find.text('Tarefa 2')).dy),
    );

    // Mark 'Tarefa 1' (top task) as completed
    final firstTaskCheckbox = find.descendant(
      of: find.widgetWithText(ListTile, 'Tarefa 1'),
      matching: find.byType(Checkbox),
    );
    final secondTaskCheckbox = find.descendant(
      of: find.widgetWithText(ListTile, 'Tarefa 2'),
      matching: find.byType(Checkbox),
    );
    await tester.tap(firstTaskCheckbox);
    await tester.pumpAndSettle();

    // Only 'Tarefa 1' should be checked; 'Tarefa 2' stays unchecked at the top
    expect(tester.widget<Checkbox>(firstTaskCheckbox).value, isTrue);
    expect(tester.widget<Checkbox>(secondTaskCheckbox).value, isFalse);
    expect(find.text('Concluídas'), findsOneWidget);

    // 'Tarefa 2' (pending) should now be above 'Tarefa 1' (completed)
    expect(
      tester.getTopLeft(find.text('Tarefa 2')).dy,
      lessThan(tester.getTopLeft(find.text('Tarefa 1')).dy),
    );

    // Adding a new task should place it above the completed task
    await addTask('Tarefa 3');
    expect(
      tester.getTopLeft(find.text('Tarefa 3')).dy,
      lessThan(tester.getTopLeft(find.text('Tarefa 1')).dy),
    );
  });

  testWidgets('TaskDateCalendar selects a date before saving a task', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Home()));

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(TaskDateCalendar), findsOneWidget);
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Reunião');
    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    final now = DateTime.now();
    final expectedDate = formatTaskDate(DateTime(now.year, now.month, 15));
    expect(find.text('Data selecionada: $expectedDate'), findsOneWidget);

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Reunião'), findsOneWidget);
    expect(find.text('Data: $expectedDate'), findsOneWidget);
  });

  testWidgets('User must register first and then can log in', (WidgetTester tester) async {
    registeredUsers.clear();
    activeSession.clear();

    await tester.pumpWidget(const MyApp());

    // Try logging in without registering first
    await tester.enterText(find.byType(TextField).at(0), 'aluno@email.com');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(
      find.text('Nenhum usuário cadastrado. Faça o cadastro primeiro.'),
      findsOneWidget,
    );

    // Switch to registration mode and register
    await tester.tap(find.text('Não tem conta? Cadastrar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'aluno@email.com');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
    await tester.pumpAndSettle();

    expect(registeredUsers.length, 1);
    expect(find.text('Cadastro realizado! Agora faça login.'), findsOneWidget);

    // Now log in with the registered account
    await tester.enterText(find.byType(TextField).at(0), 'aluno@email.com');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
    await tester.pumpAndSettle();

    expect(activeSession.length, 1);
    expect(activeSession.first.email, 'aluno@email.com');
    expect(find.text('Gerenciador de tarefas'), findsOneWidget);
  });
}
