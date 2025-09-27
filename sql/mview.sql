CREATE MATERIALIZED VIEW accidents_2024_with_parties AS
WITH parties AS (
  SELECT
    h.資料区分,
    h.都道府県コード,
    h.警察署等コード,
    h.本票番号,
    CASE WHEN h.補充票番号 = '1' THEN 'A'
         WHEN h.補充票番号 = '2' THEN 'B'
         ELSE 'X' END AS party_label,
    h.当事者種別,
    h.用途別,
    h.車両形状等,
    h.乗車別,
    h.人身損傷程度,
    h.車両の衝突部位,
    h.車両の損壊程度,
    h.エアバッグの装備,
    h.サイドエアバッグの装備
  FROM hojuhyo_2024_raw h
)
SELECT
    a.*,
    pA.当事者種別        AS partyA_type,
    pA.用途別           AS partyA_use,
    pA.車両形状等        AS partyA_vehicle,
    pA.乗車別           AS partyA_ride,
    pA.人身損傷程度       AS partyA_injury,
    pA.車両の衝突部位     AS partyA_collision,
    pA.車両の損壊程度     AS partyA_damage,
    pA.エアバッグの装備   AS partyA_airbag,
    pA.サイドエアバッグの装備 AS partyA_side_airbag,
    pB.当事者種別        AS partyB_type,
    pB.用途別           AS partyB_use,
    pB.車両形状等        AS partyB_vehicle,
    pB.乗車別           AS partyB_ride,
    pB.人身損傷程度       AS partyB_injury,
    pB.車両の衝突部位     AS partyB_collision,
    pB.車両の損壊程度     AS partyB_damage,
    pB.エアバッグの装備   AS partyB_airbag,
    pB.サイドエアバッグの装備 AS partyB_side_airbag
FROM accidents_2024_raw a
         LEFT JOIN parties pA
                   ON a.資料区分 = pA.資料区分
                       AND a.都道府県コード = pA.都道府県コード
                       AND a.警察署等コード = pA.警察署等コード
                       AND a.本票番号 = pA.本票番号
                       AND pA.party_label = 'A'
         LEFT JOIN parties pB
                   ON a.資料区分 = pB.資料区分
                       AND a.都道府県コード = pB.都道府県コード
                       AND a.警察署等コード = pB.警察署等コード
                       AND a.本票番号 = pB.本票番号
                       AND pB.party_label = 'B';



-- 都道府県（codebookの一覧に対応）
CREATE TABLE dim_pref (
                          pref_code TEXT PRIMARY KEY,
                          pref_name TEXT NOT NULL
);

-- 警察署等（都道府県別のコードを持つため複合PK）
CREATE TABLE dim_police (
                            pref_code TEXT NOT NULL,
                            ps_code   TEXT NOT NULL,
                            ps_name   TEXT NOT NULL,
                            PRIMARY KEY (pref_code, ps_code)
);

-- 事故内容（1=死亡, 2=負傷）
CREATE TABLE dim_accident_type (
                                   code  TEXT PRIMARY KEY,
                                   label TEXT NOT NULL
);

-- 天候・路面・道路形状など（必要に応じて）
CREATE TABLE dim_weather (code TEXT PRIMARY KEY, label TEXT NOT NULL);
CREATE TABLE dim_road_surface (code TEXT PRIMARY KEY, label TEXT NOT NULL);
CREATE TABLE dim_road_shape   (code TEXT PRIMARY KEY, label TEXT NOT NULL);

-- 当事者関連
CREATE TABLE dim_party_type   (code TEXT PRIMARY KEY, label TEXT NOT NULL);   -- 当事者種別
CREATE TABLE dim_usage        (code TEXT PRIMARY KEY, label TEXT NOT NULL);   -- 用途別
CREATE TABLE dim_vehicle_shape(code TEXT PRIMARY KEY, label TEXT NOT NULL);   -- 車両形状
CREATE TABLE dim_injury       (code TEXT PRIMARY KEY, label TEXT NOT NULL);   -- 人身損傷程度
CREATE TABLE dim_airbag       (code TEXT PRIMARY KEY, label TEXT NOT NULL);   -- エアバッグ
CREATE TABLE dim_side_airbag  (code TEXT PRIMARY KEY, label TEXT NOT NULL);   -- サイドエアバッグ



-- 都道府県（47件）
INSERT INTO dim_pref (pref_code, pref_name) VALUES
                                                ('01','北海道'),
                                                ('02','青森'),
                                                ('03','岩手'),
                                                ('04','宮城'),
                                                ('05','秋田'),
                                                ('06','山形'),
                                                ('07','福島'),
                                                ('08','茨城'),
                                                ('09','栃木'),
                                                ('10','群馬'),
                                                ('11','埼玉'),
                                                ('12','千葉'),
                                                ('13','東京'),
                                                ('14','神奈川'),
                                                ('15','新潟'),
                                                ('16','富山'),
                                                ('17','石川'),
                                                ('18','福井'),
                                                ('19','山梨'),
                                                ('20','長野'),
                                                ('21','岐阜'),
                                                ('22','静岡'),
                                                ('23','愛知'),
                                                ('24','三重'),
                                                ('25','滋賀'),
                                                ('26','京都'),
                                                ('27','大阪'),
                                                ('28','兵庫'),
                                                ('29','奈良'),
                                                ('30','和歌山'),
                                                ('31','鳥取'),
                                                ('32','島根'),
                                                ('33','岡山'),
                                                ('34','広島'),
                                                ('35','山口'),
                                                ('36','徳島'),
                                                ('37','香川'),
                                                ('38','愛媛'),
                                                ('39','高知'),
                                                ('40','福岡'),
                                                ('41','佐賀'),
                                                ('42','長崎'),
                                                ('43','熊本'),
                                                ('44','大分'),
                                                ('45','宮崎'),
                                                ('46','鹿児島'),
                                                ('47','沖縄');

-- 事故内容（codebook 2024）
INSERT INTO dim_accident_type (code, label) VALUES
                                                ('1','死亡'),
                                                ('2','負傷');

-- エアバッグ（当事者別項目）
INSERT INTO dim_airbag (code, label) VALUES
                                         ('0','対象外当事者'),
                                         ('1','装備あり・作動'),
                                         ('2','その他');

-- サイドエアバッグ（当事者別項目）
INSERT INTO dim_side_airbag (code, label) VALUES
                                              ('0','対象外当事者'),
                                              ('1','装備あり・作動'),
                                              ('2','その他');








-- 都道府県
COPY dim_pref(pref_code, pref_name)
    FROM PROGRAM 'cat /work/dim/dim_pref.csv | tail -n +2'
    WITH (FORMAT csv);

-- 警察署等
COPY dim_police(pref_code, ps_code, ps_name)
    FROM PROGRAM 'cat /work/dim/dim_police.csv | tail -n +2'
    WITH (FORMAT csv);

-- 事故内容
COPY dim_accident_type(code, label)
    FROM PROGRAM 'cat /work/dim/dim_accident_type.csv | tail -n +2'
    WITH (FORMAT csv);

-- 天候
COPY dim_weather(code, label)
    FROM PROGRAM 'cat /work/dim/dim_weather.csv | tail -n +2'
    WITH (FORMAT csv);

-- 路面
COPY dim_road_surface(code, label)
    FROM PROGRAM 'cat /work/dim/dim_road_surface.csv | tail -n +2'
    WITH (FORMAT csv);

-- 道路形状
COPY dim_road_shape(code, label)
    FROM PROGRAM 'cat /work/dim/dim_road_shape.csv | tail -n +2'
    WITH (FORMAT csv);

-- 当事者種別
COPY dim_party_type(code, label)
    FROM PROGRAM 'cat /work/dim/dim_party_type.csv | tail -n +2'
    WITH (FORMAT csv);

-- 用途別
COPY dim_usage(code, label)
    FROM PROGRAM 'cat /work/dim/dim_usage.csv | tail -n +2'
    WITH (FORMAT csv);

-- 車両形状
COPY dim_vehicle_shape(code, label)
    FROM PROGRAM 'cat /work/dim/dim_vehicle_shape.csv | tail -n +2'
    WITH (FORMAT csv);

-- 人身損傷程度
COPY dim_injury(code, label)
    FROM PROGRAM 'cat /work/dim/dim_injury.csv | tail -n +2'
    WITH (FORMAT csv);

-- エアバッグ
COPY dim_airbag(code, label)
    FROM PROGRAM 'cat /work/dim/dim_airbag.csv | tail -n +2'
    WITH (FORMAT csv);

-- サイドエアバッグ
COPY dim_side_airbag(code, label)
    FROM PROGRAM 'cat /work/dim/dim_side_airbag.csv | tail -n +2'
    WITH (FORMAT csv);



