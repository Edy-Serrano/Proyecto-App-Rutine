# Rutine - Documentación General

Bienvenido a la documentación oficial de **Rutine**, tu gestor personal de tareas y rutinas diseñado bajo un concepto gamificado y una estética atractiva de temática oscura y luminosa.

---

## Propósito del Proyecto
Rutine nace para resolver el problema clásico de la falta de constancia al realizar tareas diarias. A diferencia de un simple bloc de notas, Rutine incentiva al usuario mostrándole gráficas de su rendimiento diario, semanal y mensual, además de un contador de **"Rachas" (Streaks)** para que mantenga su nivel de productividad en alto. 

Todo esto está envuelto en una experiencia de usuario rápida, fluida y sumamente satisfactoria mediante micro-interacciones.

---

## Funcionalidades Principales (Features)

1. **Gestión Integral de Tareas:**
   - Crear, visualizar, editar y eliminar tareas con categorías especializadas (Universidad, Higiene, Trabajo, Deporte, Comida, Paseo, Entretenimiento, Leer, Investigar, Gaming, Meditación, etc).
   - Asignación de iconos específicos y colores por cada categoría.
   - Posibilidad de establecer fechas y horas precisas.

2. **Recordatorios Inteligentes (Notificaciones Locales):**
   - Alarmas exactas integradas nativamente en Android con ícono y color representativo según la categoría.
   - Patrón de vibración personalizado y sonido específico (usando archivos `.mp3` propios) para garantizar que los recordatorios capten la atención.
   - Posibilidad de definir cuántos minutos antes deseas ser avisado de tu actividad (10, 15, 30 minutos, etc).

3. **Gamificación y Estadísticas Interactivas:**
   - Panel de control principal con porcentaje de progreso en tiempo real y un **Reto Diario Interactivo** (de Zona de Confort) con botones para ganar rachas especiales.
   - Panel interactivo de estadísticas (`StatsScreen`) con selección por fechas para analizar:
     - El **Tiempo Invertido** por cada categoría y porcentaje de tu tiempo productivo en el día.
     - Gráficas y tarjetas dinámicas que te muestran tu progreso.
     - Posibilidad de **Exportar Estadísticas a CSV** para visualizarlas en Excel, detectando inteligentemente solo los meses en los que tienes actividad real.
   - Perfil con **Títulos de Gamificación** según tu racha general y una Racha de Confort independiente.
   - Contadores numéricos que premian los días perfectos consecutivos (Mejor Racha y Racha Actual).

4. **Registro de Tiempo y Postergación Inteligente (Time Tracking):**
   - Al marcar una tarea como completada, se te preguntará el tiempo que le has dedicado y si tienes una nota.
   - Posibilidad de **Posponer** tareas a otro día desde el menú de edición, registrando el avance de hoy sin perder el historial.
   - **Sistema de Cadenas Dinámicas:** Al posponer múltiples veces, la aplicación crea una cadena inteligente. Las horas se calculan dinámicamente; si eliminas una tarea intermedia, la cadena se reconecta de forma automática (restando el tiempo de esa tarea eliminada pero conservando intacto todo el resto del historial), garantizando métricas globales perfectas sin conteo doble.
   - Al tocar cualquier tarea, se despliega una ventana con todo su **Historial de Tiempos** consolidado.

5. **Registro Nutricional Integrado:**
   - Creación de tareas con la categoría **Comida** despliega un panel especial.
   - Registra de forma sencilla tu consumo de vasos de agua, proteínas y carbohidratos, visualizándolo resumido en tu panel de estadísticas diario.

6. **Diseño Visual Dinámico:**
   - Cambio fluido e instantáneo entre **Modo Claro** y **Modo Oscuro** que respeta la jerarquía de lectura del sistema.
   - Interacciones hápticas (vibración leve) al completar o desmarcar tareas.
   - Interfaces fluidas mediante uso de `BottomSheets` y `Dialogs` emergentes redondeados.

7. **Persistencia Total Sin Internet (Offline First):**
   - Tus datos y configuraciones personales viajan contigo de forma local gracias a la integración nativa y ligera de `Hive Database`.

---

## 💻 Guía Rápida de Uso (Para el Usuario Final)

### Pantalla de Inicio (Dashboard)
- Es lo primero que ves al abrir la app. Se enfoca exclusivamente en **tu día de hoy**.
- **Reto del Día:** Sal de tu zona de confort con un reto diario clasificado por niveles. Pulsa en "¡Lo cumplí!" para sumar días a tu Racha de Confort especial.
- **Completar tarea:** Simplemente toca el círculo (checkbox) o desliza (swipe) la tarea de izquierda a derecha. ¡Aparecerá un menú preguntándote cuánto tiempo le dedicaste hoy!
- **Ver Detalles:** Toca la tarjeta de la tarea (sobre el texto) para leer su descripción completa y ver todo su **Historial de Tiempo (Timeline)** acumulado.
- **Editar o Posponer:** Mantén presionada cualquier tarea que necesites modificar. Si hoy no la terminaste, usa el botón "Posponer a otro día" para registrar el avance de hoy y cambiar su fecha sin perder su historial.
- **Borrar Tarea:** Desliza (swipe) una tarea completamente hacia la izquierda. (¡Cuidado, esta acción no se puede deshacer!).

### Agenda (Calendario Semanal)
- Toca el ícono de calendario en la barra inferior.
- En la parte superior verás un carrusel de fechas. Selecciónalo para ir al día que desees organizar o revisar (ideal para prepararte para el día de mañana).

### Panel de Estadísticas Dinámico (Stats)
- Toca el ícono de gráfica en la barra inferior.
- Selecciona la **Fecha** que quieres evaluar usando las flechas superiores. Toda la pantalla reacciona como una máquina del tiempo: si viajas a un mes pasado, todos tus promedios, listas y gráficos se ajustarán para mostrarte el desempeño de esa época.
- **Resumen Semanal y Mensual:** Visualiza tus rachas, porcentaje de éxito general y el porcentaje de éxito desglosado **por cada categoría**.
- **Por Tarea Específica:** Identifica hábitos individuales. Analiza cuántas veces programaste vs cuántas veces completaste una tarea exacta *durante el mes que tienes seleccionado*.
- **Gráficos de Distribución:** Explora dos gráficos de pastel interactivos. Uno para ver en qué categorías se fue tu día, y otro para ver el panorama general de tu mes. Ambos gráficos están basados en el **tiempo exacto** (en horas y minutos) que invertiste en cada categoría.
- Si registraste tareas de la categoría **Comida**, verás aquí mismo una tarjeta con la recopilación de tu consumo de macros (Agua, Proteínas y Carbohidratos).

### Perfil y Configuración
- Personaliza tu experiencia. Toca el botón de cambiar Foto de Perfil o modifica tu nombre de usuario.
- Observa tu **Título de Gamificación** y tu **Racha de Confort** debajo de tu foto.
- En los **Ajustes Generales**:
  - Activa o desactiva la paleta visual (Modo Oscuro/Claro).
  - Enciende o apaga por completo las notificaciones.
  - **Exportar Estadísticas:** La aplicación detecta dinámicamente en qué meses has registrado productividad y te permite exportarlos en formato CSV.

---

## Cómo Compilar y Ejecutar el Proyecto (Para Desarrolladores)

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
