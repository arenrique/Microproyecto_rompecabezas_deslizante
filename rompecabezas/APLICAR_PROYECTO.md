# Proyecto completo (commits 1 a 8 fusionados)

Este archivo contiene el estado final de todos los archivos tras aplicar los
ocho commits en orden. Sirve para **comprobar el proyecto entero de una vez**.
Si ya fuiste aplicando commit a commit, no hace falta: el resultado es el mismo.

## 1. Preparar un proyecto Flutter

Con el nombre de paquete `rompecabezas` (los imports de las pruebas lo usan):

```bash
flutter create --project-name rompecabezas --platforms=web,android,ios .
```

Si ya tienes el proyecto con otro nombre, cambia `name:` en `pubspec.yaml` a
`rompecabezas`.

## 2. Copiar los archivos

1. Borra la prueba de ejemplo que genera Flutter: `test/widget_test.dart`.
2. Descomprime este zip en la raíz del proyecto (sobrescribiendo).
3. Si vienes de los commits 1 a 5, borra el archivo ya sin uso
   `lib/nucleo/widgets/seccion_provisional.dart` (este zip no lo incluye).

## 3. Añadir la única dependencia

```bash
flutter pub add shared_preferences
```

## 4. Edición manual de `web/index.html`

Solo para la parte web. No toques `<base href>` ni los `<script>`:

- `<html lang="es">`
- `<title>15-Puzzle Flutter</title>`
- un `<meta name="description" ...>` en español
- `<meta name="theme-color" content="#4F46E5">`

## 5. Comprobar

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run -d chrome
```

Para la compilación web y la verificación de la PWA:

```bash
flutter build web --release --base-href "/NOMBRE-DEL-REPOSITORIO/"
bash scripts/verificar_pwa.sh build/web "/NOMBRE-DEL-REPOSITORIO/"
```

## Mapa de archivos

```
lib/
  main.dart                               (1)  punto de entrada
  aplicacion.dart                         (1,4,5) MaterialApp, ajustes y récords
  nucleo/
    logica/        dificultad.dart, tablero.dart (2) · partida.dart (3)
    records/       records_dificultad, almacen_records, servicio_records,
                   proveedor_records (5)
    ajustes/       estilo_ficha, ajustes_aplicacion, proveedor_ajustes (4)
    tema/          tema_aplicacion.dart (1)
    utilidades/    formato.dart (3,5) · sonido.dart (4)
    rutas.dart                              (1,3)
  funcionalidades/
    presentacion/  pantalla_presentacion.dart (1)
    menu/          pantalla_menu_principal.dart, selector_dificultad.dart (1,4)
    juego/         pantalla_juego.dart (3,4,5,6)
      widgets/     vista_tablero (3,4,7), ficha_vista (3,4), dialogo_victoria (6)
    configuracion/ pantalla_configuracion.dart (4,7)
    marcadores/    pantalla_marcadores.dart (5)
    instrucciones/ pantalla_instrucciones.dart, widgets/mini_tablero.dart (6)
test/
  navegacion_inicial_test.dart (1,6) · logica/ (2,3) · juego/ (3-6)
  ajustes/ configuracion/ menu/ (4) · records/ marcadores/ utilidades/ (5)
  instrucciones/ (6) · ayudas/ integracion/ responsive/ (7)
docs/VERIFICACION.md                      (7)
web/manifest.json · scripts/verificar_pwa.sh
.github/workflows/desplegar.yml · README.md   (8)
```

Entre paréntesis, el número de commit que introdujo o modificó cada archivo.
