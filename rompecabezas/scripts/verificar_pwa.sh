#!/usr/bin/env bash
# Comprueba que la compilación web conserva lo necesario para ser una PWA
# instalable con caché sin conexión.
#
# Uso: bash scripts/verificar_pwa.sh [carpeta_de_compilacion] [base_href]
#   carpeta_de_compilacion  por defecto: build/web
#   base_href               por defecto: /
#
# Requiere bash y python3 (ambos disponibles en los runners de GitHub).
#
# Esto verifica la PRESENCIA y coherencia de los archivos. El comportamiento
# real (instalación y uso sin conexión) debe comprobarse además en un
# navegador; ver el README.
set -uo pipefail

dir="${1:-build/web}"
base="${2:-/}"
errores=0

ok()    { echo "OK     $1"; }
fallo() { echo "::error::$1"; errores=$((errores + 1)); }

[ -d "$dir" ] || { echo "::error::No existe la carpeta $dir"; exit 1; }

# --- Manifest ---------------------------------------------------------------
manifest="$dir/manifest.json"
if [ ! -f "$manifest" ]; then
  fallo "Falta $manifest"
else
  salida="$(python3 - "$manifest" "$dir" <<'PY'
import json, os, sys

ruta, carpeta = sys.argv[1], sys.argv[2]
try:
    with open(ruta, encoding="utf-8") as f:
        m = json.load(f)
except Exception as e:
    print(f"FALLO manifest.json no es un JSON válido ({e})")
    sys.exit(0)
if not isinstance(m, dict):
    print("FALLO manifest.json debe ser un objeto JSON")
    sys.exit(0)

print("OK manifest.json es JSON válido")
for campo in ("name", "short_name", "start_url", "display",
              "theme_color", "background_color"):
    valor = m.get(campo)
    if valor:
        print(f"OK manifest.{campo} = {valor}")
    else:
        print(f'FALLO manifest.json no define "{campo}"')

modo = m.get("display", "")
if modo in ("standalone", "fullscreen", "minimal-ui"):
    print(f"OK display permite la instalación ({modo})")
else:
    print(f'FALLO display debe ser standalone, fullscreen o minimal-ui (es "{modo}")')

iconos = m.get("icons") or []
for tam in ("192x192", "512x512"):
    if any(isinstance(i, dict) and i.get("sizes") == tam for i in iconos):
        print(f"OK hay icono de {tam}")
    else:
        print(f"FALLO falta un icono de {tam} en el manifest")
for i in iconos:
    src = i.get("src", "") if isinstance(i, dict) else ""
    if not src:
        continue
    if os.path.isfile(os.path.join(carpeta, src)):
        print(f"OK existe {src}")
    else:
        print(f"FALLO el manifest referencia {src} pero no existe")
PY
)"
  while IFS= read -r linea; do
    case "$linea" in
      OK\ *)    ok "${linea#OK }" ;;
      FALLO\ *) fallo "${linea#FALLO }" ;;
    esac
  done <<< "$salida"
fi

# --- index.html -------------------------------------------------------------
indice="$dir/index.html"
if [ ! -f "$indice" ]; then
  fallo "Falta $indice"
else
  if grep -q 'rel="manifest"' "$indice"; then
    ok "index.html enlaza el manifest"
  else
    fallo "index.html no enlaza manifest.json"
  fi

  if grep -qF "<base href=\"$base\">" "$indice"; then
    ok "base href correcto ($base)"
  else
    fallo "index.html no contiene <base href=\"$base\"> (revisa --base-href)"
  fi
fi

# --- Service worker y código de la app --------------------------------------
if [ -f "$dir/flutter_service_worker.js" ]; then
  ok "existe flutter_service_worker.js"
else
  fallo "Falta flutter_service_worker.js (sin él no hay caché sin conexión)"
fi

if [ -f "$dir/main.dart.js" ]; then
  ok "existe main.dart.js"
else
  fallo "Falta main.dart.js"
fi

# --- Resultado --------------------------------------------------------------
if [ "$errores" -gt 0 ]; then
  echo "Verificación PWA: $errores problema(s)."
  exit 1
fi
echo "Verificación PWA: correcta."
