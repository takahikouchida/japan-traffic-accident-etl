include .env

DC := docker compose
ETL := $(DC) run --rm etl
PSQL := $(DC) exec db psql -U $(PGUSER) -d $(PGDATABASE)

.PHONY: up down sh dbsh import

up:
	$(DC) up -d --build

down:
	$(DC) down

sh:
	$(ETL) bash

dbsh:
	$(DC) exec -it db bash

# 使い方例:
# make import CSV=data/source/honhyo_2024.csv TABLE=accidents_2024_raw ENCODING=CP932 DELIM=COMMA
# DELIM: COMMA|TAB|SEMICOLON など
import:
	@[ -n "$(CSV)" ] || (echo "CSV= パスを指定してください"; exit 1)
	@[ -n "$(TABLE)" ] || (echo "TABLE= 作成するテーブル名を指定してください"; exit 1)
	$(ETL) bash scripts/import_csv.sh "$(CSV)" "$(TABLE)" "$(ENCODING)" "$(DELIM)"