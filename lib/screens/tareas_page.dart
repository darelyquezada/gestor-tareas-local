import 'package:flutter/material.dart';
import '../data/app_database.dart';

class TareasPage extends StatefulWidget {
  final AppDatabase database;

  const TareasPage({super.key, required this.database});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();
  late final Stream<List<Tarea>> _tareasStream;

  @override
  void initState() {
    super.initState();
    // Se inicializa el Stream aquí para evitar consultas en build()
    _tareasStream = widget.database.watchTareas();
  }

  Future<void> _agregarTarea() async {
    final titulo = _tituloController.text.trim();
    if (titulo.isEmpty) {
      _mostrarMensaje('El título no puede estar vacío');
      return;
    }

    try {
      await widget.database.insertarTarea(titulo);
      _tituloController.clear();
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('Error al guardar la tarea: $e');
    }
  }

  void _alternarCompletada(Tarea tarea, bool completada) {
    _mostrarMensaje('Implementar actualización de tarea');
  }

  void _editarTarea(Tarea tarea) {
    _mostrarMensaje('Implementar edición de título');
  }

  void _eliminarTarea(Tarea tarea) {
    _mostrarMensaje('Implementar eliminación de tarea');
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    widget.database.close(); // Cerrar la conexión con BD
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Tarea>>(
                stream: _tareasStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final tareas = snapshot.data ?? [];

                  return tareas.isEmpty
                      ? const Center(child: Text('Todavía no hay tareas guardadas'))
                      : ListView.builder(
                            itemCount: tareas.length,
                            itemBuilder: (context, index) {
                              final tarea = tareas[index];
                              return Card(
                                child: ListTile(
                                  leading: Checkbox(
                                    value: tarea.completada,
                                    onChanged: (valor) {
                                      if (valor != null) {
                                        _alternarCompletada(tarea, valor);
                                      }
                                    },
                                  ),
                                  title: Text(tarea.titulo),
                                  subtitle: Text('ID: ${tarea.id}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Editar',
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _editarTarea(tarea),
                                      ),
                                      IconButton(
                                        tooltip: 'Eliminar',
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _eliminarTarea(tarea),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
