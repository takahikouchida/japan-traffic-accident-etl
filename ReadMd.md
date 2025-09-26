# japan-traffic-accident-etl

**目的**: 交通事故のCSVを **PostGIS（Docker）** に「確実に」取り込む。  

## クイックスタート

```bash
cp .env.example .env
docker compose up -d --build
```


# 例1: Shift-JIS(CP932) の本票CSVをカンマ区切りで取り込み
```
make import CSV=data/source/honhyo_2024.csv TABLE=accidents_2024_raw ENCODING=CP932 DELIM=COMMA
```

# 例2: UTF-8 / タブ区切り
```
make import CSV=data/source/honhyo_2024_utf8.tsv TABLE=accidents_2024_raw ENCODING=UTF-8 DELIM=TAB
```

