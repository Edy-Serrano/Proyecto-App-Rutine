# 🎮 Rutine — Tu Agenda Personal Gamificada

> Aplicación Android desarrollada con **Flutter** para gestionar rutinas diarias, hábitos personales y eventos con estadísticas de rendimiento.

---

## 📱 Capturas de Estado Actual
> _La app ya corre en el dispositivo LM G910 (Android 12). Fase 3 en progreso._

---

## 🚦 Estado del Proyecto

| Fase | Descripción | Estado |
|------|-------------|--------|
| 🏗️ Fase 1 | Configuración del Entorno y Base del Proyecto | ✅ Completada |
| 🎨 Fase 2 | Arquitectura y Diseño Base (UI/UX) | ✅ Completada |
| 📱 Fase 3 | Pantallas Principales (Frontend) | 🔄 En progreso |
| ⚙️ Fase 4 | Lógica de Negocio y Motor de Tareas | ⏳ Pendiente |
| 💾 Fase 5 | Persistencia de Datos (Base de Datos) | ⏳ Pendiente |
| 🚀 Fase 6 | Optimización, Empaquetado y Despliegue | ⏳ Pendiente |

---

## 🎯 Objetivo
Crear una aplicación móvil que combine funciones de **agenda**, **lista de tareas categorizadas** y un **panel de estadísticas de rendimiento**, con un diseño gamificado oscuro estilo Neón.

---

## 🛠️ Stack Tecnológico

- **Framework:** Flutter (Dart)
- **Plataforma:** Android (probado en LG G910 - Android 12 API 31)
- **Diseño:** Gamificación con paleta Neón Oscuro
- **Tipografía:** Outfit (Google Fonts)
- **Paquetes:**
  - `google_fonts` — Tipografía premium
  - `percent_indicator` — Indicadores circulares de progreso

---

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada
├── theme/
│   └── app_theme.dart           # Paleta de colores y tema global
├── models/
│   └── task_model.dart          # Modelo de datos: Task y categorías
├── providers/
│   └── task_provider.dart       # Gestión de estado (ChangeNotifier)
└── screens/
    ├── main_navigation.dart     # Navegación principal (Bottom Nav + FAB)
    ├── dashboard_screen.dart    # Pantalla de inicio con progreso diario
    ├── agenda_screen.dart       # 🔄 Calendario mensual (Fase 3)
    ├── stats_screen.dart        # ⏳ Estadísticas (Fase 4)
    └── add_task_screen.dart     # 🔄 Formulario de nueva tarea (Fase 3)
```

---

## 🎨 Paleta de Colores (Neón Oscuro)

| Rol | Color | Hex |
|-----|-------|-----|
| Fondo principal | Negro profundo | `#0D0D14` |
| Fondo tarjetas | Azul noche | `#1A1A2E` |
| Acento primario | Morado Neón | `#7C3AED` |
| Acento secundario | Cian Brillante | `#06B6D4` |
| Completado | Verde Neón | `#10B981` |
| Higiene | Cian | `#06B6D4` |
| Universidad | Morado | `#7C3AED` |
| Trabajo | Ámbar | `#F59E0B` |
| Compras | Verde | `#10B981` |
| Ocio/Paseo | Rosa | `#EC4899` |

---

## ⚙️ Cómo ejecutar el proyecto

### Prerrequisitos
- Flutter SDK instalado en `C:\src\flutter`
- Android Studio instalado (para el Android SDK)
- Modo Desarrollador de Windows activado

### Comandos
```bash
# Instalar dependencias
flutter pub get

# Ejecutar en dispositivo conectado
flutter run -d <device-id>

# Ver dispositivos conectados
flutter devices
```

---

## 🗺️ Plan de Desarrollo Detallado
Ver archivo [PLAN_IMPLEMENTACION.md](./PLAN_IMPLEMENTACION.md) para el roadmap completo con todas las fases.