import 'package:flutter/material.dart';
import 'screens/tareas_page.dart';
import 'data/app_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  runApp(GestorTareasApp(database: database));
}

/// Punto de entrada de la aplicación con persistencia local SQLite (Drift)
class GestorTareasApp extends StatelessWidget {
  final AppDatabase? database;

  const GestorTareasApp({super.key, this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(database: database ?? AppDatabase()),
    );
  }
}
