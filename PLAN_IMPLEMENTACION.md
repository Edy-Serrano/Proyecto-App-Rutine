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

## 🔄 Fase 3: Pantallas Principales (Frontend) — EN PROGRESO

### Objetivo
Construir las interfaces completas donde el usuario interactúa con sus tareas.

### Tareas
- [/] **Modal / Pantalla "Nueva Tarea":**
  - Selector de categoría con íconos y colores
  - Campo de título y descripción
  - DatePicker y TimePicker estilizados
  - Switch de "Tarea Recurrente" con selector de días de la semana
- [ ] **Pantalla Agenda / Calendario:**
  - Calendario mensual interactivo (widget `TableCalendar` o implementación propia)
  - Vista de tareas del día seleccionado
  - Indicadores de días con tareas asignadas
- [ ] **Integración del FAB:** conectar el botón + con el modal de nueva tarea

---

## ⏳ Fase 4: Lógica de Negocio y Motor de Tareas

### Objetivo
Darle inteligencia y dinamismo a la aplicación.

### Tareas
- [ ] Algoritmo de recurrencia avanzado (generar instancias de tareas repetitivas)
- [ ] Sistema de rachas (streaks): calcular días consecutivos completados
- [ ] Pantalla de Estadísticas:
  - Gráfico de barras semanal por categoría
  - Gráfico de pastel (pie chart) de distribución
  - Score mensual de productividad
  - Mensajes motivadores basados en el rendimiento

---

## ⏳ Fase 5: Persistencia de Datos (Base de Datos Local)

### Objetivo
Garantizar que toda la información se guarde de forma permanente en el dispositivo.

### Tareas
- [ ] Integración de base de datos local (**Hive** o **Isar**)
- [ ] Persistencia de tareas creadas y su historial de completado
- [ ] Migración del `TaskProvider` para leer/escribir en la base de datos
- [ ] Guardado de preferencias del usuario (nombre, tema)

---

## ⏳ Fase 6: Optimización, Empaquetado y Despliegue

### Objetivo
Dejar la app lista para publicación.

### Tareas
- [ ] Pantalla de perfil y configuración de categorías personalizadas
- [ ] Notificaciones locales (recordatorio de tareas por hora)
- [ ] Pruebas manuales completas (QA)
- [ ] Pulido de micro-animaciones
- [ ] Generación del APK de producción (`flutter build apk --release`)
- [ ] Generación del AAB para Play Store (`flutter build appbundle`)
- [ ] Guía paso a paso: firma de la app y subida a Google Play Store

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
