
/*
Кораблев Денис Андреевич
Вариант 4 — хранение товаров на складе.

Условие задания
Выберите номера стеллажей, а также объём одного места и суммарный объём всех мест на каждом из них.
Выберите названия юр. лиц всех клиентов и количество их товаров на стеллажах.
*/

-- Для помещения указываются название, полезный объём, температурные
-- и влажностные условия.
CREATE TABLE rooms (
    room_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL CHECK (name <> ''),
    usable_volume_m3 NUMERIC(12, 3) NOT NULL CHECK (usable_volume_m3 > 0),
    min_temperature_c NUMERIC(5, 2) NOT NULL,
    max_temperature_c NUMERIC(5, 2) NOT NULL,
    min_wet_pct NUMERIC(5, 2) NOT NULL,
    max_wet_pct NUMERIC(5, 2) NOT NULL,

    CHECK (min_temperature_c <= max_temperature_c),
    CHECK (
        0 <= min_wet_pct
        AND min_wet_pct <= max_wet_pct
        AND max_wet_pct <= 100
    )
);


-- Для стеллажа указываются номер, помещение,
-- количество мест, высота, ширина и длина одного места, а также
-- максимальная суммарная нагрузка.
CREATE TABLE racks (
    rack_id INTEGER PRIMARY KEY,
    room_id INTEGER NOT NULL REFERENCES rooms (room_id),
    rack_number INTEGER NOT NULL CHECK (rack_number > 0),
    slot_count INTEGER NOT NULL CHECK (slot_count > 0),
    slot_height_cm NUMERIC(12, 3) NOT NULL CHECK (slot_height_cm > 0),
    slot_width_cm NUMERIC(12, 3) NOT NULL CHECK (slot_width_cm > 0),
    slot_length_cm NUMERIC(12, 3) NOT NULL CHECK (slot_length_cm > 0),
    max_load_kg NUMERIC(12, 3) NOT NULL CHECK (max_load_kg > 0),

    UNIQUE (room_id, rack_number)
);


-- Для клиента указываются название юридического лица и банковские
-- реквизиты в виде текста.
CREATE TABLE clients (
    client_id INTEGER PRIMARY KEY,
    legal_name TEXT NOT NULL,
    bank_details TEXT NOT NULL
);

-- Для товара указываются высота, ширина,
-- длина, вес, дата поступления, номер договора, клиент, дата окончания
-- договора, температурные и влажностные условия хранения, стеллаж
-- и целочисленная позиция на нём. На одном стеллаже могут храниться
-- товары разных клиентов.
CREATE TABLE goods (
    goods_id INTEGER PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES clients (client_id),
    rack_id INTEGER NOT NULL REFERENCES racks (rack_id),
    rack_position INTEGER NOT NULL CHECK (rack_position > 0),
    height_cm NUMERIC(12, 3) NOT NULL CHECK (height_cm > 0),
    width_cm NUMERIC(12, 3) NOT NULL CHECK (width_cm > 0),
    length_cm NUMERIC(12, 3) NOT NULL CHECK (length_cm > 0),
    weight_kg NUMERIC(12, 3) NOT NULL CHECK (weight_kg > 0),
    received_on DATE NOT NULL DEFAULT CURRENT_DATE,
    contract_number TEXT NOT NULL,
    contract_expires_on DATE NOT NULL,
    min_temperature_c NUMERIC(5, 2) NOT NULL,
    max_temperature_c NUMERIC(5, 2) NOT NULL,
    min_wet_pct NUMERIC(5, 2) NOT NULL,
    max_wet_pct NUMERIC(5, 2) NOT NULL,

    UNIQUE (rack_id, rack_position),
    CHECK (received_on <= contract_expires_on),
    CHECK (min_temperature_c <= max_temperature_c),
    CHECK (
        0 <= min_wet_pct
        AND min_wet_pct <= max_wet_pct
        AND max_wet_pct <= 100
    )
);


INSERT INTO rooms (
    room_id, name, usable_volume_m3,
    min_temperature_c, max_temperature_c, min_wet_pct, max_wet_pct
) VALUES
    (1, 'Склад бакалеи',                480,  15,  20, 40, 60),
    (2, 'Камера охлаждения',            160,   2,   4, 60, 70),
    (3, 'Морозильная камера',           140, -24, -20, 65, 80),
    (4, 'Склад упаковки',               300,  16,  22, 40, 60),
    (5, 'Склад хозяйственных товаров',  420,  15,  25, 35, 65);

INSERT INTO racks (
    rack_id, room_id, rack_number, slot_count,
    slot_height_cm, slot_width_cm, slot_length_cm, max_load_kg
) VALUES
    (1, 1, 101,  8, 160,  90, 130, 4000),
    (2, 2, 201,  6, 150,  90, 130, 3000),
    (3, 3, 301,  6, 155,  90, 130, 3600),
    (4, 4, 401,  8, 180, 100, 140, 2400),
    (5, 5, 501, 10, 170, 100, 140, 3500);

INSERT INTO clients (client_id, legal_name, bank_details) VALUES
    (1, 'ООО «Северная бакалея»', 'АО «Учебный банк», БИК 000000000, р/с 40702**********00001'),
    (2, 'ООО «Городские продукты»', 'АО «Учебный банк», БИК 000000000, р/с 40702**********00002'),
    (3, 'ООО «Полярные овощи»', 'АО «Учебный банк», БИК 000000000, р/с 40702**********00003'),
    (4, 'ООО «Картон Плюс»', 'АО «Учебный банк», БИК 000000000, р/с 40702**********00004'),
    (5, 'ООО «Товары для дома»', 'АО «Учебный банк», БИК 000000000, р/с 40702**********00005'),
    (6, 'ООО «Линия поставок»', 'АО «Учебный банк», БИК 000000000, р/с 40702**********00006');

INSERT INTO goods (
    goods_id, client_id, rack_id, rack_position,
    height_cm, width_cm, length_cm, weight_kg,
    received_on, contract_number, contract_expires_on,
    min_temperature_c, max_temperature_c, min_wet_pct, max_wet_pct
) VALUES
    (1, 1, 1, 1, 125, 80, 120, 250, '2026-11-03', 'ХР-101', '2027-01-31',  10,  25, 35, 65),
    (2, 2, 1, 2, 110, 80, 120, 420, '2026-11-04', 'ХР-102', '2027-01-31',  10,  25, 35, 65),
    (3, 2, 2, 1, 105, 80, 120, 310, '2026-11-09', 'ХР-103', '2026-11-13',   2,   4, 55, 80),
    (4, 3, 3, 1, 120, 80, 120, 380, '2026-11-06', 'ХР-104', '2027-02-28', -25, -18, 60, 85),
    (5, 4, 4, 1, 145, 80, 120, 160, '2026-11-05', 'ХР-105', '2027-03-31',  10,  25, 35, 65),
    (6, 5, 5, 1, 135, 80, 120, 190, '2026-11-07', 'ХР-106', '2027-02-28',   5,  30, 30, 75),
    (7, 2, 1, 3, 95, 60, 80, 145, '2026-11-08', 'ХР-102', '2027-01-31', 10, 25, 35, 65);

-- Выберите номера стеллажей, а также объём одного места и суммарный объём всех мест на каждом из них.
SELECT rack_number as "Номер стеллажа", slot_height_cm * slot_length_cm * slot_width_cm as "Максимальный объем одного места",
    slot_height_cm * slot_length_cm * slot_width_cm * slot_count as "Максимальный объем стеллажа" FROM racks;

-- Выберите названия юр. лиц всех клиентов и количество их товаров на стеллажах.
SELECT clients.legal_name as "Имя юр.лица", (SELECT COUNT(*) FROM goods WHERE goods.client_id = clients.client_id) as "Количество товара на стеллажах" FROM clients;

