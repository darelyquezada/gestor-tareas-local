import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Tareas extends Table {
  // ID único autoincremental (Llave primaria)
  IntColumn get id => integer().autoIncrement()();

  // Título obligatorio (mínimo 1 carácter)
  TextColumn get titulo => text().withLength(min: 1)();

  // Estado booleano mapeado como 0/1, falso por defecto
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(
          name: 'tareas_db', 
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.dart.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 1;

  // Consulta reactiva Stream
  Stream<List<Tarea>> watchTareas() {
    return (select(tareas)..orderBy([(t) => OrderingTerm.asc(t.id)])).watch();
  }

  // Alta: valida que el título no esté vacío y lo guarda en SQLite
  Future<int> insertarTarea(String titulo) {
    final tituloLimpio = titulo.trim();
    if (tituloLimpio.isEmpty) {
      throw ArgumentError('El título de la tarea no puede estar vacío.');
    }
    return into(tareas).insert(
      TareasCompanion.insert(titulo: tituloLimpio),
    );
  }

  // Actualización de estado
  Future<int> actualizarEstadoTarea(int id, bool completada) {
    return (update(tareas)..where((t) => t.id.equals(id))).write( 
      TareasCompanion(completada: Value(completada)),
    );
  }

  // Edición de título
  Future<int> actualizarTituloTarea(int id, String nuevoTitulo) {
    final tituloLimpio = nuevoTitulo.trim();
    if (tituloLimpio.isEmpty) {
      throw ArgumentError('El título de la tarea no puede estar vacío.');
    }
    return (update(tareas)..where((t) => t.id.equals(id))).write(
      TareasCompanion(titulo: Value(tituloLimpio)),
    );
  }

  // Baja: borra el registro específico por su ID
  Future<int> eliminarTarea(int id) {
    return (delete(tareas)..where((t) => t.id.equals(id))).go();
  }
}
