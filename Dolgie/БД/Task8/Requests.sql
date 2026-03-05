
-- Очитска таблицы
TRUNCATE TABLE GoodsCheck, Account, Goods, FlowersAndBouquet, 
             Bouquet, Flowers, AnotherGoods, TypeGoods, Client RESTART IDENTITY CASCADE;
--

-- Заполнение -- 
-- Клиенты
INSERT INTO Client (Name, LastName, Otchestvo, PhoneNumber, NumberPurchase) VALUES
('Иван', 'Иванов', 'Иванович', '+7(999)123-45-67', 10),
('Мария', 'Петрова', 'Сергеевна', '+7(912)345-67-89', 25),
('Алексей', 'Сидоров', 'Алексеевич', '+7(905)678-90-12', 5),
('Ольга', 'Смирнова', 'Ивановна', '+7(916)234-56-78', 15),
('Дмитрий', 'Кузнецов', 'Дмитриевич', '+7(903)456-78-90', 30),
('Елена', 'Попова', 'Владимировна', '+7(925)567-89-01', 8),
('Сергей', 'Васильев', NULL, '+7(926)678-90-12', 12),
('Анна', 'Павлова', 'Андреевна', '+7(927)789-01-23', 20),
('Андрей', 'Семенов', 'Петрович', '+7(928)890-12-34', 3),
('Наталья', 'Голубева', NULL, '+7(929)901-23-45', 18);
--

-- Старый запрос(он был тестовым, и я решила его оставить)
INSERT INTO Client (Name, LastName, Otchestvo, PhoneNumber, NumberPurchase)
SELECT 
    first_names.name,
    last_names.lastname,
    CASE WHEN random() > 0.3 THEN middle_names.middlename ELSE NULL END,
    '+7(9' || lpad((floor(random() * 100))::text, 2, '0') || ')' || 
    lpad((floor(random() * 1000))::text, 3, '0') || '-' ||
    lpad((floor(random() * 100))::text, 2, '0') || '-' ||
    lpad((floor(random() * 100))::text, 2, '0'),
    floor(random() * 50)
FROM 
    (VALUES ('Петр'), ('Михаил'), ('Владимир'), ('Екатерина'), ('Светлана'),
            ('Татьяна'), ('Юлия'), ('Александр'), ('Николай'), ('Виктор')) first_names(name)
CROSS JOIN 
    (VALUES ('Воробьев'), ('Лебедев'), ('Зайцев'), ('Соловьев'), ('Волков'),
            ('Козлов'), ('Новиков'), ('Морозов'), ('Егоров'), ('Алексеев')) last_names(lastname)
CROSS JOIN 
    (VALUES ('Олегович'), ('Михайлович'), ('Владимирович'), ('Николаевич'),
            ('Олеговна'), ('Михайловна'), ('Владимировна'), ('Николаевна')) middle_names(middlename)
LIMIT 40;

-- Цветы
INSERT INTO Flowers (Species, Name, LatName, Country) VALUES
('Роза', 'Красная роза', 'Rosa rubra', 'Нидерланды'),
('Роза', 'Белая роза', 'Rosa alba', 'Нидерланды'),
('Роза', 'Розовая роза', 'Rosa pink', 'Эквадор'),
('Роза', 'Желтая роза', 'Rosa yellow', 'Кения'),
('Тюльпан', 'Тюльпан красный', 'Tulipa gesneriana', 'Россия'),
('Тюльпан', 'Тюльпан желтый', 'Tulipa yellow', 'Россия'),
('Хризантема', 'Хризантема белая', 'Chrysanthemum', 'Италия'),
('Хризантема', 'Хризантема желтая', 'Chrysanthemum', 'Италия'),
('Пион', 'Пион розовый', 'Paeonia lactiflora', 'Франция'),
('Пион', 'Пион белый', 'Paeonia alba', 'Франция'),
('Гвоздика', 'Гвоздика красная', 'Dianthus', 'Россия'),
('Гортензия', 'Гортензия голубая', 'Hydrangea', 'Япония');
--

-- Букеты
INSERT INTO Bouquet (Name, Quantity, Structure, Price) VALUES
('Романтический', 15, 'Красные розы, зелень', 3500),
('Нежный', 11, 'Белые розы, пионы', 4200),
('Солнечный', 9, 'Желтые тюльпаны, хризантемы', 2800),
('Королевский', 25, 'Розы, пионы, хризантемы', 6500),
('Минимализм', 7, 'Белые хризантемы', 1800),
('Весенний', 13, 'Тюльпаны, нарциссы', 3200),
('Свадебный', 21, 'Белые розы, гортензия', 5500),
('Юбилейный', 31, 'Ассорти из 5 видов цветов', 7800),
('Детский', 9, 'Мелкие разноцветные цветы', 2100),
('Премиум', 51, 'Эксклюзивная композиция', 12500);
--

-- Типы товаров
INSERT INTO TypeGoods (NameType) VALUES
('Букеты'), ('Цветы в упаковке'), ('Горшечные растения'), 
('Сухоцветы'), ('Открытки'), ('Мягкие игрушки'),
('Композиции'), ('Сопутствующие товары');
--

-- Прочее
INSERT INTO AnotherGoods (Name) VALUES
('Роза красная в упаковке'), ('Тюльпаны набор 5 шт'), ('Кактус в горшке'),
('Открытка "С любовью"'), ('Медведь 30 см'), ('Лаванда сухая'),
('Хризантема в горшке'), ('Открытка "С днём рождения"'), ('Зайка мягкая'),
('Букет розовый смешанный'), ('Роза белая в упаковке'), ('Фиалка в горшке'),
('Набор открыток'), ('Собачка мягкая'), ('Эустома в горшке'),
('Композиция в корзине'), ('Ваза стеклянная'), ('Лента упаковочная');
--

-- Цветы и букеты. Связь
INSERT INTO FlowersAndBouquet (IdFlower, IdBouquet) VALUES
-- Романтический (букет 1)
(1, 1), (2, 1),
-- Нежный (букет 2)
(2, 2), (9, 2), (10, 2),
-- Солнечный (букет 3)
(4, 3), (5, 3), (6, 3), (8, 3),
-- Королевский (букет 4)
(1, 4), (3, 4), (7, 4), (9, 4),
-- Минимализм (букет 5)
(7, 5),
-- Весенний (букет 6)
(5, 6), (6, 6),
-- Свадебный (букет 7)
(2, 7), (10, 7), (12, 7),
-- Юбилейный (букет 8)
(1, 8), (3, 8), (7, 8), (9, 8), (11, 8),
-- Детский (букет 9)
(3, 9), (5, 9), (8, 9),
-- Премиум (букет 10)
(1, 10), (3, 10), (9, 10), (12, 10);
--

-- Товары
INSERT INTO Goods (IdAnotherGoods, IdType, IdBouquet) VALUES
-- Тип 1 (Букеты)
(10, 1, 1), (1, 1, 2), (2, 1, 3), (3, 1, 4), (4, 1, 5),
-- Тип 2 (Цветы в упаковке)
(1, 2, NULL), (2, 2, NULL), (11, 2, NULL),
-- Тип 3 (Горшечные растения)
(3, 3, NULL), (7, 3, NULL), (12, 3, NULL), (15, 3, NULL),
-- Тип 4 (Сухоцветы)
(6, 4, NULL),
-- Тип 5 (Открытки)
(4, 5, NULL), (8, 5, NULL), (13, 5, NULL),
-- Тип 6 (Мягкие игрушки)
(5, 6, NULL), (9, 6, NULL), (14, 6, NULL),
-- Тип 7 (Композиции)
(16, 7, NULL),
-- Тип 8 (Сопутствующие товары)
(17, 8, NULL), (18, 8, NULL);
--

-- Чеки
INSERT INTO Account (IdClient, Status, DatePurchase, Summ, ProcentDiscount, SummAll)
SELECT 
    c.Id,
    'оплачено',
    CURRENT_DATE - (floor(random() * 180)::int || ' days')::interval,
    1500 + floor(random() * 10000),
    CASE WHEN random() > 0.7 THEN floor(random() * 20) ELSE 0 END,
    1500 + floor(random() * 10000) * (1 - CASE WHEN random() > 0.7 THEN floor(random() * 20) / 100.0 ELSE 0 END)
FROM Client c
CROSS JOIN generate_series(1, 3) -- по 3 чека на каждого клиента
WHERE c.Id <= 20; -- Для первых 20 клиентов
--

-- Добавление еще активных клиентов
INSERT INTO Account (IdClient, Status, DatePurchase, Summ, ProcentDiscount, SummAll)
SELECT 
    c.Id,
    CASE WHEN random() > 0.9 THEN 'возврат' ELSE 'оплачено' END,
    CURRENT_DATE - (floor(random() * 60)::int || ' days')::interval,
    2000 + floor(random() * 15000),
    CASE WHEN random() > 0.6 THEN floor(random() * 15) ELSE 0 END,
    2000 + floor(random() * 15000) * (1 - CASE WHEN random() > 0.6 THEN floor(random() * 15) / 100.0 ELSE 0 END)
FROM Client c
CROSS JOIN generate_series(1, 2) -- еще по 2 чека
WHERE c.NumberPurchase > 15; -- Только для клиентов с большим числом покупок

-- Товары в чеке
INSERT INTO GoodsCheck (IdCheck, IdAnotherGoods, IdFlower, Price)
SELECT 
    a.Id,
    ag.Id,
    CASE WHEN random() > 0.7 THEN f.Id ELSE NULL END,
    ag.Id * 100 + floor(random() * 1000)
FROM Account a
CROSS JOIN AnotherGoods ag
LEFT JOIN Flowers f ON f.Id = ag.Id % 12 + 1
WHERE random() > 0.7 -- Не для всех товаров, чтобы не было слишком много записей
LIMIT 100;


-- ЗАПРОСЫ -- 
-- 1. Пункт Соеденения
SELECT '--- 1. INNER JOIN ---' AS query_type;
SELECT a.Id, a.DatePurchase, a.Summ, c.Name, c.LastName
FROM Account a
INNER JOIN Client c ON a.IdClient = c.Id
LIMIT 10;
--

-- 2. Пункт Операции над множествами
SELECT '--- 2. UNION ---' AS query_type;
SELECT Name AS ItemName, 'Flower' AS ItemType FROM Flowers
UNION
SELECT Name, 'Bouquet' FROM Bouquet
ORDER BY ItemName
LIMIT 20;
--

-- 3. Пункт Предикаты
SELECT '--- 3. EXISTS ---' AS query_type;
SELECT c.Name, c.LastName
FROM Client c
WHERE EXISTS (
    SELECT 1
    FROM Account a
    WHERE a.IdClient = c.Id AND a.Summ < 2000
);
--

-- 4. Пункт Выражения CASE
SELECT '--- 4. CASE ---' AS query_type;
SELECT Name, LastName, NumberPurchase,
    CASE 
        WHEN NumberPurchase BETWEEN 5 AND 15 THEN 'Постоянный клиент'
        WHEN NumberPurchase BETWEEN 16 AND 25 THEN 'VIP-клиент'
        ELSE 'Супер-VIP'
    END AS ClientCategory
FROM Client
ORDER BY NumberPurchase DESC;
--

-- 5. Пункт Встроенные функции
SELECT '--- 5. COALESCE ---' AS query_type;
SELECT Name, LastName, COALESCE(Otchestvo, 'нет отчества') AS MiddleName
FROM Client
WHERE Id <= 25;
--

-- 6. Пункт Строки
SELECT '--- 6. STRING FUNCTIONS ---' AS query_type;
SELECT 
    Name, 
    LENGTH(Name) AS NameLength,
    UPPER(LastName) AS LastNameUpper,
    SUBSTRING(PhoneNumber FROM 3 FOR 5) AS PhoneCodePart
FROM Client
WHERE Id <= 5;
--

-- 7. Пункт Дата и время
SELECT '--- 7. DATE FUNCTIONS ---' AS query_type;
SELECT 
    Id, 
    DatePurchase,
    AGE(CURRENT_DATE, DatePurchase) AS DaysSincePurchase,
    EXTRACT(MONTH FROM DatePurchase) AS PurchaseMonth
FROM Account
LIMIT 10;
--

-- 8. Пункт Агрегатные функции GROUP BY, HAVING
SELECT '--- 8. AGGREGATE FUNCTIONS ---' AS query_type;
SELECT 
    c.Id, 
    c.Name || ' ' || c.LastName AS FullName,
    COUNT(a.Id) AS TotalChecks,
    SUM(a.Summ) AS TotalSpent,
    AVG(a.Summ) AS AverageCheckSum,
    MIN(a.Summ) AS MinCheckSum,
    MAX(a.Summ) AS MaxCheckSum
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.Name, c.LastName
HAVING COUNT(a.Id) > 0
ORDER BY TotalSpent DESC;
-- 

-- Индексы

-- Индексы B-Tree
-- ===================================================

-- 1. Простой индекс B-Tree
-- Для запросов с соединениями (JOIN)
CREATE INDEX idx_account_idclient ON Account(IdClient);

-- 2. Уникальный индекс B-Tree
-- Для уникальности номеров телефонов клиентов
CREATE UNIQUE INDEX idx_client_phone_unique ON Client(PhoneNumber);

-- 3. Составной индекс B-Tree
-- Для запросов с фильтрацией по дате и статусу
CREATE INDEX idx_account_date_status ON Account(DatePurchase, Status);

-- 4. Индекс с использованием выражения
-- Для поиска по фамилии в верхнем регистре
CREATE INDEX idx_client_lastname_upper ON Client(UPPER(LastName));

-- 5. Покрывающий индекс (включает все поля, используемые в запросе)
-- Покрывает запрос с агрегатными функциями
CREATE INDEX idx_client_covering ON Client(Id, Name, LastName, NumberPurchase) 
INCLUDE (Otchestvo, PhoneNumber);

-- 6. Частичный индекс
-- Только для оплаченных чеков с большой суммой
CREATE INDEX idx_account_paid_large ON Account(IdClient, Summ) 
WHERE Status = 'оплачено' AND Summ > 5000;

-- 7. Частичный покрывающий индекс
-- Для VIP-клиентов с покрытием всех полей
CREATE INDEX idx_client_vip_covering ON Client(Id, Name, LastName, NumberPurchase) 
INCLUDE (Otchestvo, PhoneNumber) 
WHERE NumberPurchase > 25;


-- Индексы Hash
-- ===================================================

-- 1. Простой индекс Hash
-- Для точного поиска по имени клиента
CREATE INDEX idx_client_name_hash ON Client USING HASH(Name);

-- 4. Индекс Hash с использованием выражения
-- Для точного поиска по нормализованному телефону
CREATE INDEX idx_client_phone_clean_hash ON Client USING HASH(
    REGEXP_REPLACE(PhoneNumber, '[^0-9]', '', 'g')
);

-- 5. Покрывающий индекс Hash (PostgreSQL не поддерживает INCLUDE с HASH, создаем составной)
CREATE INDEX idx_client_covering_hash ON Client USING HASH(Id) 
WHERE Id IS NOT NULL;

-- 6. Частичный индекс Hash
-- Для активных клиентов с большим числом покупок
CREATE INDEX idx_client_active_hash ON Client USING HASH(Id) 
WHERE NumberPurchase > 20;

-- 7. Частичный покрывающий индекс Hash (имитация через составной индекс)
CREATE INDEX idx_client_vip_hash ON Client USING HASH(Id) 
WHERE NumberPurchase > 25;


-- Индексы для конкретных запросов из файла
-- ===================================================

-- Для запроса с EXISTS (поиск чеков с суммой < 2000)
CREATE INDEX idx_account_summ_low ON Account(IdClient, Summ) WHERE Summ < 2000;

-- Для запроса с UNION (поиск по названиям)
CREATE INDEX idx_flowers_name ON Flowers(Name);
CREATE INDEX idx_bouquet_name ON Bouquet(Name);

-- Для запросов с функциями строк (SUBSTRING, UPPER)
CREATE INDEX idx_client_phone_part ON Client(SUBSTRING(PhoneNumber FROM 3 FOR 5));

-- Для запросов с функциями даты
CREATE INDEX idx_account_month ON Account(EXTRACT(MONTH FROM DatePurchase), IdClient);

-- Для агрегатных запросов с GROUP BY
CREATE INDEX idx_account_aggregate ON Account(IdClient, Summ) INCLUDE (DatePurchase);

-- Для вложенных запросов
CREATE INDEX idx_goods_type ON Goods(IdType, IdBouquet, IdAnotherGoods);

-- Для запросов с INTERSECT
CREATE INDEX idx_flowers_country ON Flowers(Country, Name);


-- Индексы для операторов сравнения
-- ===================================================

-- Для BETWEEN (по дате)
CREATE INDEX idx_account_date_range ON Account(DatePurchase) INCLUDE (Summ, Status);

-- Для LIKE (поиск по имени с шаблоном)
CREATE INDEX idx_client_name_like ON Client(Name text_pattern_ops);

-- Для ILIKE (регистронезависимый поиск)
CREATE INDEX idx_client_name_ilike ON Client(LOWER(Name));

-- Для операторов ALL, ANY, SOME
CREATE INDEX idx_account_summ_comparison ON Account(Summ, IdClient);

-- Для оператора IN (по статусам)
CREATE INDEX idx_account_status_in ON Account(Status) WHERE Status IN ('оплачено', 'возврат');


-- Дополнительные индексы для оптимизации
-- ===================================================

-- Для связи FlowersAndBouquet
CREATE INDEX idx_flowersbouquet_flower ON FlowersAndBouquet(IdFlower);
CREATE INDEX idx_flowersbouquet_bouquet ON FlowersAndBouquet(IdBouquet);

-- Для связи GoodsCheck
CREATE INDEX idx_goodscheck_check ON GoodsCheck(IdCheck);
CREATE INDEX idx_goodscheck_goods ON GoodsCheck(IdAnotherGoods);

-- Составной индекс для частого соединения
CREATE INDEX idx_goods_composite ON Goods(IdType, IdBouquet, IdAnotherGoods);

-- Индекс для поиска по цене в чеке
CREATE INDEX idx_account_summ_range ON Account(Summ) WHERE Summ IS NOT NULL;

-- Индекс для сортировки по дате
CREATE INDEX idx_account_date_desc ON Account(DatePurchase DESC);

-- Индекс для поиска клиентов без отчества
CREATE INDEX idx_client_no_middle ON Client(Id) WHERE Otchestvo IS NULL;


-- Все индексы с информацией о таблицах
SELECT 
    tablename AS table_name,
    indexname AS index_name,
    indexdef AS index_definition
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
