-- Индексы B-Tree и Hash
-- ===================================================

-- 1. ПРОСТЫЕ ИНДЕКСЫ (B-Tree и Hash)
-- ===================================================

-- B-Tree простой индекс для соединений (JOIN)
CREATE INDEX idx_account_idclient_btree ON Account(IdClient);

-- Hash простой индекс для точного поиска по телефону
CREATE INDEX idx_client_phone_hash ON Client USING HASH(PhoneNumber);

-- 2. УНИКАЛЬНЫЙ ИНДЕКС (только B-Tree)
-- ===================================================
CREATE UNIQUE INDEX idx_client_phone_unique_btree ON Client(PhoneNumber);

-- 3. СОСТАВНОЙ ИНДЕКС (только B-Tree)
-- ===================================================
-- Для запросов с фильтрацией по дате и статусу (BETWEEN, GROUP BY)
CREATE INDEX idx_account_date_status_composite ON Account(DatePurchase, Status);

-- 4. ИНДЕКСЫ С ИСПОЛЬЗОВАНИЕМ ВЫРАЖЕНИЙ
-- ===================================================
-- Для поиска по имени цветка в верхнем регистре (используется в UNION с Flower)
CREATE INDEX idx_flowers_name_upper ON Flowers(UPPER(Name));

-- Для поиска по фамилии без учета регистра (ILIKE)
CREATE INDEX idx_client_lastname_upper ON Client(UPPER(LastName));

-- Для поиска по cleaned phone number (без форматирования)
CREATE INDEX idx_client_clean_phone ON Client(REGEXP_REPLACE(PhoneNumber, '[^0-9]', '', 'g'));

-- 5. ПОКРЫВАЮЩИЕ ИНДЕКСЫ (B-Tree)
-- ===================================================
-- Покрывающий индекс для Client (используется в GROUP BY, агрегатных функциях)
-- Включает все поля, используемые в запросах с агрегацией и конкатенацией
CREATE INDEX idx_client_covering_full ON Client(Id, Name, LastName, NumberPurchase) 
INCLUDE (Otchestvo, PhoneNumber);

-- Покрывающий индекс для Account (покрывает запросы с датами и суммами)
CREATE INDEX idx_account_covering_full ON Account(Id, IdClient, DatePurchase, Summ, Status) 
INCLUDE (ProcentDiscount, SummAll);

-- Покрывающий индекс для GoodsCheck (для JOIN с AnotherGoods и Account)
CREATE INDEX idx_goodscheck_covering_full ON GoodsCheck(Id, IdCheck, IdAnotherGoods, Price) 
INCLUDE (IdFlower);

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

-- 8. ДОПОЛНИТЕЛЬНЫЕ ИНДЕКСЫ ДЛЯ СПЕЦИФИЧЕСКИХ ЗАПРОСОВ
-- ===================================================

-- Для вложенных запросов и ANY/ALL
CREATE INDEX idx_account_summ_client ON Account(IdClient, Summ);

-- Для UNION и INTERSECT (поиск по имени)
CREATE INDEX idx_flowers_name ON Flowers(Name);
CREATE INDEX idx_bouquet_name ON Bouquet(Name);

-- Для запросов с датами (AGE, EXTRACT, DATE_TRUNC)
CREATE INDEX idx_account_date ON Account(DatePurchase);

-- Для запросов с GROUP BY и HAVING
CREATE INDEX idx_client_number_purchase ON Client(NumberPurchase);
CREATE INDEX idx_account_client_summ ON Account(IdClient, Summ);

-- Hash индекс для точного поиска по статусу (используется в FILTER)
CREATE INDEX idx_account_status_hash ON Account USING HASH(Status);

-- Индекс для LIKE 'Пет%' (поддержка left-anchored поиска)
CREATE INDEX idx_client_lastname_pattern ON Client(LastName text_pattern_ops);

-- Индекс для ILIKE '%ов%' (используем триграммы для нечеткого поиска)
CREATE INDEX idx_client_lastname_trgm ON Client USING gin(LastName gin_trgm_ops);
CREATE INDEX idx_client_name_trgm ON Client USING gin(Name gin_trgm_ops);

-- Обновление статистики после создания индексов
ANALYZE Client;
ANALYZE Account;
ANALYZE Flowers;
ANALYZE Bouquet;
ANALYZE AnotherGoods;
ANALYZE GoodsCheck;
ANALYZE TypeGoods;
ANALYZE FlowersAndBouquet;


