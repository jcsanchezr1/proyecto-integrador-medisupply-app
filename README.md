# MediSupply - APP Móvil

Aplicación móvil desarrollada con Flutter como parte del proyecto integrador MediSupply, enfocada principalmente en la creación de pedidos y consulta de información relevante para visitas a los clientes.

## Funcionalidades principales del aplicativo

- Registro de clientes.
- Autenticación de usuarios con roles: **Cliente** y **Vendedor/Gerente de cuenta**.  
- Gestión de pedidos (crear, visualizar histórico, consultar inventario, recibir recomendaciones).  
- Consulta de clientes asignados para usuarios con rol **Vendedor/Gerente de cuenta**.  
- Consulta de rutas y registro de visitas para usuarios con rol **Vendedor/Gerente de cuenta**.   

---

## Instalación rápida (APK)

Para la revisión de entregas del app, se recomienda usar el **APK** para instalar la app directamente en un dispositivo Android.

### Pasos para instalar el APK
1. Descargar el archivo `app-release.apk` desde el GitHub Release correspondiente al sprint que se está entregando.
> **Ejemplo:** Si es la entrega del Sprint 01, el apk correspondiente estará en el Release v1.0 y así sucesivamente.
2. Transferirlo al dispositivo Android (Vía WhatsApp, correo, etc).  
3. En el dispositivo:
   - Habilitar la instalación desde **Fuentes desconocidas** si el sistema lo solicita.  
   - Abrir el APK y completar la instalación.  
4. Abrir la aplicación e interactuar con las funcionalidades.

## Ejecución en modo debug (opcional)

### Requisitos previos

Si prefieres ejecutar el código fuente en modo debug, asegúrate de contar con:

- **Flutter SDK** (recomendado >= 3.0.0).  
- **Android Studio** o **Visual Studio Code** con extensiones de Flutter instaladas.  
- **Emulador Android** configurado y arrancado *o* un dispositivo físico con depuración USB activada.  
> Para crear un emulador:
> 1. En Android Studio, ir a **Tools > Device Manager**.  
> 2. Crear un nuevo dispositivo virtual (AVD).  
> 3. Seleccionar la versión de Android deseada e iniciarlo.

Luego de cumplir con estos requisitos, verifica tu entorno ejecutando:
```bash
flutter doctor
```
- **Clonar repositorio**
```bash
git clone https://github.com/jcsanchezr1/proyecto-integrador-medisupply-app.git
```
- **Instalar dependencias** ejecutando en la terminal el comando
```bash
flutter pub get
```
- **Ejecutar la app** en el dispositivo inicializado o conectado
```bash
flutter run
```
---
## Estructura del proyecto
```bash
android/                   # Configuración Android (APK, Gradle, etc.)
ios/                       # Configuración iOS

assets/
  ┣ images/                # Imágenes, gifs, videos utilizados en el aplicativo.
  ┗ language/              # Diccionarios de idiomas inglés y español para textos estáticos.

lib/
  ┣ main.dart              # Punto de entrada
  ┗ src/
      ┣ classes/           # Modelos de datos
      ┣ pages/             # Páginas principales
      ┣ providers/         # Gestión del estado y comunicación entre componentes
      ┣ services/          # Lógica y llamadas a APIs
      ┣ utils/             # Constantes y utilitarios
      ┗ widgets/           # Componentes reutilizables

pubspec.yaml               # Dependencias y metadatos del proyecto
```
---
> **Nota final**
>
> Este proyecto es de uso académico e interno para la universidad.
> No está pensado para distribución pública ni para contribuciones externas.
