-- Создание материализованного представления (индексированного) для цветочного магазина
-- и сравнение производительности с обычным запросом

-- НУЖНО БОЛЬШЕ ДАННЫХ
SELECT '--- ПОДГОТОВКА ДАННЫХ: Добавление дополнительных записей для тестирования ---' AS setup;
DO $$
DECLARE
    client_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO client_count FROM Client;
    
    IF client_count < 100 THEN
        INSERT INTO Client (Name, LastName, Otchestvo, PhoneNumber, NumberPurchase)
        SELECT 
            first_names.name,
            last_names.lastname,
            CASE WHEN random() > 0.3 THEN middle_names.middlename ELSE NULL END,
            '+7(' || floor(random() * 900 + 100)::text || ')' || 
            lpad((floor(random() * 1000))::text, 3, '0') || '-' ||
            lpad((floor(random() * 100))::text, 2, '0') || '-' ||
            lpad((floor(random() * 100))::text, 2, '0'),
            floor(random() * 100)
        FROM 
            (VALUES ('Петр'), ('Михаил'), ('Владимир'), ('Екатерина'), ('Светлана'),
                    ('Татьяна'), ('Юлия'), ('Александр'), ('Николай'), ('Виктор'),
                    ('Артем'), ('Денис'), ('Кристина'), ('Людмила'), ('Роман'),
                    ('София'), ('Даниил'), ('Маргарита'), ('Григорий'), ('Алина')) first_names(name)
        CROSS JOIN 
            (VALUES ('Воробьев'), ('Лебедев'), ('Зайцев'), ('Соловьев'), ('Волков'),
                    ('Козлов'), ('Новиков'), ('Морозов'), ('Егоров'), ('Алексеев'),
                    ('Соколов'), ('Федоров'), ('Павлов'), ('Семенов'), ('Голубев'),
                    ('Виноградов'), ('Богданов'), ('Воронов'), ('Казаков'), ('Савельев')) last_names(lastname)
        CROSS JOIN 
            (VALUES ('Олегович'), ('Михайлович'), ('Владимирович'), ('Николаевич'),
                    ('Олеговна'), ('Михайловна'), ('Владимировна'), ('Николаевна'),
                    ('Александрович'), ('Алексеевна')) middle_names(middlename)
        LIMIT 100 - client_count;
    END IF;
END $$;

-- Добавим больше чеков
INSERT INTO Account (IdClient, Status, DatePurchase, Summ, ProcentDiscount, SummAll)
SELECT 
    c.Id,
    CASE WHEN random() > 0.9 THEN 'возврат' ELSE 'оплачено' END,
    CURRENT_DATE - (floor(random() * 365)::int || ' days')::interval,
    500 + floor(random() * 20000),
    floor(random() * 20)::int,
    500 + floor(random() * 20000) * (1 - floor(random() * 20)::int / 100.0)
FROM Client c
CROSS JOIN generate_series(1, 5)
WHERE random() > 0.3
LIMIT 500;

-- Добавим больше товаров в чеки
INSERT INTO GoodsCheck (IdCheck, IdAnotherGoods, IdFlower, Price)
SELECT 
    a.Id,
    ag.Id,
    CASE WHEN random() > 0.7 THEN f.Id ELSE NULL END,
    100 + floor(random() * 5000)
FROM Account a
CROSS JOIN AnotherGoods ag
LEFT JOIN Flowers f ON f.Id = (ag.Id % 12) + 1
WHERE random() > 0.5
LIMIT 2000;


-- СОЗДАНИЕ ОБЫЧНОГО (НЕМАТЕРИАЛИЗОВАННОГО) ПРЕДСТАВЛЕНИЯ
SELECT '--- ЧАСТЬ 2: Обычное представление (нематериализованное) ---' AS part;

-- Создадим представление с аналитикой продаж по месяцам
CREATE OR REPLACE VIEW MonthlySalesAnalysis AS
SELECT 
    EXTRACT(YEAR FROM a.DatePurchase) AS Year,
    EXTRACT(MONTH FROM a.DatePurchase) AS Month,
    TO_CHAR(a.DatePurchase, 'YYYY-MM') AS YearMonth,
    COUNT(DISTINCT a.Id) AS TotalChecks,
    COUNT(DISTINCT a.IdClient) AS UniqueClients,
    SUM(a.Summ) AS TotalRevenue,
    AVG(a.Summ) AS AverageCheckSum,
    SUM(a.SummAll) AS TotalRevenueWithDiscount,
    SUM(a.Summ - a.SummAll) AS TotalDiscount,
    COUNT(gc.Id) AS TotalItemsSold,
    SUM(gc.Price) AS TotalItemsRevenue
FROM Account a
LEFT JOIN GoodsCheck gc ON a.Id = gc.IdCheck
GROUP BY EXTRACT(YEAR FROM a.DatePurchase), EXTRACT(MONTH FROM a.DatePurchase), TO_CHAR(a.DatePurchase, 'YYYY-MM')
ORDER BY Year DESC, Month DESC;

-- Проверим работу представления
SELECT 'Данные из обычного представления (первые 10 записей):' AS info;
SELECT * FROM MonthlySalesAnalysis LIMIT 10;

-- СОЗДАНИЕ МАТЕРИАЛИЗОВАННОГО ПРЕДСТАВЛЕНИЯ
SELECT '--- ЧАСТЬ 3: Материализованное представление ---' AS part;
-- Создадим материализованное представление с теми же данными
CREATE MATERIALIZED VIEW IF NOT EXISTS MaterializedMonthlySales AS
SELECT 
    EXTRACT(YEAR FROM a.DatePurchase) AS Year,
    EXTRACT(MONTH FROM a.DatePurchase) AS Month,
    TO_CHAR(a.DatePurchase, 'YYYY-MM') AS YearMonth,
    COUNT(DISTINCT a.Id) AS TotalChecks,
    COUNT(DISTINCT a.IdClient) AS UniqueClients,
    SUM(a.Summ) AS TotalRevenue,
    AVG(a.Summ) AS AverageCheckSum,
    SUM(a.SummAll) AS TotalRevenueWithDiscount,
    SUM(a.Summ - a.SummAll) AS TotalDiscount,
    COUNT(gc.Id) AS TotalItemsSold,
    SUM(gc.Price) AS TotalItemsRevenue
FROM Account a
LEFT JOIN GoodsCheck gc ON a.Id = gc.IdCheck
GROUP BY EXTRACT(YEAR FROM a.DatePurchase), EXTRACT(MONTH FROM a.DatePurchase), TO_CHAR(a.DatePurchase, 'YYYY-MM')
ORDER BY Year DESC, Month DESC;

-- Создадим индексы на материализованном представлении для ускорения запросов
CREATE INDEX IF NOT EXISTS idx_mv_month_year ON MaterializedMonthlySales(Year, Month);
CREATE INDEX IF NOT EXISTS idx_mv_yearmonth ON MaterializedMonthlySales(YearMonth);
CREATE INDEX IF NOT EXISTS idx_mv_revenue ON MaterializedMonthlySales(TotalRevenue);

-- Обновим статистику для оптимизатора
ANALYZE MaterializedMonthlySales;

-- Проверим данные в материализованном представлении
SELECT 'Данные из материализованного представления:' AS info;
SELECT * FROM MaterializedMonthlySales LIMIT 10;


-- СРАВНЕНИЕ ПРОИЗВОДИТЕЛЬНОСТИ
SELECT '--- ЧАСТЬ 4: СРАВНЕНИЕ ПРОИЗВОДИТЕЛЬНОСТИ ---' AS part;
-- Функция для измерения времени выполнения запроса
DO $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    execution_time INTERVAL;
    query_result TEXT;
BEGIN
    -- ТЕСТ 1: Запрос к обычному представлению (вычисляется каждый раз)
    RAISE NOTICE 'ТЕСТ 1: Запрос к обычному представлению (MonthlySalesAnalysis)';
    
    start_time := clock_timestamp();
   
    -- Выполняем сложный запрос с агрегацией
    PERFORM 
        Year, 
        Month, 
        TotalRevenue,
        TotalChecks,
        UniqueClients
    FROM MonthlySalesAnalysis
    WHERE Year = EXTRACT(YEAR FROM CURRENT_DATE) - 1
    ORDER BY TotalRevenue DESC;
    
    end_time := clock_timestamp();
    execution_time := end_time - start_time;
    
    RAISE NOTICE 'Время выполнения обычного представления: %', execution_time;
    
    -- ТЕСТ 2: Запрос к материализованному представлению (данные уже готовы)
    RAISE NOTICE 'ТЕСТ 2: Запрос к материализованному представлению (MaterializedMonthlySales)';
    
    start_time := clock_timestamp();
    
    PERFORM 
        Year, 
        Month, 
        TotalRevenue,
        TotalChecks,
        UniqueClients
    FROM MaterializedMonthlySales
    WHERE Year = EXTRACT(YEAR FROM CURRENT_DATE) - 1
    ORDER BY TotalRevenue DESC;
    
    end_time := clock_timestamp();
    execution_time := end_time - start_time;
    
    RAISE NOTICE 'Время выполнения материализованного представления: %', execution_time;
    
    -- ТЕСТ 3: Прямой SELECT без представления
    RAISE NOTICE 'ТЕСТ 3: Прямой SELECT без представления';
    
    start_time := clock_timestamp();
    
    PERFORM 
        EXTRACT(YEAR FROM a.DatePurchase) AS Year,
        EXTRACT(MONTH FROM a.DatePurchase) AS Month,
        SUM(a.Summ) AS TotalRevenue,
        COUNT(DISTINCT a.Id) AS TotalChecks,
        COUNT(DISTINCT a.IdClient) AS UniqueClients
    FROM Account a
    WHERE EXTRACT(YEAR FROM a.DatePurchase) = EXTRACT(YEAR FROM CURRENT_DATE) - 1
    GROUP BY EXTRACT(YEAR FROM a.DatePurchase), EXTRACT(MONTH FROM a.DatePurchase)
    ORDER BY TotalRevenue DESC;
    
    end_time := clock_timestamp();
    execution_time := end_time - start_time;
    
    RAISE NOTICE 'Время выполнения прямого SELECT: %', execution_time;
END $$;


-- ТЕСТИРОВАНИЕ С РАЗЛИЧНЫМИ ТИПАМИ ЗАПРОСОВ
SELECT '--- ЧАСТЬ 5: ТЕСТИРОВАНИЕ РАЗЛИЧНЫХ ТИПОВ ЗАПРОСОВ ---' AS part;
-- Создадим еще одно материализованное представление для анализа по клиентам
CREATE MATERIALIZED VIEW IF NOT EXISTS MaterializedClientAnalysis AS
SELECT 
    c.Id AS ClientId,
    c.LastName || ' ' || c.Name AS ClientName,
    c.PhoneNumber,
    COUNT(DISTINCT a.Id) AS CheckCount,
    SUM(a.Summ) AS TotalSpent,
    AVG(a.Summ) AS AvgCheck,
    MAX(a.Summ) AS MaxCheck,
    MIN(a.Summ) AS MinCheck,
    COUNT(DISTINCT gc.IdAnotherGoods) AS UniqueGoodsPurchased,
    SUM(gc.Price) AS TotalGoodsSpent
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
LEFT JOIN GoodsCheck gc ON a.Id = gc.IdCheck
GROUP BY c.Id, c.LastName, c.Name, c.PhoneNumber;

-- Создадим индексы
CREATE INDEX IF NOT EXISTS idx_mv_client_spent ON MaterializedClientAnalysis(TotalSpent DESC);
CREATE INDEX IF NOT EXISTS idx_mv_client_checks ON MaterializedClientAnalysis(CheckCount DESC);

-- Обновим статистику
ANALYZE MaterializedClientAnalysis;

-- Функция для детального сравнения с EXPLAIN ANALYZE
DO $$
DECLARE
    explain_output TEXT;
BEGIN
    RAISE NOTICE '=== ПЛАН ВЫПОЛНЕНИЯ ДЛЯ ОБЫЧНОГО ПРЕДСТАВЛЕНИЯ ===';
    
    -- Получаем план выполнения для обычного представления
    FOR explain_output IN 
        EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) 
        SELECT * FROM MonthlySalesAnalysis WHERE TotalRevenue > 10000
    LOOP
        RAISE NOTICE '%', explain_output;
    END LOOP;
    
    RAISE NOTICE '=== ПЛАН ВЫПОЛНЕНИЯ ДЛЯ МАТЕРИАЛИЗОВАННОГО ПРЕДСТАВЛЕНИЯ ===';
    
    -- Получаем план выполнения для материализованного представления
    FOR explain_output IN 
        EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) 
        SELECT * FROM MaterializedMonthlySales WHERE TotalRevenue > 10000
    LOOP
        RAISE NOTICE '%', explain_output;
    END LOOP;
END $$;

-- ===================================================
-- ЧАСТЬ 6: ОБНОВЛЕНИЕ МАТЕРИАЛИЗОВАННОГО ПРЕДСТАВЛЕНИЯ
-- ===================================================
SELECT '--- ЧАСТЬ 6: ОБНОВЛЕНИЕ МАТЕРИАЛИЗОВАННОГО ПРЕДСТАВЛЕНИЯ ---' AS part;

-- Добавим новые данные
INSERT INTO Account (IdClient, Status, DatePurchase, Summ, ProcentDiscount, SummAll)
SELECT 
    c.Id,
    'оплачено',
    CURRENT_DATE,
    3000 + floor(random() * 5000),
    floor(random() * 10)::int,
    3000 + floor(random() * 5000) * (1 - floor(random() * 10)::int / 100.0)
FROM Client c
WHERE random() > 0.7
LIMIT 20;

-- Показываем, что материализованное представление не обновилось автоматически
SELECT 'Данные в материализованном представлении ДО обновления (последние записи):' AS info;
SELECT * FROM MaterializedMonthlySales ORDER BY Year DESC, Month DESC LIMIT 5;

-- Обновляем материализованное представление
REFRESH MATERIALIZED VIEW MaterializedMonthlySales;
REFRESH MATERIALIZED VIEW MaterializedClientAnalysis;

SELECT 'Данные в материализованном представлении ПОСЛЕ обновления:' AS info;
SELECT * FROM MaterializedMonthlySales ORDER BY Year DESC, Month DESC LIMIT 5;


-- СРАВНЕНИЕ РАЗМЕРА ДАННЫХ

SELECT '--- ЧАСТЬ 7: СРАВНЕНИЕ РАЗМЕРА ДАННЫХ ---' AS part;
-- Сравним количество записей
SELECT 
    'MonthlySalesAnalysis (обычное)' AS object_type,
    COUNT(*) AS row_count 
FROM MonthlySalesAnalysis
UNION ALL
SELECT 
    'MaterializedMonthlySales (материализованное)' AS object_type,
    COUNT(*) AS row_count 
FROM MaterializedMonthlySales
UNION ALL
SELECT 
    'Client (таблица)' AS object_type,
    COUNT(*) AS row_count 
FROM Client
UNION ALL
SELECT 
    'Account (таблица)' AS object_type,
    COUNT(*) AS row_count 
FROM Account;

-- Информация о размере объектов в базе данных
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname || '.' || tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || tablename) - 
                   pg_relation_size(schemaname || '.' || tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'public' 
  AND tablename IN ('client', 'account', 'materializedmonthlysales')
ORDER BY pg_total_relation_size(schemaname || '.' || tablename) DESC;


-- ИТОГОВОЕ СРАВНЕНИЕ
SELECT '--- ЧАСТЬ 8: ИТОГОВОЕ СРАВНЕНИЕ ПРОИЗВОДИТЕЛЬНОСТИ ---' AS part;

DO $$
DECLARE
    i INTEGER;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    regular_total INTERVAL := '0 seconds';
    materialized_total INTERVAL := '0 seconds';
    direct_total INTERVAL := '0 seconds';
    iterations INTEGER := 5;
BEGIN
    -- Многократное тестирование для усреднения результатов
    FOR i IN 1..iterations LOOP
        
        -- Обычное представление
        start_time := clock_timestamp();
        PERFORM * FROM MonthlySalesAnalysis WHERE TotalRevenue > 5000;
        end_time := clock_timestamp();
        regular_total := regular_total + (end_time - start_time);
        
        -- Материализованное представление
        start_time := clock_timestamp();
        PERFORM * FROM MaterializedMonthlySales WHERE TotalRevenue > 5000;
        end_time := clock_timestamp();
        materialized_total := materialized_total + (end_time - start_time);
        
        -- Прямой запрос
        start_time := clock_timestamp();
        PERFORM 
            EXTRACT(YEAR FROM a.DatePurchase) AS Year,
            EXTRACT(MONTH FROM a.DatePurchase) AS Month,
            SUM(a.Summ) AS TotalRevenue
        FROM Account a
        GROUP BY EXTRACT(YEAR FROM a.DatePurchase), EXTRACT(MONTH FROM a.DatePurchase)
        HAVING SUM(a.Summ) > 5000;
        end_time := clock_timestamp();
        direct_total := direct_total + (end_time - start_time);
        
    END LOOP;
    
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'ИТОГОВЫЕ РЕЗУЛЬТАТЫ (среднее за % итераций):', iterations;
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Обычное представление: %', regular_total / iterations;
    RAISE NOTICE 'Материализованное представление: %', materialized_total / iterations;
    RAISE NOTICE 'Прямой SELECT: %', direct_total / iterations;
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Ускорение материализованного относительно обычного: %x', 
        ROUND(EXTRACT(EPOCH FROM regular_total) / NULLIF(EXTRACT(EPOCH FROM materialized_total), 0), 2);
    RAISE NOTICE '=============================================';
END $$;

-- ВЫВОД ИНФОРМАЦИИ О ВСЕХ МАТЕРИАЛИЗОВАННЫХ ПРЕДСТАВЛЕНИЯХ
SELECT '--- ЧАСТЬ 9: ИНФОРМАЦИЯ О МАТЕРИАЛИЗОВАННЫХ ПРЕДСТАВЛЕНИЯХ ---' AS part;
SELECT 
    schemaname,
    matviewname AS materialized_view_name,
    pg_size_pretty(pg_total_relation_size(schemaname || '.' || matviewname)) AS size,
    obj_description(c.oid) AS comment
FROM pg_matviews
JOIN pg_class c ON c.relname = matviewname
WHERE schemaname = 'public'
ORDER BY matviewname;

--  определение материализованного представления
SELECT 'Определение материализованного представления MaterializedMonthlySales:' AS info;
SELECT pg_get_viewdef('materializedmonthlysales', true);