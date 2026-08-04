# 📂 Estructura del Proyecto Rutine

La arquitectura de Rutine está diseñada bajo el patrón de separación de responsabilidades (Separation of Concerns), utilizando **Provider** para la gestión de estado y **Hive** para la base de datos local rápida. 

Toda la lógica principal reside en el directorio `lib/`, el cual está organizado en los siguientes módulos:

## 🗂️ `lib/`

Directorio raíz del código fuente en Dart.

### `main.dart`
El punto de entrada de la aplicación. Configura la inicialización de los servicios asíncronos (Hive, Notificaciones, Timezones), inyecta los `Providers` principales en la raíz del árbol de widgets, e inicializa la configuración visual de la barra de estado del sistema (SystemChrome).

---

### 📁 `models/`
Contiene las clases y estructuras de datos puras que representan la información de negocio de la aplicación.

* **`task_model.dart`**: Define la clase `Task` (identificador, título, descripción, fecha, hora, estado de completado, días de recurrencia y minutos de recordatorio). También aloja el enum `TaskCategory` con sus respectivas extensiones para obtener iconos, nombres y colores (Higiene, Universidad, Trabajo, Compras, Paseo, Deporte, Comida, Otro).

---

### 📁 `providers/`
Controla el estado global y la lógica de negocio activa, comunicando los servicios subyacentes con la interfaz gráfica (UI).

* **`task_provider.dart`**: El núcleo lógico de la app. Gestiona la lista en memoria de las tareas. Provee métodos para agregar, editar, eliminar y marcar tareas como completadas. Se encarga de:
  - Leer y escribir en `HiveService`.
  - Calcular estadísticas dinámicas (rachas actuales, mejores rachas, % semanal y mensual).
  - Programar, cancelar y reprogramar las notificaciones llamando a `NotificationService`.
* **`theme_provider.dart`**: Controla el estado visual de la app y las preferencias de usuario. Gestiona la alternancia entre el **Modo Claro / Modo Oscuro** y el interruptor maestro de notificaciones, persistiendo estos valores mediante `HiveService`.

---

### 📁 `screens/`
Contiene la Interfaz de Usuario (UI). Son los widgets (Stateful o Stateless) con los que interactúa el usuario directamente.

* **`main_navigation.dart`**: Es el armazón base (Scaffold) que aloja la barra de navegación inferior (BottomNavigationBar) y controla qué pantalla se está mostrando actualmente.
* **`dashboard_screen.dart`**: Pantalla de "Inicio". Muestra el saludo inicial (según la hora del día), el progreso circular del día actual y una lista de las tareas pendientes para hoy. Soporta interacciones táctiles completas (deslizar para completar/borrar, toque corto para detalles, toque largo para editar).
* **`agenda_screen.dart`**: Vista de calendario. Usa un selector semanal deslizante. Permite ver las tareas asignadas a cualquier día en específico y también soporta acciones rápidas como marcar completado.
* **`stats_screen.dart`**: Panel de métricas. Utiliza gráficos de barras y tarjetas analíticas para visualizar el rendimiento, progreso semanal, mensual, y rachas (streaks) de productividad.
* **`profile_screen.dart`**: Pantalla de preferencias. Permite gestionar datos personales (nombre, foto de perfil), cambiar el modo visual (Claro/Oscuro), gestionar alertas locales y (próximamente) respaldos en la nube.
* **`add_task_sheet.dart`**: Es un `BottomSheet` dinámico y reutilizable que funge como formulario interactivo. Permite crear **nuevas tareas** o **editar tareas existentes**. Cuenta con selectores estilizados para categoría, calendario de fechas, selector de horas y minutos de recordatorio.

---

### 📁 `services/`
Se encarga de la comunicación directa con APIs del sistema, bases de datos o servicios externos. Son clases estáticas o singletons que no manejan estado visual.

* **`hive_service.dart`**: Inicializa la base de datos local y provee la envoltura para leer/escribir las Tareas (en formato JSON stringificado), preferencias de tema, notificaciones, imagen de perfil y nombre de usuario en cajas (Boxes) de Hive.
* **`notification_service.dart`**: Puente con el sistema operativo Android usando `flutter_local_notifications`. Gestiona los permisos iniciales, la inicialización de zonas horarias locales (Timezones) y la programación exacta de alarmas en segundo plano, así como su cancelación.

---

### 📁 `theme/`
Agrupa los tokens de diseño y configuraciones estéticas de la app.

* **`app_theme.dart`**: Definición central de la identidad visual. Define paletas de colores (fondos, tarjetas, acentos Neón), estilos de tipografía base (Google Fonts `Outfit`), formas de botones, y configuraciones globales para el Tema Oscuro y el Tema Claro de Material 3.
