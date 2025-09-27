# japan-traffic-accident-etl

**目的**: 交通事故のCSVを **PostGIS（Docker）** に「確実に」取り込む。  

## クイックスタート

```bash
cp .env.example .env
docker compose up -d --build

docker compose run --rm etl ogr2ogr --version

docker compose run --rm etl bash

```


# 例1: Shift-JIS(CP932) の本票CSVをカンマ区切りで取り込み
# Docker
```bash
# 1) CP932 → UTF-8 に変換（出力先: /work/data/tmp/honhyo_2024_utf8.csv）
docker compose run --rm etl bash -lc '
  mkdir -p /work/data/tmp && \
  iconv -f CP932 -t UTF-8 \
    /work/data/source/2024/honhyo_2024.csv \
    -o /work/data/tmp/honhyo_2024_utf8.csv && \
  head -n 3 /work/data/tmp/honhyo_2024_utf8.csv
'

# 2) 変換済みCSVをインポート（UTF-8として読み込み）
docker compose run --rm etl ogr2ogr \
  -f "PostgreSQL" \
  "PG:host=db dbname=${PGDATABASE:-traffic} user=${PGUSER:-postgres} password=${PGPASSWORD:-postgres} port=${PGPORT:-5432}" \
  /work/data/tmp/honhyo_2024_utf8.csv \
  -nln accidents_2024_raw \
  -overwrite \
  -oo ENCODING=UTF-8 \
  -oo AUTODETECT_TYPE=YES \
  -oo SEPARATOR=COMMA \
  -oo KEEP_GEOM_COLUMNS=NO
```

# 例2: Shift-JIS(CP932) の補充票CSV（hojuhyo）をカンマ区切りで取り込み
# Docker
```bash
# 1) CP932 → UTF-8 に変換（出力先: /work/data/tmp/hojuhyo_2024_utf8.csv）
docker compose run --rm etl bash -lc '
  mkdir -p /work/data/tmp && \
  iconv -f CP932 -t UTF-8 \
    /work/data/source/2024/hojuhyo_2024.csv \
    -o /work/data/tmp/hojuhyo_2024_utf8.csv && \
  head -n 3 /work/data/tmp/hojuhyo_2024_utf8.csv
'

# 2) 変換済みCSVをインポート（UTF-8として読み込み）
docker compose run --rm etl ogr2ogr \
  -f "PostgreSQL" \
  "PG:host=db dbname=${PGDATABASE:-traffic} user=${PGUSER:-postgres} password=${PGPASSWORD:-postgres} port=${PGPORT:-5432}" \
  /work/data/tmp/hojuhyo_2024_utf8.csv \
  -nln hojuhyo_2024_raw \
  -overwrite \
  -oo ENCODING=UTF-8 \
  -oo AUTODETECT_TYPE=YES \
  -oo SEPARATOR=COMMA \
  -oo KEEP_GEOM_COLUMNS=NO
```

# 例3: Shift-JIS(CP932) の高速票CSV（kosokuhyo）をカンマ区切りで取り込み
# Docker
```bash
# 1) CP932 → UTF-8 に変換（出力先: /work/data/tmp/kosokuhyo_2024_utf8.csv）
docker compose run --rm etl bash -lc '
  mkdir -p /work/data/tmp && \
  iconv -f CP932 -t UTF-8 \
    /work/data/source/2024/kosokuhyo_2024.csv \
    -o /work/data/tmp/kosokuhyo_2024_utf8.csv && \
  head -n 3 /work/data/tmp/kosokuhyo_2024_utf8.csv
'

# 2) 変換済みCSVをインポート（UTF-8として読み込み）
docker compose run --rm etl ogr2ogr \
  -f "PostgreSQL" \
  "PG:host=db dbname=${PGDATABASE:-traffic} user=${PGUSER:-postgres} password=${PGPASSWORD:-postgres} port=${PGPORT:-5432}" \
  /work/data/tmp/kosokuhyo_2024_utf8.csv \
  -nln kosokuhyo_2024_raw \
  -overwrite \
  -oo ENCODING=UTF-8 \
  -oo AUTODETECT_TYPE=YES \
  -oo SEPARATOR=COMMA \
  -oo KEEP_GEOM_COLUMNS=NO
```
