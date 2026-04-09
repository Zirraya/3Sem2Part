-- 1. Создание дополнительных индексов для mv_client_statistics
-- =====================================================
-- Индекс для фильтрации по сумме трат и дате последней покупки
CREATE INDEX IF NOT EXISTS idx_mv_client_stats_spent_last 
ON mv_client_statistics (total_spent DESC, last_purchase DESC NULLS LAST);

-- Индекс для поиска по количеству чеков и сумме возвратов
CREATE INDEX IF NOT EXISTS idx_mv_client_stats_checks_returns 
ON mv_client_statistics (actual_checks DESC, returns_count DESC);

-- Индекс для фильтрации по средней скидке
CREATE INDEX IF NOT EXISTS idx_mv_client_stats_discount 
ON mv_client_statistics (avg_discount DESC, total_spent DESC);

-- Составной индекс для частых условий WHERE (активные VIP-клиенты)
CREATE INDEX IF NOT EXISTS idx_mv_client_stats_active_vip 
ON mv_client_statistics (last_purchase DESC, total_spent DESC, actual_checks DESC)
WHERE total_spent > 5000 AND last_purchase > CURRENT_DATE - INTERVAL '90 days';

-- =====================================================
-- 2. Функция для сравнения производительности
DO $$
DECLARE
    start_time timestamptz;
    end_time timestamptz;
    duration_ms numeric;
    i integer;
    iterations integer := 10;  -- Количество итераций для усреднения
    base_total_ms numeric := 0;
    mv_total_ms numeric := 0;
BEGIN
    -- ТЕСТ 1: Поиск топ-10 клиентов по сумме трат
    -- =====================================================
    RAISE NOTICE ' ТЕСТ 1: Топ-10 клиентов по сумме трат';
    -- Базовый запрос (исходный SELECT)
    base_total_ms := 0;
    FOR i IN 1..iterations LOOP
        start_time := clock_timestamp();
        PERFORM 
            c.Id,
            c.Name || ' ' || c.LastName AS full_name,
            COUNT(a.Id) AS checks_count,
            COALESCE(SUM(a.Summ), 0) AS total_spent
        FROM Client c
        LEFT JOIN Account a ON c.Id = a.IdClient
        GROUP BY c.Id, c.Name, c.LastName
        ORDER BY total_spent DESC
        LIMIT 10;
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        base_total_ms := base_total_ms + duration_ms;
    END LOOP;
    base_total_ms := base_total_ms / iterations;
    RAISE NOTICE '│ Базовый запрос (среднее за % итераций): % мс', iterations, base_total_ms::numeric(10,3);
    
    -- Материализованное представление с индексами
    mv_total_ms := 0;
    FOR i IN 1..iterations LOOP
        start_time := clock_timestamp();
        PERFORM 
            client_id,
            Name || ' ' || LastName AS full_name,
            actual_checks AS checks_count,
            total_spent
        FROM mv_client_statistics
        ORDER BY total_spent DESC
        LIMIT 10;
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        mv_total_ms := mv_total_ms + duration_ms;
    END LOOP;
    mv_total_ms := mv_total_ms / iterations;
    RAISE NOTICE ' Индексированное MV (среднее за % итераций): % мс', iterations, mv_total_ms::numeric(10,3);
    RAISE NOTICE ' Ускорение: %x', (base_total_ms / NULLIF(mv_total_ms, 0))::numeric(10,2);


    -- ТЕСТ 2: Поиск VIP-клиентов с фильтрацией
    -- =====================================================
    RAISE NOTICE ' ТЕСТ 2: VIP-клиенты (total_spent > 10000 OR actual_checks > 10)';
    -- Базовый запрос
    base_total_ms := 0;
    FOR i IN 1..iterations LOOP
        start_time := clock_timestamp();
        PERFORM 
            c.Id,
            c.Name,
            c.LastName,
            COUNT(a.Id) AS checks_count,
            COALESCE(SUM(a.Summ), 0) AS total_spent
        FROM Client c
        LEFT JOIN Account a ON c.Id = a.IdClient
        GROUP BY c.Id, c.Name, c.LastName
        HAVING COALESCE(SUM(a.Summ), 0) > 10000 OR COUNT(a.Id) > 10
        ORDER BY total_spent DESC
        LIMIT 20;
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        base_total_ms := base_total_ms + duration_ms;
    END LOOP;
    base_total_ms := base_total_ms / iterations;
    RAISE NOTICE ' Базовый запрос (среднее за % итераций): % мс', iterations, base_total_ms::numeric(10,3);
    
    -- Материализованное представление с индексом idx_mv_client_stats_vip
    mv_total_ms := 0;
    FOR i IN 1..iterations LOOP
        start_time := clock_timestamp();
        PERFORM 
            client_id,
            Name,
            LastName,
            actual_checks AS checks_count,
            total_spent
        FROM mv_client_statistics
        WHERE total_spent > 10000 OR actual_checks > 10
        ORDER BY total_spent DESC
        LIMIT 20;
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        mv_total_ms := mv_total_ms + duration_ms;
    END LOOP;
    mv_total_ms := mv_total_ms / iterations;
    RAISE NOTICE ' Индексированное MV (среднее за % итераций): % мс', iterations, mv_total_ms::numeric(10,3);
    RAISE NOTICE ' Ускорение: %x', (base_total_ms / NULLIF(mv_total_ms, 0))::numeric(10,2);

    -- ТЕСТ 3: Активные клиенты за последние 30 дней
    -- =====================================================

    RAISE NOTICE ' ТЕСТ 3: Активные клиенты (покупки за последние 30 дней)';

    
    -- Базовый запрос
    base_total_ms := 0;
    FOR i IN 1..iterations LOOP
        start_time := clock_timestamp();
        PERFORM DISTINCT
            c.Id,
            c.Name,
            c.LastName,
            c.PhoneNumber
        FROM Client c
        INNER JOIN Account a ON c.Id = a.IdClient
        WHERE a.DatePurchase > CURRENT_DATE - INTERVAL '30 days'
        ORDER BY c.LastName
        LIMIT 30;
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        base_total_ms := base_total_ms + duration_ms;
    END LOOP;
    base_total_ms := base_total_ms / iterations;
    RAISE NOTICE '│ Базовый запрос (среднее за % итераций): % мс', iterations, base_total_ms::numeric(10,3);
    
    -- Материализованное представление с индексом idx_mv_client_stats_last_purchase
    mv_total_ms := 0;
    FOR i IN 1..iterations LOOP
        start_time := clock_timestamp();
        PERFORM 
            client_id,
            Name,
            LastName,
            PhoneNumber
        FROM mv_client_statistics
        WHERE last_purchase > CURRENT_DATE - INTERVAL '30 days'
        ORDER BY LastName
        LIMIT 30;
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        mv_total_ms := mv_total_ms + duration_ms;
    END LOOP;
    mv_total_ms := mv_total_ms / iterations;
    RAISE NOTICE ' Индексированное MV (среднее за % итераций): % мс', iterations, mv_total_ms::numeric(10,3);
    RAISE NOTICE ' Ускорение: %x', (base_total_ms / NULLIF(mv_total_ms, 0))::numeric(10,2);

    -- ТЕСТ 4: Сложный аналитический запрос
    -- =====================================================
    RAISE NOTICE ' ТЕСТ 4: Анализ клиентов с группировкой по активности'; 
    -- Базовый запрос
    base_total_ms := 0;
    FOR i IN 1..iterations LOOP
        start_time := clock_timestamp();
        PERFORM 
            CASE 
                WHEN MAX(a.DatePurchase) > CURRENT_DATE - INTERVAL '30 days' THEN 'Активный'
                WHEN MAX(a.DatePurchase) > CURRENT_DATE - INTERVAL '90 days' THEN 'Недавний'
                ELSE 'Неактивный'
            END AS activity_status,
            COUNT(DISTINCT c.Id) AS client_count,
            COALESCE(SUM(a.Summ), 0) AS total_revenue,
            COALESCE(AVG(a.Summ), 0)::NUMERIC(10,2) AS avg_check
        FROM Client c
        LEFT JOIN Account a ON c.Id = a.IdClient
        GROUP BY activity_status;
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        base_total_ms := base_total_ms + duration_ms;
    END LOOP;
    base_total_ms := base_total_ms / iterations;
    RAISE NOTICE '│ Базовый запрос (среднее за % итераций): % мс', iterations, base_total_ms::numeric(10,3);
    
    -- Материализованное представление
    mv_total_ms := 0;
    FOR i IN 1..iterations LOOP
        start_time := clock_timestamp();
        PERFORM 
            CASE 
                WHEN last_purchase > CURRENT_DATE - INTERVAL '30 days' THEN 'Активный'
                WHEN last_purchase > CURRENT_DATE - INTERVAL '90 days' THEN 'Недавний'
                ELSE 'Неактивный'
            END AS activity_status,
            COUNT(*) AS client_count,
            SUM(total_spent) AS total_revenue,
            AVG(avg_check)::NUMERIC(10,2) AS avg_check
        FROM mv_client_statistics
        GROUP BY activity_status;
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        mv_total_ms := mv_total_ms + duration_ms;
    END LOOP;
    mv_total_ms := mv_total_ms / iterations;
    RAISE NOTICE ' Индексированное MV (среднее за % итераций): % мс', iterations, mv_total_ms::numeric(10,3);
    RAISE NOTICE ' Ускорение: %x', (base_total_ms / NULLIF(mv_total_ms, 0))::numeric(10,2);

    
    -- =====================================================
    -- ТЕСТ 5: Агрегация по диапазонам трат
    -- =====================================================

    RAISE NOTICE ' ТЕСТ 5: Распределение клиентов по диапазонам трат';

    -- Базовый запрос
    base_total_ms := 0;
    FOR i IN 1..iterations LOOP
        start_time := clock_timestamp();
        PERFORM 
            CASE 
                WHEN COALESCE(SUM(a.Summ), 0) = 0 THEN 'Нет покупок'
                WHEN COALESCE(SUM(a.Summ), 0) < 5000 THEN 'До 5000'
                WHEN COALESCE(SUM(a.Summ), 0) < 15000 THEN '5000-15000'
                WHEN COALESCE(SUM(a.Summ), 0) < 30000 THEN '15000-30000'
                ELSE 'Более 30000'
            END AS spending_range,
            COUNT(*) AS client_count,
            COALESCE(SUM(SUM(a.Summ)), 0) AS range_revenue
        FROM Client c
        LEFT JOIN Account a ON c.Id = a.IdClient
        GROUP BY spending_range
        ORDER BY MIN(COALESCE(SUM(a.Summ), 0));
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        base_total_ms := base_total_ms + duration_ms;
    END LOOP;
    base_total_ms := base_total_ms / iterations;
    RAISE NOTICE '│ Базовый запрос (среднее за % итераций): % мс', iterations, base_total_ms::numeric(10,3);
    
    -- Материализованное представление
    mv_total_ms := 0;
    FOR i IN 1..iterations LOOP
        start_time := clock_timestamp();
        PERFORM 
            CASE 
                WHEN total_spent = 0 THEN 'Нет покупок'
                WHEN total_spent < 5000 THEN 'До 5000'
                WHEN total_spent < 15000 THEN '5000-15000'
                WHEN total_spent < 30000 THEN '15000-30000'
                ELSE 'Более 30000'
            END AS spending_range,
            COUNT(*) AS client_count,
            SUM(total_spent) AS range_revenue
        FROM mv_client_statistics
        GROUP BY spending_range
        ORDER BY MIN(total_spent);
        end_time := clock_timestamp();
        duration_ms := EXTRACT(EPOCH FROM (end_time - start_time)) * 1000;
        mv_total_ms := mv_total_ms + duration_ms;
    END LOOP;
    mv_total_ms := mv_total_ms / iterations;
    RAISE NOTICE ' Индексированное MV (среднее за % итераций): % мс', iterations, mv_total_ms::numeric(10,3);
    RAISE NOTICE ' Ускорение: %x', (base_total_ms / NULLIF(mv_total_ms, 0))::numeric(10,2);
END $$;

-- 3. Детальный анализ планов выполнения (EXPLAIN ANALYZE)
-- =====================================================
-- Настройка вывода
SET enable_seqscan = ON;
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;
-- Анализ ТЕСТА 1: Топ-10 клиентов
\echo '=== АНАЛИЗ ТЕСТА 1: Топ-10 клиентов по сумме трат ==='
\echo ''
\echo '--- Базовый запрос (исходный SELECT) ---'
EXPLAIN (ANALYZE, BUFFERS, TIMING, FORMAT TEXT)
SELECT 
    c.Id,
    c.Name || ' ' || c.LastName AS full_name,
    COUNT(a.Id) AS checks_count,
    COALESCE(SUM(a.Summ), 0) AS total_spent
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.Name, c.LastName
ORDER BY total_spent DESC
LIMIT 10;

\echo ''
\echo '--- Материализованное представление с индексами ---'
EXPLAIN (ANALYZE, BUFFERS, TIMING, FORMAT TEXT)
SELECT 
    client_id,
    Name || ' ' || LastName AS full_name,
    actual_checks AS checks_count,
    total_spent
FROM mv_client_statistics
ORDER BY total_spent DESC
LIMIT 10;


-- Анализ ТЕСТА 2: VIP-клиенты
\echo ''
\echo '=== АНАЛИЗ ТЕСТА 2: VIP-клиенты (фильтрация) ==='
\echo ''

\echo '--- Базовый запрос (исходный SELECT) ---'
EXPLAIN (ANALYZE, BUFFERS, TIMING, FORMAT TEXT)
SELECT 
    c.Id,
    c.Name,
    c.LastName,
    COUNT(a.Id) AS checks_count,
    COALESCE(SUM(a.Summ), 0) AS total_spent
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.Name, c.LastName
HAVING COALESCE(SUM(a.Summ), 0) > 10000 OR COUNT(a.Id) > 10
ORDER BY total_spent DESC
LIMIT 20;

\echo ''
\echo '--- Материализованное представление с индексами ---'
EXPLAIN (ANALYZE, BUFFERS, TIMING, FORMAT TEXT)
SELECT 
    client_id,
    Name,
    LastName,
    actual_checks AS checks_count,
    total_spent
FROM mv_client_statistics
WHERE total_spent > 10000 OR actual_checks > 10
ORDER BY total_spent DESC
LIMIT 20;


-- Анализ ТЕСТА 3: Активные клиенты
\echo ''
\echo '=== АНАЛИЗ ТЕСТА 3: Активные клиенты (по дате) ==='
\echo ''

\echo '--- Базовый запрос (исходный SELECT) ---'
EXPLAIN (ANALYZE, BUFFERS, TIMING, FORMAT TEXT)
SELECT DISTINCT
    c.Id,
    c.Name,
    c.LastName,
    c.PhoneNumber
FROM Client c
INNER JOIN Account a ON c.Id = a.IdClient
WHERE a.DatePurchase > CURRENT_DATE - INTERVAL '30 days'
ORDER BY c.LastName
LIMIT 30;

\echo ''
\echo '--- Материализованное представление с индексами ---'
EXPLAIN (ANALYZE, BUFFERS, TIMING, FORMAT TEXT)
SELECT 
    client_id,
    Name,
    LastName,
    PhoneNumber
FROM mv_client_statistics
WHERE last_purchase > CURRENT_DATE - INTERVAL '30 days'
ORDER BY LastName
LIMIT 30;

-- 4. Информация о созданных индексах
\echo ''
\echo '=== ИНФОРМАЦИЯ ОБ ИНДЕКСАХ ==='
\echo ''
-- Список всех индексов MV
SELECT 
    indexname AS "Имя индекса",
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS "Размер",
    indexdef AS "Определение"
FROM pg_indexes 
WHERE tablename = 'mv_client_statistics'
ORDER BY pg_relation_size(indexname::regclass) DESC;

SELECT 
    indexname AS "Индекс",
    idx_scan AS "Количество сканирований",
    idx_tup_read AS "Прочитано кортежей",
    idx_tup_fetch AS "Выбрано кортежей"
FROM pg_stat_user_indexes 
WHERE tablename = 'mv_client_statistics'
   AND schemaname = 'public'
ORDER BY idx_scan DESC;
