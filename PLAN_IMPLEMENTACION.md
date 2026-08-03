# Roadmap Completo: Proyecto "Rutine" (Flutter)

Hoja de ruta completa con todas las fases de desarrollo. Avanzamos fase por fase, asegurándonos de que cada módulo funcione antes de pasar al siguiente.

---

## ✅ Fase 1: Configuración del Entorno y Base del Proyecto — COMPLETADA

- [x] Instalación de Flutter SDK (`C:\src\flutter`)
- [x] Android Studio + Android SDK configurados
- [x] Modo Desarrollador de Windows activado
- [x] Proyecto creado: `flutter create . --project-name rutine --org com.rutine`
- [x] Dependencias instaladas: `google_fonts`, `percent_indicator`
- [x] Dispositivo físico autorizado: LM G910 (Android 12, API 31)
- [x] Primera ejecución exitosa en el dispositivo

---

## ✅ Fase 2: Arquitectura y Diseño Base (UI/UX) — COMPLETADA

- [x] Estructura modular de carpetas (`screens/`, `models/`, `providers/`, `theme/`)
- [x] Tema global implementado: paleta Neón Oscuro, tipografía Outfit
- [x] Modelo de datos `Task` con 5 categorías y soporte recurrente
- [x] `TaskProvider` (ChangeNotifier) con lógica de estado
- [x] Navegación principal: Bottom App Bar + FAB con gradiente
- [x] Dashboard: Saludo dinámico + progreso circular + lista de tareas con swipe
- [x] Hot Reload verificado y corrección de layout aplicada

---

## ✅ Fase 3: Pantallas Principales (Frontend) — COMPLETADA

### Entregables
- [x] **Modal "Nueva Tarea":** Selector de categoría, título, descripción, DatePicker, TimePicker, switch de recurrencia con días
- [x] **Pantalla Agenda / Calendario:** Calendario mensual interactivo, indicadores de días con tareas, barra de progreso del día
- [x] **Integración del FAB:** Botón + conectado al modal de nueva tarea desde cualquier pantalla

---

## ✅ Fase 4: Lógica de Negocio y Motor de Tareas — COMPLETADA

### Entregables
- [x] Algoritmo de recurrencia dinámico sin duplicar datos
- [x] Cálculo avanzado de rachas (streaks) actuales y mejor racha histórica
- [x] Pantalla de Estadísticas con: 
  - Gráfico de barras animado de los últimos 7 días
  - Mensaje motivacional dinámico según el rendimiento
  - Barras de progreso de completitud por categoría
  - Gráfico de pastel (pie chart) interactivo de la distribución de tareas

---

## ✅ Fase 5: Persistencia de Datos — COMPLETADA

### Entregables
- [x] Integración de base de datos local rápida y ligera con **Hive** y `hive_flutter`
- [x] Serialización JSON de los modelos (`toMap`, `fromMap`) sin dependencias de generación de código pesadas
- [x] Creación de `HiveService` para gestionar la persistencia
- [x] Migración del `TaskProvider` para sincronizar el estado reactivo con la persistencia en Hive
- [x] Caja dedicada para preferencias del usuario (`prefsBox`) conectada al saludo dinámico del Dashboard

---

## ✅ Fase 6: Optimización, Empaquetado y Despliegue — COMPLETADA

### Entregables
- [x] Pantalla de perfil (`ProfileScreen`) con edición de usuario
- [x] Integración de `flutter_local_notifications` para recordatorios programados en base a la hora de las tareas.
- [x] Permisos de Android (`AndroidManifest.xml`) para alarmas exactas en Android 12+.
- [x] Generación de la build oficial para producción: APK generado en `build\app\outputs\flutter-apk\app-release.apk`.
- [x] Artifact final de `walkthrough.md` para proveer los siguientes pasos hacia la Google Play Store.

---

## ❓ Decisiones Técnicas Tomadas

| Decisión | Elección | Motivo |
|----------|----------|--------|
| Framework | Flutter (Dart) | Multiplataforma, rendimiento nativo |
| Estilo Visual | Gamificación Neón Oscuro | Elección del usuario |
| Fuente tipográfica | Outfit (Google Fonts) | Moderna, legible y premium |
| Gestión de estado | ChangeNotifier | Simple, sin dependencias extra en fase inicial |
| Base de datos | Hive / Isar (pendiente) | Ligera, rápida y sin servidor |
| Pruebas | Dispositivo físico LG G910 | Más rápido que emulador |
