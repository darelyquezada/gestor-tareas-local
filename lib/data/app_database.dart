import 'package:drift/drift.dart';

class Tareas extends Table {
  // ID único autoincremental (Llave primaria)
  IntColumn get id => integer().autoIncrement()();

  // Título obligatorio (mínimo 1 carácter)
  TextColumn get titulo => text().withLength(min: 1)();

  // Estado booleano mapeado como 0/1, falso por defecto
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}