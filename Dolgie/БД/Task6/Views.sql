
-- Удаление существующих представлений
-- Удаление обычных представлений
DROP VIEW IF EXISTS v_sales_report CASCADE;
DROP VIEW IF EXISTS v_bouquet_analysis CASCADE;
DROP VIEW IF EXISTS v_goods_type_stats CASCADE;
DROP VIEW IF EXISTS v_vip_clients CASCADE;
DROP VIEW IF EXISTS v_active_clients_base CASCADE;
DROP VIEW IF EXISTS v_active_clients_local CASCADE;
DROP VIEW IF EXISTS v_active_clients_cascaded CASCADE;
DROP VIEW IF EXISTS v_level1 CASCADE;
DROP VIEW IF EXISTS v_level2_local CASCADE;
DROP VIEW IF EXISTS v_level3_local CASCADE;
DROP VIEW IF EXISTS v_level2_cascaded CASCADE;
DROP VIEW IF EXISTS v_level3_cascaded CASCADE;

-- Удаление материализованных представлений
DROP MATERIALIZED VIEW IF EXISTS mv_client_statistics CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_monthly_sales CASCADE;
DROP MATERIALIZED VIEW IF EXISTS mv_top_products CASCADE;

-- Задача 1 - Создание представлений (отчеты)
-- Представление 1: Отчет по продажам с информацией о клиентах и скидках
CREATE OR REPLACE VIEW v_sales_report AS
SELECT 
    a.Id AS check_id,
    a.DatePurchase AS purchase_date,
    c.Id AS client_id,
    c.Name || ' ' || c.LastName AS client_full_name,
    c.PhoneNumber AS client_phone,
    a.Summ AS total_amount,
    a.ProcentDiscount AS discount_percent,
    a.SummAll AS final_amount,
    a.Status AS order_status,
    EXTRACT(YEAR FROM a.DatePurchase) AS year,
    EXTRACT(MONTH FROM a.DatePurchase) AS month,
    EXTRACT(QUARTER FROM a.DatePurchase) AS quarter,
    TO_CHAR(a.DatePurchase, 'DD.MM.YYYY') AS formatted_date,
    CASE 
        WHEN a.ProcentDiscount = 0 THEN 'Без скидки'
        WHEN a.ProcentDiscount < 10 THEN 'Маленькая скидка'
        WHEN a.ProcentDiscount < 20 THEN 'Средняя скидка'
        ELSE 'Большая скидка'
    END AS discount_category
FROM Account a
INNER JOIN Client c ON a.IdClient = c.Id
WHERE a.Status = 'оплачено'
ORDER BY a.DatePurchase DESC;

-- Проверка представления 1
SELECT * FROM v_sales_report LIMIT 10;

-- Получение кода представления 1
SELECT pg_get_viewdef('v_sales_report', true);


-- Представление 2: Анализ продаж по букетам и цветам
CREATE OR REPLACE VIEW v_bouquet_analysis AS
SELECT 
    b.Id AS bouquet_id,
    b.Name AS bouquet_name,
    b.Quantity AS flowers_quantity,
    b.Price AS bouquet_price,
    b.Structure AS structure,
    COUNT(DISTINCT fb.IdFlower) AS unique_flowers_count,
    STRING_AGG(DISTINCT f.Species, ', ' ORDER BY f.Species) AS flower_species,
    STRING_AGG(DISTINCT f.Name, ', ' ORDER BY f.Name) AS flower_names,
    STRING_AGG(DISTINCT f.Country, ', ' ORDER BY f.Country) AS flower_countries,
    CASE 
        WHEN b.Price < 3000 THEN 'Бюджетный'
        WHEN b.Price < 6000 THEN 'Средний'
        ELSE 'Премиум'
    END AS price_category
FROM Bouquet b
LEFT JOIN FlowersAndBouquet fb ON b.Id = fb.IdBouquet
LEFT JOIN Flowers f ON fb.IdFlower = f.Id
GROUP BY b.Id, b.Name, b.Quantity, b.Price, b.Structure
ORDER BY b.Price DESC;

-- Проверка представления 2
SELECT * FROM v_bouquet_analysis;

-- Получение кода представления 2
SELECT pg_get_viewdef('v_bouquet_analysis', true);


-- Представление 3: Статистика по типам товаров
CREATE OR REPLACE VIEW v_goods_type_stats AS
SELECT 
    tg.IdTypeGoods AS type_id,
    tg.NameType AS type_name,
    COUNT(DISTINCT g.IdAnotherGoods) AS unique_goods_count,
    COUNT(DISTINCT gc.IdCheck) AS times_sold,
    COUNT(gc.IdCheck) AS total_sales_count,
    COALESCE(SUM(gc.Price), 0) AS total_revenue,
    COALESCE(AVG(gc.Price), 0)::NUMERIC(10,2) AS average_price,
    COALESCE(MIN(gc.Price), 0) AS min_price,
    COALESCE(MAX(gc.Price), 0) AS max_price,
    COUNT(CASE WHEN gc.IdFlower IS NOT NULL THEN 1 END) AS with_flowers_count,
    ROUND(COALESCE(SUM(gc.Price) * 100.0 / SUM(SUM(gc.Price)) OVER (), 0), 2) AS revenue_percent
FROM TypeGoods tg
LEFT JOIN Goods g ON tg.IdTypeGoods = g.IdType
LEFT JOIN GoodsCheck gc ON g.IdAnotherGoods = gc.IdAnotherGoods
GROUP BY tg.IdTypeGoods, tg.NameType
ORDER BY total_revenue DESC NULLS LAST;

-- Проверка представления 3
SELECT * FROM v_goods_type_stats;

-- Получение кода представления 3
SELECT pg_get_viewdef('v_goods_type_stats', true);


-- Представление 4: VIP-клиенты с детальной информацией (дополнительное)
CREATE OR REPLACE VIEW v_vip_clients AS
SELECT 
    c.Id AS client_id,
    c.Name || ' ' || c.LastName AS full_name,
    COALESCE(c.Otchestvo, '') AS patronymic,
    c.PhoneNumber AS phone,
    c.NumberPurchase AS total_purchases,
    COUNT(a.Id) AS actual_checks_count,
    COALESCE(SUM(a.Summ), 0) AS total_spent,
    COALESCE(AVG(a.Summ), 0)::NUMERIC(10,2) AS average_check,
    COALESCE(MIN(a.Summ), 0) AS min_check,
    COALESCE(MAX(a.Summ), 0) AS max_check,
    MAX(a.DatePurchase) AS last_purchase_date,
    MIN(a.DatePurchase) AS first_purchase_date,
    COUNT(CASE WHEN a.Status = 'возврат' THEN 1 END) AS returns_count,
    CASE 
        WHEN MAX(a.DatePurchase) > CURRENT_DATE - INTERVAL '30 days' THEN 'Активный'
        WHEN MAX(a.DatePurchase) > CURRENT_DATE - INTERVAL '90 days' THEN 'Недавний'
        WHEN MAX(a.DatePurchase) IS NOT NULL THEN 'Неактивный'
        ELSE 'Нет покупок'
    END AS activity_status,
    CASE 
        WHEN COALESCE(SUM(a.Summ), 0) > 20000 THEN 'Платиновый'
        WHEN COALESCE(SUM(a.Summ), 0) > 10000 THEN 'Золотой'
        WHEN COALESCE(SUM(a.Summ), 0) > 5000 THEN 'Серебряный'
        ELSE 'Обычный'
    END AS vip_status
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
WHERE c.NumberPurchase > 10
GROUP BY c.Id, c.Name, c.LastName, c.Otchestvo, c.PhoneNumber, c.NumberPurchase
ORDER BY total_spent DESC;

-- Проверка представления 4
SELECT * FROM v_vip_clients LIMIT 10;

-- Получение кода представления 4
SELECT pg_get_viewdef('v_vip_clients', true);

-- Задача 2 - Обновляемые представления
-- Базовое представление (без CHECK OPTION)
CREATE OR REPLACE VIEW v_active_clients_base AS
SELECT 
    Id,
    Name,
    LastName,
    Otchestvo,
    PhoneNumber,
    NumberPurchase
FROM Client
WHERE NumberPurchase >= 5;

-- Проверка базового представления
SELECT * FROM v_active_clients_base ORDER BY NumberPurchase DESC;


-- Представление с LOCAL CHECK OPTION
-- Проверяет только условия текущего представления
CREATE OR REPLACE VIEW v_active_clients_local AS
SELECT *
FROM v_active_clients_base
WHERE NumberPurchase >= 10
WITH LOCAL CHECK OPTION;

-- Демонстрация работы LOCAL CHECK OPTION
-- 1. Ошибочная вставка (NumberPurchase = 7 - не проходит условие NumberPurchase >= 10)
INSERT INTO v_active_clients_local (Name, LastName, PhoneNumber, NumberPurchase)
VALUES ('Тестовый', 'Локальный', '+7(999)000-00-00', 7);
-- Ожидаемая ошибка: new row violates check option for view "v_active_clients_local"

-- 2. Успешная вставка (NumberPurchase = 12 - проходит условие)
INSERT INTO v_active_clients_local (Name, LastName, PhoneNumber, NumberPurchase)
VALUES ('Успешный', 'Локальный', '+7(999)111-11-11', 12);

-- 3. Успешная вставка (NumberPurchase = 15)
INSERT INTO v_active_clients_local (Name, LastName, PhoneNumber, NumberPurchase)
VALUES ('Отличный', 'Локальный', '+7(999)222-22-22', 15);

-- Проверка результатов
SELECT * FROM v_active_clients_local WHERE LastName = 'Локальный';
SELECT * FROM Client WHERE LastName = 'Локальный';


-- Представление с CASCADED CHECK OPTION
-- Проверяет условия текущего представления И всех нижележащих
CREATE OR REPLACE VIEW v_active_clients_cascaded AS
SELECT *
FROM v_active_clients_base
WHERE NumberPurchase >= 10
WITH CASCADED CHECK OPTION;

-- Демонстрация работы CASCADED CHECK OPTION
-- 1. Ошибочная вставка (NumberPurchase = 12 - проходит текущее условие, но не проходит базовое? 
--    На самом деле проходит, так как базовое условие >=5, а 12>=5)
INSERT INTO v_active_clients_cascaded (Name, LastName, PhoneNumber, NumberPurchase)
VALUES ('Каскадный', 'Тест1', '+7(999)333-33-33', 12);
-- Успешно, так как 12 >= 10 и 12 >= 5

-- 2. Ошибочная вставка (NumberPurchase = 8 - не проходит условие NumberPurchase >= 10)
INSERT INTO v_active_clients_cascaded (Name, LastName, PhoneNumber, NumberPurchase)
VALUES ('Каскадный', 'Тест2', '+7(999)444-44-44', 8);
-- Ошибка: не проходит условие NumberPurchase >= 10

-- Проверка результатов
SELECT * FROM v_active_clients_cascaded WHERE LastName = 'Тест1';


-- Иерархия представлений для демонстрации различий LOCAL vs CASCADED

-- Уровень 1: Базовое представление
CREATE OR REPLACE VIEW v_level1 AS
SELECT Id, Name, LastName, NumberPurchase
FROM Client
WHERE NumberPurchase >= 3;

-- Уровень 2: С LOCAL CHECK OPTION
CREATE OR REPLACE VIEW v_level2_local AS
SELECT *
FROM v_level1
WHERE NumberPurchase >= 5
WITH LOCAL CHECK OPTION;

-- Уровень 3: С LOCAL CHECK OPTION
CREATE OR REPLACE VIEW v_level3_local AS
SELECT *
FROM v_level2_local
WHERE NumberPurchase >= 7
WITH LOCAL CHECK OPTION;

-- Уровень 2: С CASCADED CHECK OPTION
CREATE OR REPLACE VIEW v_level2_cascaded AS
SELECT *
FROM v_level1
WHERE NumberPurchase >= 5
WITH CASCADED CHECK OPTION;

-- Уровень 3: С CASCADED CHECK OPTION
CREATE OR REPLACE VIEW v_level3_cascaded AS
SELECT *
FROM v_level2_cascaded
WHERE NumberPurchase >= 7
WITH CASCADED CHECK OPTION;

-- Демонстрация LOCAL: вставка с NumberPurchase = 6
-- Должна пройти? Проверяет только уровень 3 (>=7) → НЕТ
INSERT INTO v_level3_local (Name, LastName, NumberPurchase)
VALUES ('Локальный', 'Демо1', 6);
-- Ошибка

-- Демонстрация LOCAL: вставка с NumberPurchase = 8
-- Должна пройти (8 >= 7)
INSERT INTO v_level3_local (Name, LastName, NumberPurchase)
VALUES ('Локальный', 'Демо2', 8);
-- Успешно

-- Демонстрация CASCADED: вставка с NumberPurchase = 8
-- Проверяет все уровни: 8>=7, 8>=5, 8>=3 → Успешно
INSERT INTO v_level3_cascaded (Name, LastName, NumberPurchase)
VALUES ('Каскадный', 'Демо3', 8);
-- Успешно

-- Демонстрация CASCADED: вставка с NumberPurchase = 4
-- Проверяет: 4>=7? НЕТ → Ошибка
INSERT INTO v_level3_cascaded (Name, LastName, NumberPurchase)
VALUES ('Каскадный', 'Демо4', 4);
-- Ошибка

-- Очистка тестовых данных ееееехеехе, если захочется
-- DELETE FROM Client WHERE LastName IN ('Локальный', 'Каскадный', 'Тестовый', 'Успешный', 'Отличный', 
-- 'Демо1', 'Демо2', 'Демо3', 'Демо4', 'Тест1', 'Тест2');

SET enable_seqscan = ON;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;  -- Отключаем и bitmap scan

-- Задача 3 - Индексированные (материализованные) представления
-- Материализованное представление 1: Статистика по клиентам
CREATE MATERIALIZED VIEW mv_client_statistics AS
SELECT 
    c.Id AS client_id,
    c.Name,
    c.LastName,
    c.Otchestvo,
    c.PhoneNumber,
    c.NumberPurchase AS registered_purchases,
    COUNT(a.Id) AS actual_checks,
    COUNT(DISTINCT DATE_TRUNC('month', a.DatePurchase)) AS active_months,
    COALESCE(SUM(a.Summ), 0) AS total_spent,
    COALESCE(AVG(a.Summ), 0)::NUMERIC(10,2) AS avg_check,
    MIN(a.DatePurchase) AS first_purchase,
    MAX(a.DatePurchase) AS last_purchase,
    COALESCE(SUM(a.SummAll), 0) AS total_with_discount,
    COALESCE(AVG(a.ProcentDiscount), 0)::NUMERIC(5,2) AS avg_discount,
    COUNT(CASE WHEN a.Status = 'возврат' THEN 1 END) AS returns_count,
    COALESCE(SUM(CASE WHEN a.Status = 'возврат' THEN a.Summ ELSE 0 END), 0) AS returns_sum,
    COUNT(CASE WHEN a.Status = 'оплачено' THEN 1 END) AS paid_checks,
    COALESCE(SUM(CASE WHEN a.Status = 'оплачено' THEN a.Summ ELSE 0 END), 0) AS paid_sum,
    (COUNT(a.Id) - COUNT(CASE WHEN a.Status = 'возврат' THEN 1 END)) AS net_checks
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.Name, c.LastName, c.Otchestvo, c.PhoneNumber, c.NumberPurchase;

-- Создание индексов для mv_client_statistics
-- Уникальный индекс для быстрого поиска по ID клиента
CREATE UNIQUE INDEX idx_mv_client_stats_id ON mv_client_statistics (client_id);

-- Составной индекс для фильтрации по сумме и количеству покупок
CREATE INDEX idx_mv_client_stats_spent_purchases ON mv_client_statistics (total_spent DESC, actual_checks DESC);

-- Индекс для поиска по дате последней покупки
CREATE INDEX idx_mv_client_stats_last_purchase ON mv_client_statistics (last_purchase DESC NULLS LAST);

-- Индекс для поиска по имени и фамилии
CREATE INDEX idx_mv_client_stats_name ON mv_client_statistics (Name, LastName);

-- Частичный индекс для VIP-клиентов (траты > 10000 или покупок > 10)
CREATE INDEX idx_mv_client_stats_vip ON mv_client_statistics (client_id, total_spent, actual_checks) 
WHERE total_spent > 10000 OR actual_checks > 10;

-- Обновление статистики

SELECT * FROM mv_client_statistics;

-- Материализованное представление 2: Анализ продаж по месяцам
CREATE MATERIALIZED VIEW mv_monthly_sales AS
SELECT 
    DATE_TRUNC('month', a.DatePurchase)::DATE AS month,
    EXTRACT(YEAR FROM a.DatePurchase) AS year,
    EXTRACT(MONTH FROM a.DatePurchase) AS month_number,
    TO_CHAR(a.DatePurchase, 'Month YYYY') AS month_name,
    COUNT(DISTINCT a.IdClient) AS unique_customers,
    COUNT(a.Id) AS transactions_count,
    COALESCE(SUM(a.Summ), 0) AS revenue,
    COALESCE(AVG(a.Summ), 0)::NUMERIC(10,2) AS avg_transaction,
    COALESCE(SUM(a.SummAll), 0) AS revenue_with_discount,
    COUNT(CASE WHEN a.ProcentDiscount > 0 THEN 1 END) AS discounted_transactions,
    COALESCE(AVG(a.ProcentDiscount), 0)::NUMERIC(5,2) AS avg_discount_percent,
    MIN(a.Summ) AS min_transaction,
    MAX(a.Summ) AS max_transaction,
    COUNT(CASE WHEN a.Status = 'возврат' THEN 1 END) AS returns_count,
    COALESCE(SUM(CASE WHEN a.Status = 'возврат' THEN a.Summ ELSE 0 END), 0) AS returns_amount
FROM Account a
WHERE a.DatePurchase IS NOT NULL
GROUP BY DATE_TRUNC('month', a.DatePurchase), EXTRACT(YEAR FROM a.DatePurchase), 
         EXTRACT(MONTH FROM a.DatePurchase), TO_CHAR(a.DatePurchase, 'Month YYYY')
ORDER BY month;

-- Создание индексов для mv_monthly_sales
CREATE UNIQUE INDEX idx_mv_monthly_sales_month ON mv_monthly_sales (month);
CREATE INDEX idx_mv_monthly_sales_revenue ON mv_monthly_sales (revenue DESC);
CREATE INDEX idx_mv_monthly_sales_customers ON mv_monthly_sales (unique_customers DESC);



SELECT * FROM mv_monthly_sales;

-- Материализованное представление 3: Топ товаров по продажам
CREATE MATERIALIZED VIEW mv_top_products AS
SELECT 
    ag.Id AS product_id,
    ag.Name AS product_name,
    tg.NameType AS product_type,
    COUNT(gc.IdCheck) AS times_sold,
    COUNT(DISTINCT gc.IdCheck) AS unique_checks,
    COALESCE(SUM(gc.Price), 0) AS total_revenue,
    COALESCE(AVG(gc.Price), 0)::NUMERIC(10,2) AS avg_price,
    MIN(gc.Price) AS min_price,
    MAX(gc.Price) AS max_price,
    COUNT(CASE WHEN gc.IdFlower IS NOT NULL THEN 1 END) AS with_flower,
    RANK() OVER (ORDER BY COALESCE(SUM(gc.Price), 0) DESC) AS revenue_rank,
    RANK() OVER (ORDER BY COUNT(gc.IdCheck) DESC) AS popularity_rank
FROM AnotherGoods ag
LEFT JOIN Goods g ON ag.Id = g.IdAnotherGoods
LEFT JOIN TypeGoods tg ON g.IdType = tg.IdTypeGoods
LEFT JOIN GoodsCheck gc ON ag.Id = gc.IdAnotherGoods
GROUP BY ag.Id, ag.Name, tg.NameType
ORDER BY total_revenue DESC;

-- Создание индексов для mv_top_products
CREATE UNIQUE INDEX idx_mv_top_products_id ON mv_top_products (product_id);
CREATE INDEX idx_mv_top_products_revenue ON mv_top_products (total_revenue DESC);
CREATE INDEX idx_mv_top_products_type ON mv_top_products (product_type);

SELECT * FROM mv_top_products;


-- Сравнение производительности
-- Функция для сравнения времени выполнения запросов
DO $$
DECLARE
    start_time timestamptz;
    end_time timestamptz;
    duration_ms numeric;
BEGIN
    -- Запрос 1: Поиск клиентов с тратами > 5000 (обычный запрос)
    start_time := clock_timestamp();
    PERFORM 
        c.Id,
        c.Name || ' ' || c.LastName AS full_name,
        COUNT(a.Id) AS checks_count,
        SUM(a.Summ) AS total_spent
    FROM Client c
    LEFT JOIN Account a ON c.Id = a.IdClient
    GROUP BY c.Id, c.Name, c.LastName
    HAVING SUM(a.Summ) > 5000
    ORDER BY total_spent DESC
    LIMIT 10;
    end_time := clock_timestamp();
    duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
    RAISE NOTICE 'Обычный запрос (траты > 5000): % мс', duration_ms;
    
    -- Запрос 2: Поиск клиентов с тратами > 5000 (материализованное представление)
    start_time := clock_timestamp();
    PERFORM 
        client_id,
        Name || ' ' || LastName AS full_name,
        actual_checks AS checks_count,
        total_spent
    FROM mv_client_statistics
    WHERE total_spent > 5000
    ORDER BY total_spent DESC
    LIMIT 10;
    end_time := clock_timestamp();
    duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
    RAISE NOTICE 'Материализованное представление (траты > 5000): % мс', duration_ms;
    
    -- Запрос 3: Поиск активных клиентов (обычный запрос)
    start_time := clock_timestamp();
    PERFORM DISTINCT
        c.Id,
        c.Name,
        c.LastName
    FROM Client c
    INNER JOIN Account a ON c.Id = a.IdClient
    WHERE a.DatePurchase > CURRENT_DATE - INTERVAL '30 days'
    ORDER BY c.LastName
    LIMIT 10;
    end_time := clock_timestamp();
    duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
    RAISE NOTICE 'Обычный запрос (активные клиенты): % мс', duration_ms;
    
    -- Запрос 4: Поиск активных клиентов (материализованное представление)
    start_time := clock_timestamp();
    PERFORM 
        client_id,
        Name,
        LastName
    FROM mv_client_statistics
    WHERE last_purchase > CURRENT_DATE - INTERVAL '30 days'
    ORDER BY LastName
    LIMIT 10;
    end_time := clock_timestamp();
    duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
    RAISE NOTICE 'Материализованное представление (активные клиенты): % мс', duration_ms;
END $$;


-- Обслуживание материализованных представлений
-- Функция для обновления всех материализованных представлений
CREATE OR REPLACE FUNCTION refresh_all_materialized_views()
RETURNS TEXT AS $$
DECLARE
    refresh_start timestamptz;
    refresh_end timestamptz;
    duration_ms numeric;
BEGIN
    refresh_start := clock_timestamp();
    
    -- Обновление mv_client_statistics
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_client_statistics;
    RAISE NOTICE 'Обновлено mv_client_statistics';
    
    -- Обновление mv_monthly_sales
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_monthly_sales;
    RAISE NOTICE 'Обновлено mv_monthly_sales';
    
    -- Обновление mv_top_products
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_top_products;
    RAISE NOTICE 'Обновлено mv_top_products';
    
    refresh_end := clock_timestamp();
    duration_ms := EXTRACT(EPOCH FROM (refresh_end - refresh_start)) * 1000;
    
    RETURN format('Все материализованные представления обновлены за %s мс', duration_ms);
END;
$$ LANGUAGE plpgsql;

-- Вызов функции обновления
SELECT refresh_all_materialized_views();


-- Проверка созданных объектов
-- Вывод списка всех представлений
SELECT 
    'Обычные представления' AS object_type,
    schemaname,
    viewname AS name,
    viewowner AS owner
FROM pg_views 
WHERE viewname LIKE 'v_%'
   AND schemaname = 'public'
UNION ALL
SELECT 
    'Материализованные представления' AS object_type,
    schemaname,
    matviewname AS name,
    matviewowner AS owner
FROM pg_matviews 
WHERE matviewname LIKE 'mv_%'
   AND schemaname = 'public'
ORDER BY object_type, name;

-- Статистика по материализованным представлениям
SELECT 
    schemaname,
    matviewname,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||matviewname)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||matviewname)) AS data_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||matviewname)) AS indexes_size
FROM pg_matviews 
WHERE matviewname LIKE 'mv_%'
   AND schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||matviewname) DESC;
