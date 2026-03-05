-- Функция 1: Расчёт скидки клиента на основе количества покупок
-- Возвращает базовый тип (число) и использует условные инструкции
CREATE OR REPLACE FUNCTION calculate_discount_percent(
    p_client_id INTEGER,
    p_purchase_amount DECIMAL
) RETURNS DECIMAL(5,2) AS $$
DECLARE
    v_purchase_count INTEGER;
    v_discount DECIMAL(5,2) := 0;
    v_total_spent DECIMAL(10,2);
BEGIN
    -- Получаем количество покупок клиента
    SELECT NumberPurchase INTO v_purchase_count
    FROM Client
    WHERE Id = p_client_id;
    
    -- Получаем общую сумму всех покупок клиента
    SELECT COALESCE(SUM(Summ), 0) INTO v_total_spent
    FROM Account
    WHERE IdClient = p_client_id AND Status = 'оплачено';
    
    -- Расчёт скидки на основе накопительной системы
    IF v_purchase_count >= 50 OR v_total_spent > 100000 THEN
        v_discount := 15; -- VIP клиенты
    ELSIF v_purchase_count >= 30 OR v_total_spent > 50000 THEN
        v_discount := 10; -- Постоянные клиенты
    ELSIF v_purchase_count >= 10 OR v_total_spent > 15000 THEN
        v_discount := 5;  -- Регулярные клиенты
    ELSIF v_purchase_count >= 5 THEN
        v_discount := 3;  -- Новые, но активные клиенты
    ELSE
        v_discount := 0;  -- Новые клиенты
    END IF;
    
    -- Дополнительная скидка при большой сумме текущей покупки
    IF p_purchase_amount > 10000 THEN
        v_discount := v_discount + 5;
    ELSIF p_purchase_amount > 5000 THEN
        v_discount := v_discount + 2;
    END IF;
    
    -- Ограничиваем максимальную скидку
    IF v_discount > 25 THEN
        v_discount := 25;
    END IF;
    
    RETURN v_discount;
END;
$$ LANGUAGE plpgsql;

-- Пример использования:
SELECT calculate_discount_percent(1, 7500);

-- Функция 2: Получение детальной информации о составе букета
-- Возвращает SETOF с созданным типом данных
-- Создаём тип для детальной информации о букете
CREATE TYPE bouquet_composition_type AS (
    flower_species VARCHAR(64),
    flower_name VARCHAR(64),
    flower_latname VARCHAR(64),
    country VARCHAR(64),
    is_in_bouquet BOOLEAN
);

CREATE OR REPLACE FUNCTION get_bouquet_composition(
    p_bouquet_id INTEGER
) RETURNS SETOF bouquet_composition_type AS $$
DECLARE
    v_bouquet_exists BOOLEAN;
    v_flower_record RECORD;
    v_result bouquet_composition_type;
BEGIN
    -- Проверяем существование букета
    SELECT EXISTS(SELECT 1 FROM Bouquet WHERE Id = p_bouquet_id) INTO v_bouquet_exists;
    
    IF NOT v_bouquet_exists THEN
        RAISE EXCEPTION 'Букет с ID % не найден', p_bouquet_id;
    END IF;
    
    -- Используем циклическую инструкцию для обхода всех цветов
    FOR v_flower_record IN 
        SELECT f.Species, f.Name, f.LatName, f.Country, f.Id
        FROM Flowers f
        ORDER BY f.Species, f.Name
    LOOP
        v_result.flower_species := v_flower_record.Species;
        v_result.flower_name := v_flower_record.Name;
        v_result.flower_latname := v_flower_record.LatName;
        v_result.country := v_flower_record.Country;
        
        -- Проверяем, входит ли цветок в состав букета
        SELECT EXISTS(
            SELECT 1 FROM FlowersAndBouquet 
            WHERE IdFlower = v_flower_record.Id AND IdBouquet = p_bouquet_id
        ) INTO v_result.is_in_bouquet;
        
        RETURN NEXT v_result;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Пример использования:
SELECT * FROM get_bouquet_composition(1);


-- Функция 3: Расчёт прибыли магазина за период с детализацией по категориям
-- Возвращает таблицу и использует условные инструкции
CREATE OR REPLACE FUNCTION calculate_shop_profit(
    p_start_date DATE,
    p_end_date DATE
) RETURNS TABLE (
    category_name VARCHAR(64),
    total_sales DECIMAL(10,2),
    items_sold BIGINT,
    avg_price DECIMAL(10,2),
    profit_share_percent DECIMAL(5,2)
) AS $$
DECLARE
    v_total_all DECIMAL(10,2);
BEGIN
    -- Проверка корректности дат
    IF p_start_date > p_end_date THEN
        RAISE EXCEPTION 'Дата начала не может быть позже даты окончания';
    END IF;
    
    -- Получаем общую сумму всех продаж за период
    SELECT COALESCE(SUM(SummAll), 0) INTO v_total_all
    FROM Account
    WHERE DatePurchase BETWEEN p_start_date AND p_end_date
        AND Status = 'оплачено';
    
    -- Если нет продаж, возвращаем пустой результат с предупреждением
    IF v_total_all = 0 THEN
        RAISE NOTICE 'Нет продаж за указанный период';
        RETURN;
    END IF;
    
    -- Детализация по категориям товаров
    RETURN QUERY
    WITH category_sales AS (
        SELECT 
            tg.NameType AS category,
            SUM(gc.Price) AS total,
            COUNT(gc.IdAnotherGoods) AS count,
            AVG(gc.Price) AS avg_price
        FROM Account a
        JOIN GoodsCheck gc ON a.Id = gc.IdCheck
        JOIN Goods g ON gc.IdAnotherGoods = g.IdAnotherGoods
        JOIN TypeGoods tg ON g.IdType = tg.IdTypeGoods
        WHERE a.DatePurchase BETWEEN p_start_date AND p_end_date
            AND a.Status = 'оплачено'
        GROUP BY tg.NameType
    )
    SELECT 
        cs.category,
        cs.total,
        cs.count,
        ROUND(cs.avg_price::DECIMAL, 2),
        ROUND((cs.total / v_total_all * 100)::DECIMAL, 2)
    FROM category_sales cs
    ORDER BY cs.total DESC;
END;
$$ LANGUAGE plpgsql;

-- Пример использования:
SELECT * FROM calculate_shop_profit('2024-01-01', '2024-12-31');


-- Функция 4: Автоматическое создание чека с применением скидок
-- Возвращает ID созданного чека, использует транзакцию и циклические инструкции
CREATE OR REPLACE FUNCTION create_purchase_check(
    p_client_id INTEGER,
    p_bouquet_ids INTEGER[],
    p_other_goods_ids INTEGER[],
    p_quantities INTEGER[]
) RETURNS INTEGER AS $$
DECLARE
    v_check_id INTEGER;
    v_total_sum DECIMAL(10,2) := 0;
    v_discount_percent DECIMAL(5,2);
    v_final_sum DECIMAL(10,2);
    v_counter INTEGER;
    v_current_bouquet_id INTEGER;
    v_current_goods_id INTEGER;
    v_current_quantity INTEGER;
    v_bouquet_price INTEGER;
    v_goods_price DECIMAL(10,2);
BEGIN
    -- Проверка соответствия массивов
    IF array_length(p_quantities, 1) != 
       (COALESCE(array_length(p_bouquet_ids, 1), 0) + COALESCE(array_length(p_other_goods_ids, 1), 0)) THEN
        RAISE EXCEPTION 'Количество элементов в списке количеств не соответствует общему количеству товаров';
    END IF;
    
    -- Создаём запись в таблице Account
    INSERT INTO Account (IdClient, Status, DatePurchase, Summ, ProcentDiscount, SummAll)
    VALUES (p_client_id, 'оплачено', CURRENT_DATE, 0, 0, 0)
    RETURNING Id INTO v_check_id;
    
    v_counter := 1;
    
    -- Обрабатываем букеты (циклическая инструкция)
    IF p_bouquet_ids IS NOT NULL THEN
        FOREACH v_current_bouquet_id IN ARRAY p_bouquet_ids
        LOOP
            v_current_quantity := p_quantities[v_counter];
            
            -- Получаем цену букета
            SELECT Price INTO v_bouquet_price
            FROM Bouquet
            WHERE Id = v_current_bouquet_id;
            
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Букет с ID % не найден', v_current_bouquet_id;
            END IF;
            
            -- Добавляем запись в GoodsCheck
            INSERT INTO GoodsCheck (IdCheck, IdAnotherGoods, IdFlower, Price)
            SELECT 
                v_check_id,
                g.IdAnotherGoods,
                NULL,
                v_bouquet_price * v_current_quantity
            FROM Goods g
            WHERE g.IdBouquet = v_current_bouquet_id
            LIMIT 1;
            
            v_total_sum := v_total_sum + (v_bouquet_price * v_current_quantity);
            v_counter := v_counter + 1;
        END LOOP;
    END IF;
    
    -- Обрабатываем остальные товары (циклическая инструкция)
    IF p_other_goods_ids IS NOT NULL THEN
        FOREACH v_current_goods_id IN ARRAY p_other_goods_ids
        LOOP
            v_current_quantity := p_quantities[v_counter];
            
            -- Получаем цену товара (используем условную логику)
            SELECT 
                CASE 
                    WHEN ag.Name LIKE '%роза%' THEN 300
                    WHEN ag.Name LIKE '%тюльпан%' THEN 150
                    WHEN ag.Name LIKE '%игрушк%' THEN 800
                    ELSE 500
                END INTO v_goods_price
            FROM AnotherGoods ag
            WHERE ag.Id = v_current_goods_id;
            
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Товар с ID % не найден', v_current_goods_id;
            END IF;
            
            -- Добавляем запись в GoodsCheck
            INSERT INTO GoodsCheck (IdCheck, IdAnotherGoods, IdFlower, Price)
            VALUES (v_check_id, v_current_goods_id, NULL, v_goods_price * v_current_quantity);
            
            v_total_sum := v_total_sum + (v_goods_price * v_current_quantity);
            v_counter := v_counter + 1;
        END LOOP;
    END IF;
    
    -- Рассчитываем скидку
    v_discount_percent := calculate_discount_percent(p_client_id, v_total_sum);
    v_final_sum := v_total_sum * (1 - v_discount_percent / 100);
    
    -- Обновляем чек с финальными суммами
    UPDATE Account 
    SET Summ = v_total_sum,
        ProcentDiscount = v_discount_percent,
        SummAll = v_final_sum
    WHERE Id = v_check_id;
    
    -- Увеличиваем счетчик покупок клиента
    UPDATE Client 
    SET NumberPurchase = NumberPurchase + 1
    WHERE Id = p_client_id;
    
    RETURN v_check_id;
END;
$$ LANGUAGE plpgsql;

-- Пример использования:
SELECT create_purchase_check(1, ARRAY[1,2], ARRAY[4,5], ARRAY[1,2,1,1]);


-- Функция 5: Анализ популярности цветов по сезонам
-- Возвращает таблицу, использует вложенные запросы и условную логику
CREATE OR REPLACE FUNCTION analyze_flower_popularity_by_season(
    p_year INTEGER
) RETURNS TABLE (
    season VARCHAR(20),
    flower_name VARCHAR(64),
    times_sold BIGINT,
    total_revenue DECIMAL(10,2),
    popularity_rank INTEGER,
    trend_direction VARCHAR(20)
) AS $$
DECLARE
    v_current_date DATE;
    v_season_start DATE;
    v_season_end DATE;
    v_season_name VARCHAR(20);
    v_prev_period_start DATE;
    v_prev_period_end DATE;
    v_current_sales BIGINT;
    v_prev_sales BIGINT;
BEGIN
    -- Анализируем по 4 сезонам
    FOR v_season_name, v_season_start, v_season_end IN 
        VALUES 
            ('Зима', (p_year || '-12-01')::DATE, (p_year || '-02-28')::DATE),
            ('Весна', (p_year || '-03-01')::DATE, (p_year || '-05-31')::DATE),
            ('Лето', (p_year || '-06-01')::DATE, (p_year || '-08-31')::DATE),
            ('Осень', (p_year || '-09-01')::DATE, (p_year || '-11-30')::DATE)
    LOOP
        -- Корректируем зимний период
        IF v_season_name = 'Зима' THEN
            v_season_start := (p_year - 1 || '-12-01')::DATE;
        END IF;
        
        season := v_season_name;
        
        -- Получаем данные по цветам за текущий сезон
        FOR flower_name, v_current_sales, total_revenue IN
            SELECT 
                f.Name,
                COUNT(*) AS sales_count,
                SUM(gc.Price) AS revenue
            FROM Flowers f
            JOIN FlowersAndBouquet fb ON f.Id = fb.IdFlower
            JOIN Bouquet b ON fb.IdBouquet = b.Id
            JOIN Goods g ON b.Id = g.IdBouquet
            JOIN GoodsCheck gc ON g.IdAnotherGoods = gc.IdAnotherGoods
            JOIN Account a ON gc.IdCheck = a.Id
            WHERE a.DatePurchase BETWEEN v_season_start AND v_season_end
                AND a.Status = 'оплачено'
            GROUP BY f.Id, f.Name
            ORDER BY sales_count DESC
            LIMIT 5
        LOOP
            times_sold := v_current_sales;
            popularity_rank := ROW_NUMBER() OVER (ORDER BY v_current_sales DESC);
            
            -- Определяем даты для предыдущего аналогичного периода
            IF v_season_name = 'Зима' THEN
                v_prev_period_start := v_season_start - INTERVAL '1 year';
                v_prev_period_end := v_season_end - INTERVAL '1 year';
            ELSE
                v_prev_period_start := v_season_start - INTERVAL '1 year';
                v_prev_period_end := v_season_end - INTERVAL '1 year';
            END IF;
            
            -- Получаем продажи за предыдущий период
            SELECT COALESCE(COUNT(*), 0) INTO v_prev_sales
            FROM Flowers f2
            JOIN FlowersAndBouquet fb2 ON f2.Id = fb2.IdFlower
            JOIN Bouquet b2 ON fb2.IdBouquet = b2.Id
            JOIN Goods g2 ON b2.Id = g2.IdBouquet
            JOIN GoodsCheck gc2 ON g2.IdAnotherGoods = gc2.IdAnotherGoods
            JOIN Account a2 ON gc2.IdCheck = a2.Id
            WHERE f2.Name = flower_name
                AND a2.DatePurchase BETWEEN v_prev_period_start AND v_prev_period_end
                AND a2.Status = 'оплачено';
            
            -- Определяем тренд (условная инструкция)
            IF v_prev_sales = 0 THEN
                trend_direction := 'новинка';
            ELSIF v_current_sales > v_prev_sales * 1.2 THEN
                trend_direction := 'резкий рост';
            ELSIF v_current_sales > v_prev_sales THEN
                trend_direction := 'рост';
            ELSIF v_current_sales < v_prev_sales * 0.8 THEN
                trend_direction := 'резкое падение';
            ELSIF v_current_sales < v_prev_sales THEN
                trend_direction := 'падение';
            ELSE
                trend_direction := 'стабильно';
            END IF;
            
            RETURN NEXT;
        END LOOP;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- Пример использования:
SELECT * FROM analyze_flower_popularity_by_season(2024);