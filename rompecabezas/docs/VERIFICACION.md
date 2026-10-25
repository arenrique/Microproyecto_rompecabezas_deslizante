# Verificación del proyecto

Este documento separa lo que comprueban las **pruebas automatizadas** de lo que
hay que comprobar **a mano**. Rellena la columna *Resultado* al ejecutar cada
punto; no marques nada que no hayas hecho realmente.

## 1. Comprobaciones automáticas

Ejecutar desde la raíz del proyecto:

| Comando | Qué comprueba | Resultado |
|---|---|---|
| `flutter pub get` | Dependencias resueltas | _pendiente_ |
| `dart format --set-exit-if-changed .` | Formato del código | _pendiente_ |
| `flutter analyze` | Errores y avisos del analizador | _pendiente_ |
| `flutter test` | Todas las pruebas (lógica, interfaz, integración) | _pendiente_ |
| `flutter build web --release` | Compilación web | _pendiente_ |

### Cobertura de las pruebas

| Área | Archivo de pruebas |
|---|---|
| Tablero: tamaños 3×3, 4×4 y 5×5, movimientos válidos e inválidos, victoria, resolubilidad, generación aleatoria | `test/logica/tablero_test.dart` |
| Partida: contador de movimientos, inicio y fin del cronómetro, reinicio | `test/logica/partida_test.dart` |
| Récords: mejora independiente, empates, JSON, almacenamiento, servicio | `test/records/` |
| Ajustes | `test/ajustes/ajustes_test.dart`, `test/configuracion/` |
| Pantallas: juego, marcadores, instrucciones, selector de dificultad | `test/juego/`, `test/marcadores/`, `test/instrucciones/`, `test/menu/` |
| Flujo completo con una partida real resuelta por un resolutor de pruebas | `test/integracion/flujo_completo_test.dart` |
| Ausencia de desbordes en 5 tamaños de ventana y en tema claro y oscuro | `test/responsive/pantallas_responsive_test.dart` |

## 2. Comprobaciones manuales

| # | Comprobación | Plataforma | Resultado |
|---|---|---|---|
| 1 | Splash: título, animación, botón «Saltar» y paso automático | Chrome | _pendiente_ |
| 2 | Partida completa en Fácil, Medio y Difícil hasta ganar | Chrome | _pendiente_ |
| 3 | Diálogo «¡Ganaste!» y aviso «¡Nuevo récord!» | Chrome | _pendiente_ |
| 4 | Los récords siguen ahí tras cerrar y volver a abrir la app | Chrome | _pendiente_ |
| 5 | Cambiar tema (claro, oscuro, automático) y estilo de fichas | Chrome | _pendiente_ |
| 6 | Tema automático sigue al del sistema operativo | Chrome / SO | _pendiente_ |
| 7 | Redimensionar la ventana de móvil a escritorio sin desbordes | Chrome | _pendiente_ |
| 8 | App en un emulador o dispositivo Android | Android | _pendiente_ |
| 9 | App en iOS (si hay Mac disponible) | iOS | _pendiente_ |
| 10 | Efecto de sonido al mover (si está activado) | Android / iOS | _pendiente_ |

## 3. Limitaciones conocidas

- Las preferencias (dificultad, tema, estilo, animaciones y sonido) **no se
  guardan** al cerrar la aplicación: el PDF permite el paquete de
  almacenamiento solo para los marcadores.
- El sonido usa el clic del sistema; en navegador puede no oírse.
- El modo imagen para las fichas (opcional en el enunciado) no está
  implementado.
