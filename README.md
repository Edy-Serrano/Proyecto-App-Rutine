# 📘 Rutine - Documentación General

Bienvenido a la documentación oficial de **Rutine**, tu gestor personal de tareas y rutinas diseñado bajo un concepto gamificado y una estética atractiva de temática oscura y luminosa.

---

## 🎯 Propósito del Proyecto
Rutine nace para resolver el problema clásico de la falta de constancia al realizar tareas diarias. A diferencia de un simple bloc de notas, Rutine incentiva al usuario mostrándole gráficas de su rendimiento diario, semanal y mensual, además de un contador de **"Rachas" (Streaks)** para que mantenga su nivel de productividad en alto. 

Todo esto está envuelto en una experiencia de usuario rápida, fluida y sumamente satisfactoria mediante micro-interacciones.

---

## ✨ Funcionalidades Principales (Features)

1. **Gestión Integral de Tareas:**
   - Crear, visualizar, editar y eliminar tareas con categorías especializadas (Universidad, Higiene, Trabajo, Deporte, Comida, etc).
   - Asignación de iconos específicos y colores por cada categoría.
   - Posibilidad de establecer fechas y horas precisas.

2. **Recordatorios Inteligentes (Notificaciones Locales):**
   - Alarmas exactas integradas nativamente en Android.
   - Posibilidad de definir cuántos minutos antes deseas ser avisado de tu tarea (10, 15, 30 minutos, etc).

3. **Gamificación y Estadísticas:**
   - Panel de control principal con porcentaje de progreso en tiempo real del día.
   - Sección interactiva de gráficas de barras para evaluar los últimos 7 días.
   - Contadores numéricos que premian los días perfectos consecutivos (Mejor Racha y Racha Actual).

4. **Diseño Visual Dinámico:**
   - Cambio fluido e instantáneo entre **Modo Claro** y **Modo Oscuro** que respeta la jerarquía de lectura del sistema.
   - Interacciones hápticas (vibración leve) al completar o desmarcar tareas.
   - Interfaces fluidas mediante uso de `BottomSheets` y `Dialogs` emergentes redondeados.

5. **Persistencia Total Sin Internet (Offline First):**
   - Tus datos y configuraciones personales viajan contigo de forma local gracias a la integración nativa y ligera de `Hive Database`.

---

## 💻 Guía Rápida de Uso (Para el Usuario Final)

### Pantalla de Inicio (Dashboard)
- Es lo primero que ves al abrir la app. Se enfoca exclusivamente en **tu día de hoy**.
- **Completar tarea:** Simplemente toca el círculo (checkbox) o desliza (swipe) la tarea de izquierda a derecha. ¡Verás una luz verde!
- **Ver Detalles:** Toca la tarjeta de la tarea (sobre el texto) para leer su descripción completa en una elegante ventana.
- **Editar Tarea:** Mantén presionada cualquier tarea que necesites modificar.
- **Borrar Tarea:** Desliza (swipe) una tarea completamente hacia la izquierda. (¡Cuidado, esta acción no se puede deshacer!).

### Agenda (Calendario Semanal)
- Toca el ícono de calendario en la barra inferior.
- En la parte superior verás un carrusel de fechas. Selecciónalo para ir al día que desees organizar o revisar (ideal para prepararte para el día de mañana).

### Panel de Estadísticas (Stats)
- Toca el ícono de gráfica en la barra inferior.
- Monitorea tus gráficas y compite contigo mismo para lograr la "Mejor Racha Histórica" de días en donde marcaste el 100% de tus rutinas.

### Perfil y Configuración
- Personaliza tu experiencia. Toca el botón de cambiar Foto de Perfil o modifica tu nombre de usuario.
- Activa o desactiva la paleta visual (Modo Oscuro/Claro).
- Enciende o apaga por completo las notificaciones para que nada te moleste en tu tiempo libre.

---

## 🛠️ Cómo Compilar y Ejecutar el Proyecto (Para Desarrolladores)

El proyecto está diseñado exclusivamente para **Flutter**.

### Prerrequisitos:
- **Flutter SDK** instalado (Versión compatible probada >3.22.x).
- **Dart SDK** (v3.x).
- Emulador de Android o teléfono físico conectado vía USB/Wi-Fi (Depuración USB activada).

### Pasos de Ejecución:
1. **Clonar/Abrir el repositorio:** Abre la carpeta raíz del proyecto (`Proyecto-App-Rutine`) en tu editor preferido (VS Code, Android Studio, Cursor, etc).
2. **Descargar Dependencias:**
   Abre una terminal en la ruta del proyecto y ejecuta:
   ```bash
   flutter pub get
   ```
3. **Seleccionar un Dispositivo:**
   Asegúrate de que tu celular está conectado usando:
   ```bash
   flutter devices
   ```
4. **Correr en Debug Mode:**
   Ejecuta el siguiente comando o presiona `F5` en VSCode:
   ```bash
   flutter run
   ```
5. **Construir el Instalador (APK de Producción):**
   Si deseas exportar la aplicación lista para ser instalada en cualquier teléfono Android y compartirla, debes generar un APK comprimido. Ejecuta:
   ```bash
   flutter build apk --release
   ```
   *Nota: El archivo final lo encontrarás guardado dentro de la ruta `build/app/outputs/flutter-apk/app-release.apk`.*
