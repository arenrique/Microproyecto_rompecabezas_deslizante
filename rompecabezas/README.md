# 15-Puzzle Flutter

Rompecabezas deslizante (15-Puzzle) hecho con Flutter y Material 3. Funciona en
móvil, tablet y escritorio, y también como aplicación web instalable (PWA).

> **Enlace a la aplicación publicada:** _pendiente. Se añadirá cuando el
> workflow se haya ejecutado correctamente y se haya comprobado el sitio._

## Funcionalidades

- **Tres dificultades:** Fácil (3×3, 8 fichas), Medio (4×4, 15 fichas) y
  Difícil (5×5, 24 fichas).
- **Tableros siempre resolubles:** se generan mezclando al azar y corrigiendo la
  paridad de inversiones.
- **Cronómetro y contador de movimientos:** el tiempo empieza con el primer
  movimiento válido y se detiene al ganar. Solo cuentan los movimientos válidos.
- **Marcadores por dificultad:** mejor tiempo y menor número de movimientos, cada
  uno con su fecha. Se guardan en el dispositivo.
- **Personalización:** tema claro, oscuro o automático; estilos de ficha
  (clásico, colorido, retro y minimalista); animaciones y sonido opcionales.
- **Pantallas:** presentación, menú, partida, configuración, marcadores e
  instrucciones, más un resumen de victoria con aviso de «¡Nuevo récord!».
- **Diseño adaptable** a distintos tamaños de pantalla.
- **PWA:** instalable y con caché para funcionar sin conexión.

No hay condición de derrota: no existe límite de tiempo ni de movimientos, y
todos los tableros tienen solución.

## Cómo se guardan los récords

Cada dificultad guarda dos récords **independientes**: el mejor tiempo y el
menor número de movimientos (pueden venir de partidas distintas), cada uno con
la fecha de la partida en la que se logró. Un récord solo se reemplaza si el
resultado es **estrictamente mejor**; un empate conserva el récord anterior y su
fecha.

## Limitaciones

- **Las preferencias no se conservan al cerrar la aplicación** (dificultad,
  tema, estilo de fichas, animaciones y sonido). El enunciado permite el paquete
  de almacenamiento local exclusivamente para los marcadores, y así se ha
  aplicado: `shared_preferences` se usa solo para los récords.
- **Sonido:** usa el clic del sistema (sin paquetes de audio). Funciona en
  Android e iOS; en el navegador puede no oírse.
- **Modo imagen** para las fichas (opcional en el enunciado): no implementado.

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) 3.22 o superior
  (canal estable).
- Para la versión web: Google Chrome.
- Para móvil: un emulador o dispositivo (Android Studio o Xcode).

Comprueba tu instalación con `flutter doctor`.

## Instalación y ejecución

```bash
git clone <URL-del-repositorio>
cd <carpeta-del-repositorio>
flutter pub get

flutter run -d chrome      # navegador
flutter run                # dispositivo o emulador conectado
```

## Pruebas y calidad

```bash
dart format .
flutter analyze
flutter test
```

Las pruebas cubren la lógica del tablero y de la partida, los récords y su
almacenamiento, las pantallas, un flujo completo con una partida real y la
ausencia de desbordes en varios tamaños de pantalla. El detalle y la lista de
comprobaciones manuales están en [`docs/VERIFICACION.md`](docs/VERIFICACION.md).

## Compilación web

```bash
flutter build web --release --base-href "/NOMBRE-DEL-REPOSITORIO/"
bash scripts/verificar_pwa.sh build/web "/NOMBRE-DEL-REPOSITORIO/"
```

El `--base-href` debe coincidir con el nombre del repositorio, porque GitHub
Pages publica el sitio en `https://USUARIO.github.io/NOMBRE-DEL-REPOSITORIO/`.
(Si el repositorio se llama `USUARIO.github.io`, la ruta base es `/`.)

## Despliegue en GitHub Pages

El workflow [`.github/workflows/desplegar.yml`](.github/workflows/desplegar.yml)
hace lo siguiente:

1. **En cada push a `main` y en cada pull request:** instala Flutter, resuelve
   dependencias, analiza el código, ejecuta las pruebas, compila la versión web
   con la ruta base del repositorio y verifica los requisitos de PWA.
2. **Solo en push a `main` (o ejecución manual):** publica el resultado en
   GitHub Pages.

Configuración única en GitHub:

1. Abre **Settings → Pages**.
2. En **Build and deployment → Source**, elige **GitHub Actions**.
3. Haz push a `main` y revisa la pestaña **Actions**.

## Verificación de la PWA

El script `scripts/verificar_pwa.sh` (que ejecuta el workflow) comprueba que la
compilación incluye un `manifest.json` válido con nombre, `display`
instalable e iconos de 192 y 512 px, que `index.html` lo enlaza y usa la ruta
base correcta, y que existen `flutter_service_worker.js` y `main.dart.js`.

Eso solo confirma que **los archivos están**. Para comprobar el comportamiento
real, con el sitio publicado:

1. **Instalación:** abre el sitio en Chrome; debe aparecer la opción de instalar
   en la barra de direcciones o en el menú (⋮ → «Instalar 15-Puzzle Flutter»).
2. **Sin conexión:** abre el sitio una vez con internet, abre DevTools →
   **Application → Service Workers** y confirma que está activado. Marca
   **Offline** (o desconecta la red) y recarga: la aplicación debe seguir
   funcionando.
3. **Lighthouse** (DevTools → Lighthouse → categoría PWA) como segunda opinión.

## Estructura del proyecto

```
lib/
  main.dart                  Punto de entrada
  aplicacion.dart            Raíz: MaterialApp, tema y estado compartido
  nucleo/
    logica/                  Dificultad, Tablero y Partida (sin Flutter)
    records/                 Récords, almacenamiento y servicio
    ajustes/                 Preferencias en memoria y su proveedor
    tema/                    Temas claro y oscuro (Material 3)
    utilidades/              Formato de tiempo y fecha, sonido
    widgets/, rutas.dart     Componentes comunes y navegación
  funcionalidades/
    presentacion/ menu/ juego/ configuracion/ marcadores/ instrucciones/
test/                        Pruebas automatizadas
docs/VERIFICACION.md         Lista de comprobaciones
scripts/verificar_pwa.sh     Verificación de requisitos PWA
.github/workflows/           Integración y despliegue continuos
```

## Decisiones técnicas

- **Lógica separada de la interfaz:** `Tablero` es inmutable y `Partida` recibe
  un reloj inyectable, de modo que el cronómetro se prueba sin esperas reales.
- **Estado:** se usa `setState` solo en pantallas con estado local (la partida y
  el botón del menú). Los ajustes y los récords viven en objetos
  `ChangeNotifier` expuestos con `InheritedNotifier`, sin paquetes de gestión de
  estado.
- **Dependencias mínimas:** solo `shared_preferences` (para los marcadores).
  Las animaciones usan los widgets de animación incluidos en Flutter.
- **Tableros resolubles:** se mezclan las fichas y, si la paridad de inversiones
  no es correcta, se intercambian dos fichas.

## Flujo de trabajo en Git

Se trabaja con ramas (`main` para lo publicado, `develop` para integración y
ramas `feature/...` para cada funcionalidad) y commits pequeños y significativos
con mensajes descriptivos.
