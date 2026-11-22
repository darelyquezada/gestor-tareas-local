import 'package:flutter/material.dart';
import '../data/app_database.dart';

class TareasPage extends StatefulWidget {
  final AppDatabase database;

  const TareasPage({super.key, required this.database});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController(); // controlador para el campo título 
  late final Stream<List<Tarea>> _tareasStream; // Stream que emite la lista de tareas actualizadas

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
      _tituloController.clear(); // limpia el campo 
    } catch (e) {
      if (!mounted) return; // protege contra llamadas asíncronas si el widget fue desmontado
      _mostrarMensaje('Error al guardar la tarea: $e');
    }
  }

  Future<void> _alternarCompletada(Tarea tarea, bool completada) async {
    try {
      await widget.database.actualizarEstadoTarea(tarea.id, completada);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('Error al actualizar el estado: $e');
    }
  }

  /// Muestra un AlertDialog para modificar el título de una tarea existente
  Future<void> _editarTarea(Tarea tarea) async {
    // Despliega el diálogo y espera la acción del usuario (guardar o cancelar)
    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final editController = TextEditingController(text: tarea.titulo);
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Título de la tarea',
              border: OutlineInputBorder(),
            ),
            // Permite confirmar la edición al presionar Enter en el teclado
            onSubmitted: (valor) => Navigator.of(dialogContext).pop(valor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // Cierra sin devolver datos
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(editController.text), // Devuelve el nuevo texto
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    // Si no hay título nuevo, no se hace nada
    if (nuevoTitulo == null) return;

    final tituloLimpio = nuevoTitulo.trim();
    if (tituloLimpio.isEmpty) {
      if (!mounted) return;
      _mostrarMensaje('El título no puede estar vacío');
      return;
    }

    try {
      await widget.database.actualizarTituloTarea(tarea.id, tituloLimpio);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('Error al editar la tarea: $e');
    }
  }

  Future<void> _eliminarTarea(Tarea tarea) async {
    try {
      await widget.database.eliminarTarea(tarea.id);
    } catch (e) {
      if (!mounted) return;
      _mostrarMensaje('Error al eliminar la tarea: $e');
    }
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    // Liberación de recursos para prevenir fugas de memoria
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
            // Vista reactiva que escucha los cambios del Stream y se redibuja automáticamente
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
                                  // Título con estilo tachado si la tarea ya fue completada
                                  title: Text(
                                    tarea.titulo,
                                    style: TextStyle(
                                      decoration: tarea.completada
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
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

