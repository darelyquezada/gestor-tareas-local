import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_tareas_local/data/app_database.dart';
import 'package:gestor_tareas_local/main.dart';

AppDatabase _crearDbEnMemoria() {
  return AppDatabase(
    DatabaseConnection(
      NativeDatabase.memory(),
      closeStreamsSynchronously: true,
    ),
  );
}

void main() {
  testWidgets('La pantalla inicial se muestra sin errores', (tester) async {
    final db = _crearDbEnMemoria();

    await tester.pumpWidget(GestorTareasApp(database: db));
    await tester.pump();

    expect(find.text('Gestor de tareas'), findsOneWidget);
    expect(find.text('Agregar tarea'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await db.close();
  });

  testWidgets('Rechaza tareas vacías o compuestas solo por espacios',
      (tester) async {
    final db = _crearDbEnMemoria();

    await tester.pumpWidget(GestorTareasApp(database: db));
    await tester.pump();

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Agregar tarea'));
    await tester.pump();

    expect(find.text('El título no puede estar vacío'), findsOneWidget);
    expect(find.text('Todavía no hay tareas guardadas'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await db.close();
  });

  testWidgets('Guarda, actualiza estado, edita título y elimina en SQLite',
      (tester) async {
    final db = _crearDbEnMemoria();

    await tester.pumpWidget(GestorTareasApp(database: db));
    await tester.pump();

    // 1. Alta y consulta reactiva
    await tester.enterText(find.byType(TextField), 'Preparar reporte PDF');
    await tester.tap(find.text('Agregar tarea'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar reporte PDF'), findsOneWidget);
    expect(find.text('ID: 1'), findsOneWidget);

    // 2. Actualizar estado (completada)
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    // 3. Editar título
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).last,
      'Entregar reporte PDF',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Entregar reporte PDF'), findsOneWidget);
    expect(find.text('Preparar reporte PDF'), findsNothing);

    // 4. Eliminar registro
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Entregar reporte PDF'), findsNothing);
    expect(find.text('Todavía no hay tareas guardadas'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}