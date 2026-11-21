# Gestor de Tareas Local (Flutter + SQLite)

Aplicación multiplataforma de gestión de tareas desarrollada en **Flutter** con persistencia local sin conexión mediante **SQLite**, diseñada para **Android, iOS, Windows, Linux, macOS y Web**.

Práctica de **Programación de Dispositivos Móviles** (7.º semestre, ISC - UAA).

## Tecnología de Persistencia

Se eligió **Drift (`drift` + `drift_flutter`)** por las siguientes razones:
* **SQLite multiplataforma:** Persiste los datos en disco en cada dispositivo (y vía `sqlite3.wasm` + `drift_worker.dart.js` en Web) con una sola base de código, sin depender de servidores externos (offline).
* **Reactividad (`Stream`):** Actualiza la interfaz automáticamente ante cambios en la tabla mediante `StreamBuilder`, evitando consultas dentro de `build()`.
* **Seguridad de tipos:** Genera código verificado en compilación con `drift_dev` y `build_runner`.

## Instalación y Ejecución

```bash
# 1. Clonar e instalar dependencias
git clone <URL_DE_TU_REPOSITORIO>
cd gestor_tareas_local
flutter pub get

# 2. Generar código de Drift (si se modifica la tabla)
dart run build_runner build --delete-conflicting-outputs

# 3. Ejecutar en Web o dispositivo nativo
flutter run -d chrome
# o: flutter run -d <id_dispositivo>
```

> **Nota Web:** Los archivos `web/sqlite3.wasm` y `web/drift_worker.dart.js` están incluidos y corresponden a las versiones de `pubspec.lock`.

## Pruebas

Para ejecutar el análisis estático y las pruebas automatizadas (validación de entradas y operaciones CRUD en SQLite):

```bash
flutter analyze
flutter test
```
