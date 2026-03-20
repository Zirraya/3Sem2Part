-- Индексы B-Tree и Hash
-- ===================================================

-- 1. ПРОСТЫЕ ИНДЕКСЫ (B-Tree и Hash)
-- ===================================================

-- B-Tree простой индекс для соединений (JOIN) и вложенных запросов
CREATE INDEX idx_account_idclient_btree ON Account(IdClient);

-- Hash простой индекс для поиска по точному соответствию (используется в IN, ANY)
CREATE INDEX idx_client_name_hash ON Client USING HASH(Name);

-- Hash индекс для поиска по статусу (используется в предикатах)
CREATE INDEX idx_account_status_hash ON Account USING HASH(Status);

-- 2. УНИКАЛЬНЫЙ ИНДЕКС (только B-Tree)
-- ===================================================
CREATE UNIQUE INDEX idx_flowers_name_species_unique ON Flowers(Species, Name);


-- 3. СОСТАВНОЙ ИНДЕКС (только B-Tree)
-- ===================================================
-- Для запросов с фильтрацией по дате и статусу (BETWEEN, GROUP BY)
CREATE INDEX idx_account_date_status_composite ON Account(DatePurchase, Status);
-- Для запросов с GROUP BY и агрегатными функциями
CREATE INDEX idx_account_client_date_composite ON Account(IdClient, DatePurchase, Summ);
-- Для запросов с JOIN по нескольким полям
CREATE INDEX idx_goods_type_composite ON Goods(IdAnotherGoods, IdType, IdBouquet);

-- 4. ИНДЕКСЫ С ИСПОЛЬЗОВАНИЕМ ВЫРАЖЕНИЙ
-- ===================================================
-- Для поиска по имени цветка в верхнем регистре (используется в UNION с Flower)
CREATE INDEX idx_flowers_name_upper ON Flowers(UPPER(Name));
-- Для поиска по фамилии без учета регистра (ILIKE)
CREATE INDEX idx_client_lastname_upper ON Client(UPPER(LastName));

-- 5. ПОКРЫВАЮЩИЕ ИНДЕКСЫ (B-Tree)
-- ===================================================
-- Покрывающий индекс для AnotherGoods (используется в JOIN и агрегациях)
CREATE INDEX idx_anothergoods_covering ON AnotherGoods(Id, Name)
INCLUDE ();
-- Покрывающий индекс для TypeGoods (используется в JOIN)
CREATE INDEX idx_typegoods_covering ON TypeGoods(IdTypeGoods, NameType)
INCLUDE ();

-- 6. ЧАСТИЧНЫЕ ИНДЕКСЫ
-- ===================================================
-- Частичный индекс для оплаченных чеков с большой суммой (используется в ANY, EXISTS)
CREATE INDEX idx_account_paid_large_partial ON Account(IdClient, Summ) 
WHERE Status = 'оплачено' AND Summ > 5000;

-- Частичный индекс для VIP-клиентов (NumberPurchase > 25)
CREATE INDEX idx_client_vip_partial ON Client(Id, Name, LastName, NumberPurchase) 
WHERE NumberPurchase > 25;

-- Частичный индекс для возвратов (используется в FILTER)
CREATE INDEX idx_account_refund_partial ON Account(IdClient, Summ) 
WHERE Status = 'возврат';


CREATE INDEX idx_client_regular_name_hash ON Client USING HASH(Name) 
WHERE NumberPurchase BETWEEN 10 AND 20;  

-- 7. ЧАСТИЧНЫЕ ПОКРЫВАЮЩИЕ ИНДЕКСЫ (сравнение с обычными частичными)
-- ===================================================
-- Частичный покрывающий индекс для VIP-клиентов
-- Включает все поля, нужные для отображения информации о VIP-клиентах
CREATE INDEX idx_client_vip_covering_partial ON Client(Id, Name, LastName, NumberPurchase) 
INCLUDE (Otchestvo, PhoneNumber) 
WHERE NumberPurchase > 25;

-- Частичный покрывающий индекс для крупных оплаченных чеков
-- Включает все поля, используемые в аналитических запросах
CREATE INDEX idx_account_large_paid_covering ON Account(Id, IdClient, DatePurchase, Summ) 
INCLUDE (Status, ProcentDiscount, SummAll) 
WHERE Status = 'оплачено' AND Summ > 5000;

-- Частичный покрывающий индекс для активных клиентов (покупали в последние 90 дней)
CREATE INDEX idx_client_active_covering ON Client(Id, Name, LastName, PhoneNumber) 
INCLUDE (Otchestvo, NumberPurchase) 
WHERE Id IN (
    SELECT DISTINCT IdClient 
    FROM Account 
    WHERE DatePurchase > CURRENT_DATE - INTERVAL '90 days'
);

-- Обновление статистики после создания индексов
ANALYZE Client;
ANALYZE Account;
ANALYZE Flowers;
ANALYZE Bouquet;
ANALYZE AnotherGoods;
ANALYZE GoodsCheck;
ANALYZE TypeGoods;
ANALYZE FlowersAndBouquet;