---

## `scripts/import_csv.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

CSV_PATH="${1:?CSV path required}"
TABLE_NAME="${2:?Table name required}"
ENCODING="${3:-UTF-8}"   # 例: CP932, UTF-8
DELIM="${4:-COMMA}"      # COMMA | TAB | SEMICOLON | SPACE | PIPE など

# DELIMマッピング
case "$DELIM" in
  COMMA)     SEP="SEPARATOR=COMMA" ;;
  TAB)       SEP="SEPARATOR=TAB" ;;
  SEMICOLON) SEP="SEPARATOR=SEMICOLON" ;;
  SPACE)     SEP="SEPARATOR=SPACE" ;;
  PIPE)      SEP="SEPARATOR=PIPE" ;;
  *)         echo "Unsupported DELIM: $DELIM"; exit 1 ;;
esac

# GDAL CSV driver options:
# -oo ENCODING=...         : 文字コード指定（CP932等）
# -oo AUTODETECT_TYPE=YES  : 列型自動推定
# -oo KEEP_GEOM_COLUMNS=NO : 幾何列の自動扱い無効（CSVなので念のため）
# -lco 指定                : PG側の作成時オプション（スキーマなど必要なら追記）

echo "[INFO] Importing CSV -> PostGIS"
echo "  CSV      : $CSV_PATH"
echo "  TABLE    : $TABLE_NAME"
echo "  ENCODING : $ENCODING"
echo "  DELIM    : $DELIM"

ogr2ogr -f "PostgreSQL" \
  PG:"host=${PGHOST} dbname=${PGDATABASE} user=${PGUSER} password=${PGPASSWORD} port=${PGPORT:-5432}" \
  "$CSV_PATH" \
  -nln "$TABLE_NAME" \
  -overwrite \
  -oo ENCODING="$ENCODING" \
  -oo AUTODETECT_TYPE=YES \
  -oo "$SEP" \
  -oo KEEP_GEOM_COLUMNS=NO

echo "[OK] Imported to table: $TABLE_NAME"