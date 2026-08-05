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

* **`task_model.dart`**: Define la clase `Task` (identificador, título, descripción, fecha, hora, estado de completado, estado de postergado `isPostponed` con enlace a su predecesora `postponedFromId`, días de recurrencia, minutos de recordatorio, historial de tiempos `history` con `TimeLog`, y metadatos nutricionales `foodMetadata`). También aloja el enum `TaskCategory` con sus respectivas extensiones para obtener iconos, nombres y colores (Higiene, Universidad, Trabajo, Compras, Paseo, Deporte, Comida, Otro, Ocio, Leer, Investigar, Gaming, Meditación).

---

### 📁 `providers/`
Controla el estado global y la lógica de negocio activa, comunicando los servicios subyacentes con la interfaz gráfica (UI).

* **`task_provider.dart`**: El núcleo lógico de la app. Gestiona la lista en memoria de las tareas. Provee métodos para agregar, editar, eliminar, marcar tareas como completadas y **posponer tareas**. Calcula los historiales de tareas postergadas de forma dinámica (`getFullHistory`) mediante enlazado en cascada, garantizando métricas sin duplicidad. Se encarga de:
  - Leer y escribir en `HiveService`.
  - Calcular estadísticas dinámicas (rachas actuales, mejores rachas, progreso de completado, tiempo invertido por categoría `timeInvestedByCategory` y estadísticas nutricionales `foodStats`).
  - Programar, cancelar y reprogramar las notificaciones llamando a `NotificationService`.
* **`theme_provider.dart`**: Controla el estado visual de la app y las preferencias de usuario. Gestiona la alternancia entre el **Modo Claro / Modo Oscuro** y el interruptor maestro de notificaciones, persistiendo estos valores mediante `HiveService`.

---

### 📁 `screens/`
Contiene la Interfaz de Usuario (UI). Son los widgets (Stateful o Stateless) con los que interactúa el usuario directamente.

* **`main_navigation.dart`**: Es el armazón base (Scaffold) que aloja la barra de navegación inferior (BottomNavigationBar) y controla qué pantalla se está mostrando actualmente.
* **`dashboard_screen.dart`**: Pantalla de "Inicio". Muestra el saludo inicial (según la hora del día), la Frase del Día con gamificación para ganar rachas extra, el progreso circular del día actual y una lista de las tareas pendientes para hoy. Soporta interacciones táctiles completas (deslizar para completar/borrar, toque corto para detalles e historial de tiempo, toque largo para editar y posponer).
* **`agenda_screen.dart`**: Vista de calendario. Usa un selector semanal deslizante. Permite ver las tareas asignadas a cualquier día en específico y también soporta acciones rápidas como marcar completado e interacciones para registro de tiempo.
* **`stats_screen.dart`**: Panel de métricas dinámico. Toda la pantalla reacciona a la fecha seleccionada en el calendario, recalculando al instante: resúmenes semanales/mensuales generales y por categoría, progreso específico por tarea filtrado por mes, distribución de tiempo invertido, gráficos de pastel duales (diario y mensual) basados en tiempo en horas/minutos, y una subsección de "Nutrición" para la categoría Comida.
* **`profile_screen.dart`**: Pantalla de preferencias. Permite gestionar datos personales (nombre, foto de perfil), cambiar el modo visual (Claro/Oscuro), gestionar alertas locales y generar respaldos seguros de datos (cifrados con AES-256) exportables mediante share_plus.
* **`add_task_sheet.dart`**: Es un `BottomSheet` dinámico y reutilizable que funge como formulario interactivo. Permite crear **nuevas tareas**, **editar tareas existentes**, o **posponer** tareas a nuevas fechas registrando el tiempo ya invertido. Cuenta con selectores estilizados para categoría, calendario de fechas, horas, y un panel nutricional especializado (si la categoría es `Food`).

---

### 📁 `services/`
Se encarga de la comunicación directa con APIs del sistema, bases de datos o servicios externos. Son clases estáticas o singletons que no manejan estado visual.

* **`hive_service.dart`**: Inicializa la base de datos local utilizando cifrado nativo **AES-256** (cuya llave maestra se genera y guarda de forma segura con `flutter_secure_storage`). Provee la envoltura para leer/escribir las Tareas, preferencias de tema, notificaciones, persistencia del chequeo de la Frase del Día y funciones para exportar/importar la base de datos de manera segura (`exportSecureBackup` / `importSecureBackup`).
* **`notification_service.dart`**: Puente con el sistema operativo Android usando `flutter_local_notifications`. Gestiona los permisos iniciales, la inicialización de zonas horarias locales (Timezones) y la programación exacta de alarmas en segundo plano con configuraciones avanzadas de canales (incluyendo el sonido personalizado `custom_sound.mp3` y patrones de vibración), así como su cancelación.

---

### 📁 `theme/`
Agrupa los tokens de diseño y configuraciones estéticas de la app.

* **`app_theme.dart`**: Definición central de la identidad visual. Define paletas de colores (fondos, tarjetas, acentos Neón), estilos de tipografía base (Google Fonts `Outfit`), formas de botones, y configuraciones globales para el Tema Oscuro y el Tema Claro de Material 3.

---

### 📁 `utils/`
Clases auxiliares y herramientas de cálculo global.

* **`quotes_repository.dart`**: Maneja el banco de 366 frases de la aplicación y la lógica para obtener la frase correspondiente al día del año actual (incluso en años bisiestos), orientadas al crecimiento personal y a la asertividad.

---

### 📁 `widgets/`
Componentes visuales reutilizables a lo largo de la aplicación.

* **`time_log_dialog.dart`**: Un cuadro de diálogo estilizado (Dialog) que interrumpe gentilmente al usuario al completar una tarea preguntando cuánto tiempo invirtió en horas/minutos y permitiendo añadir una nota textual.

---

### 📁 Scripts de Ciberseguridad (Raíz)
Archivos ubicados en la raíz del proyecto para asegurar la distribución de la aplicación.

* **`build_secure_apk.bat`** (Windows) y **`build_secure_apk.sh`** (Linux/Mac): Automatizan el proceso de compilación de producción de Flutter, inyectando banderas de ofuscación de código (`--obfuscate` y `--split-debug-info`) para compilar el código de Dart a binario de máquina inescrutable y prevenir ingeniería inversa.
