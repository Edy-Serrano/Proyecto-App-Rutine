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
5. **Construir el Instalador Seguro (APK de Producción Obfuscado):**
   Para un nivel máximo de seguridad de ciberseguridad, Rutine incluye scripts nativos que **ofuscan** el código para prevenir la ingeniería inversa y el escaneo de cadenas (strings) expuestas.
   Ejecuta el script proporcionado según tu sistema operativo:
   - En Windows: Haz doble clic en `build_secure_apk.bat` o ejecútalo en consola.
   - En Linux/Mac: Ejecuta `bash build_secure_apk.sh` en la terminal.
   
   *Nota: El archivo final seguro lo encontrarás guardado dentro de la ruta `build/app/outputs/flutter-apk/app-release.apk`.*

---

## Arquitectura de Ciberseguridad Integrada
Rutine incluye un sólido protocolo de seguridad (implementado en la Fase de Seguridad):
1. **Encriptación de Base de Datos:** Todos los datos en reposo guardados por `Hive` están cifrados usando **AES-256**, con una llave criptográfica maestra generada y almacenada en el hardware (`Keystore` usando `flutter_secure_storage`).
2. **Backups Seguros:** Al solicitar una Copia de Seguridad desde el Perfil, Rutine genera un archivo cifrado (`.enc`) usando encriptación simétrica. El backup es exportado usando el sistema nativo de tu teléfono (vía `share_plus`), asegurando que nadie pueda interceptar o leer tus datos si el archivo cae en manos equivocadas. Además, puedes **importar** estos archivos de forma segura para restaurar tus rutinas.
3. **Resistencia a Ingeniería Inversa:** El uso de `--obfuscate` al compilar asegura que las estructuras de datos, llaves de API, y lógica interna se transformen en código máquina (ARM) ilegible.
