
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
--SET enable_seqscan = OFF;
--SET enable_bitmapscan = OFF;  -- отключить битмап-сканирование
--SET enable_indexonlyscan = ON; -- разрешить index-only сканы

SELECT a.Id, a.DatePurchase, a.Summ, c.Name, c.LastName
FROM Account a
INNER JOIN Client c ON a.IdClient = c.Id

--
SELECT c.Name, c.LastName, a.Id AS CheckId, a.DatePurchase, a.Summ
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
ORDER BY c.LastName, c.Name
--
SELECT 
    COALESCE(c.Name, 'Нет клиента') AS ClientName,
    COALESCE(c.LastName, '') AS ClientLastName,
    a.Id AS CheckId,
    a.DatePurchase,
    a.Summ
FROM Client c
FULL JOIN Account a ON c.Id = a.IdClient
WHERE a.Id IS NOT NULL OR c.Id IS NOT NULL
ORDER BY a.DatePurchase DESC NULLS LAST
--
SELECT tg.NameType AS TypeName, f.Name AS FlowerName
FROM TypeGoods tg
CROSS JOIN Flowers f
WHERE tg.IdTypeGoods <= 3 AND f.Id <= 5 -- ОГРАНИЧЕНИЕ ПРОСТО
ORDER BY tg.NameType, f.Name;
--
SELECT c.Name, c.LastName, lat.CheckId, lat.Summ, lat.DatePurchase
FROM Client c
CROSS JOIN LATERAL (
    SELECT a.Id AS CheckId, a.Summ, a.DatePurchase
    FROM Account a
    WHERE a.IdClient = c.Id
    ORDER BY a.Summ DESC
    LIMIT 3
) lat
WHERE c.Id <= 10
ORDER BY c.LastName, lat.Summ DESC;
--Самосоединение (Self Join) - клиенты с одинаковым количеством покупок
SELECT 
    c1.Name AS Client1_Name,
    c1.LastName AS Client1_LastName,
    c1.NumberPurchase AS Purchases,
    c2.Name AS Client2_Name,
    c2.LastName AS Client2_LastName
FROM Client c1
INNER JOIN Client c2 ON c1.NumberPurchase = c2.NumberPurchase AND c1.Id < c2.Id
ORDER BY c1.NumberPurchase DESC;
--
--

-- 2. Пункт Операции над множествами
SELECT Name AS ItemName, 'Flower' AS ItemType FROM Flowers
UNION
SELECT Name, 'Bouquet' FROM Bouquet
ORDER BY ItemName
LIMIT 20;
--
SELECT Name AS ItemName, 'Flower' AS ItemType
FROM Flowers
UNION ALL
SELECT Name, 'Bouquet'
FROM Bouquet
WHERE Name LIKE '%Роза%' -- Только букеты с розами
ORDER BY ItemName;
--
SELECT Id FROM Flowers -- ОНО ПУСТОЕ ТАК И ДОЛЖНО БЫТЬ
EXCEPT
SELECT DISTINCT IdFlower FROM FlowersAndBouquet WHERE IdFlower IS NOT NULL;
--
SELECT Name FROM Flowers -- ОНО ПУСТОЕ ТАК И ДОЛЖНО БЫТЬ
INTERSECT
SELECT Name FROM Bouquet;
--
--

-- 3. Пункт Предикаты
SELECT c.Name, c.LastName
FROM Client c
WHERE EXISTS (
    SELECT 1
    FROM Account a
    WHERE a.IdClient = c.Id AND a.Summ < 2000
);
--
SELECT Name, LastName, PhoneNumber
FROM Client
WHERE Name IN ('Иван', 'Мария', 'Алексей', 'Елена');
--
SELECT Name, LastName, NumberPurchase
FROM Client
WHERE NumberPurchase BETWEEN 10 AND 25
ORDER BY NumberPurchase;
--
SELECT Name, LastName, PhoneNumber
FROM Client
WHERE LastName LIKE 'Пет%';
--
SELECT Name, LastName
FROM Client
WHERE LastName ILIKE '%ов%';
--
SELECT c.Name, c.LastName
FROM Client c
WHERE 2000 < ALL (
    SELECT COALESCE(Summ, 0)
    FROM Account a
    WHERE a.IdClient = c.Id
);
--
SELECT DISTINCT c.Name, c.LastName
FROM Client c
WHERE c.Id = ANY (
    SELECT IdClient
    FROM Account
    WHERE Summ > 5000
);
--
--

-- 4. Пункт Выражения CASE
SELECT Name, LastName, NumberPurchase,
    CASE 
        WHEN NumberPurchase BETWEEN 5 AND 15 THEN 'Постоянный клиент'
        WHEN NumberPurchase BETWEEN 16 AND 25 THEN 'VIP-клиент'
        ELSE 'Супер-VIP'
    END AS ClientCategory
FROM Client
ORDER BY NumberPurchase DESC;
--
SELECT 
    Name, 
    LastName, 
    COALESCE(Otchestvo, 'нет отчества') AS MiddleName,
    COALESCE(PhoneNumber, 'телефон не указан') AS Phone
FROM Client
WHERE Id <= 25;
--
SELECT 
    Name,
    LastName,
    Otchestvo,
    NULLIF(Otchestvo, LastName) AS OtchestvoIfNotLastName
FROM Client;
--
SELECT 
    Name,
    NumberPurchase,
    LENGTH(Name) AS NameLength,
    GREATEST(NumberPurchase, LENGTH(Name), 5) AS GreatestValue
FROM Client
LIMIT 10;
--
SELECT 
    Name,
    NumberPurchase,
    LENGTH(Name) AS NameLength,
    LEAST(NumberPurchase, LENGTH(Name), 10) AS LeastValue
FROM Client
LIMIT 10;
--
--

-- 5. Пункт Встроенные функции
SELECT Name, LastName, COALESCE(Otchestvo, 'нет отчества') AS MiddleName
FROM Client
WHERE Id <= 25;
--
-- COALESCE с несколькими аргументами
SELECT 
    Name,
    LastName,
    COALESCE(Otchestvo, 'нет отчества', 'не указано') AS MiddleName,
    COALESCE(PhoneNumber, 'телефон не указан', 'нет контакта') AS ContactInfo
FROM Client
WHERE Id <= 15;
--

-- NULLIF - возвращает NULL если значения равны
SELECT 
    Name,
    LastName,
    Otchestvo,
    NULLIF(Otchestvo, LastName) AS OtchestvoIfNotEqualToLastName,
    NULLIF(NumberPurchase, 0) AS NonZeroPurchases
FROM Client
LIMIT 15;
--
-- GREATEST - возвращает наибольшее значение из списка
SELECT 
    Name,
    NumberPurchase,
    LENGTH(Name) AS NameLength,
    GREATEST(NumberPurchase, LENGTH(Name), 10) AS MaxValue,
    GREATEST(NumberPurchase, 5, 15) AS AtLeast15
FROM Client
LIMIT 15;
--
-- LEAST - возвращает наименьшее значение из списка
SELECT 
    Name,
    NumberPurchase,
    LENGTH(LastName) AS LastNameLength,
    LEAST(NumberPurchase, LENGTH(LastName), 20) AS MinValue,
    LEAST(NumberPurchase, 30, 10) AS AtMost10
FROM Client
LIMIT 15;
--
-- GREATEST и LEAST с датами
SELECT 
    Id,
    DatePurchase,
    CURRENT_DATE AS Today,
    GREATEST(DatePurchase, CURRENT_DATE - INTERVAL '30 days') AS NotOlderThan30Days,
    LEAST(DatePurchase, CURRENT_DATE) AS NotLaterThanToday
FROM Account
WHERE DatePurchase IS NOT NULL
LIMIT 15;
--
-- Функции преобразования типов CAST и ::
-- CAST в разных формах
SELECT 
    Id,
    Name,
    -- Преобразование числа в строку
    CAST(Id AS VARCHAR) AS IdAsString,
    NumberPurchase::TEXT AS PurchasesAsText,
    -- Преобразование строки в число (если возможно)
    '123'::INTEGER AS StringToInt,
    '45.67'::NUMERIC(5,2) AS StringToNumeric
FROM Client
WHERE Id <= 10;
--
-- CAST для дат и времени
SELECT 
    Id,
    DatePurchase,
    CAST(DatePurchase AS DATE) AS JustDate,
    CAST(DatePurchase AS TIMESTAMP) AS AsTimestamp,
    DatePurchase::TIME AS TimePart,
    -- Форматирование даты через CAST
    CAST(DatePurchase AS VARCHAR) AS DateAsString
FROM Account
WHERE DatePurchase IS NOT NULL
LIMIT 10;
--
-- CAST для булевых значений
SELECT 
    Name,
    LastName,
    NumberPurchase,
    (NumberPurchase > 10)::INTEGER AS IsFrequentBuyer_int,
    CAST(NumberPurchase > 15 AS VARCHAR) AS IsVIP_string,
    CAST(NumberPurchase % 2 = 0 AS TEXT) AS IsEvenPurchases
FROM Client
LIMIT 15;
--
-- Комплексное использование встроенных функций
SELECT 
    c.Name,
    c.LastName,
    c.NumberPurchase,
    COALESCE(SUM(a.Summ)::INTEGER, 0) AS TotalSpent,
    COALESCE(AVG(a.Summ)::NUMERIC(10,2), 0) AS AvgCheck,
    COUNT(a.Id)::VARCHAR || ' покупок' AS PurchasesCount,
    GREATEST(COALESCE(SUM(a.Summ), 0), 1000) AS SpendAtLeast1000,
    LEAST(COUNT(a.Id), 5) AS Max5Purchases,
    CASE 
        WHEN NULLIF(c.NumberPurchase, 0) IS NULL THEN 'Нет покупок'
        ELSE (c.NumberPurchase::VARCHAR || ' шт.')
    END AS PurchaseCountDisplay
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.Name, c.LastName, c.NumberPurchase
LIMIT 15;
--
-- Преобразование типов в условиях WHERE
SELECT 
    Name,
    LastName,
    PhoneNumber,
    NumberPurchase
FROM Client
WHERE (NumberPurchase::TEXT LIKE '%5%') OR CAST(NumberPurchase AS TEXT) LIKE '%0%'
LIMIT 10;
--
-- Использование CAST для точных вычислений
SELECT 
    Id,
    Summ,
    ProcentDiscount,
    SummAll,
    CAST(Summ AS NUMERIC) / 100 AS SummInHundreds,
    (Summ * (100 - COALESCE(ProcentDiscount, 0)) / 100)::NUMERIC(10,2) AS CalculatedSummAll,
    (Summ * GREATEST(ProcentDiscount, 5) / 100)::NUMERIC(10,2) AS DiscountWithMin5Percent
FROM Account
WHERE Summ IS NOT NULL
LIMIT 15;
--
-- COALESCE с преобразованием типов
SELECT 
    Id,
    IdClient,
    COALESCE(Status, 'не указан')::VARCHAR(20) AS OrderStatus,
    COALESCE(DatePurchase::VARCHAR, 'дата неизвестна') AS PurchaseDate,
    COALESCE(Summ::INTEGER::VARCHAR, 'сумма неизвестна') AS Amount,
    COALESCE(ProcentDiscount::VARCHAR, 'без скидки') AS Discount
FROM Account
LIMIT 20;
--
-- GREATEST и LEAST с разными типами данных
SELECT 
    Id,
    IdClient,
    Summ,
    ProcentDiscount,
    GREATEST(COALESCE(Summ, 0), COALESCE(SummAll, 0), 500) AS MaxValue,
    LEAST(COALESCE(ProcentDiscount, 0), 15, 20) AS DiscountCapped
FROM Account
LIMIT 15;
--
-- NULLIF для предотвращения деления на ноль
SELECT 
    c.Name,
    c.LastName,
    COUNT(a.Id) AS PurchasesCount,
    SUM(a.Summ) AS TotalSpent,
    CASE 
        WHEN NULLIF(COUNT(a.Id), 0) IS NOT NULL 
        THEN (SUM(a.Summ) / COUNT(a.Id))::NUMERIC(10,2)
        ELSE 0
    END AS AvgCheck
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.Name, c.LastName
LIMIT 15;
--
--

-- 6. Пункт Строки
SELECT 
    Name, 
    LENGTH(Name) AS NameLength,
    UPPER(LastName) AS LastNameUpper,
    SUBSTRING(PhoneNumber FROM 3 FOR 5) AS PhoneCodePart
FROM Client
WHERE Id <= 5;
--
-- CHR(n) - получение символа по коду ASCII/Unicode
SELECT 
    CHR(65) AS ASCII_A,
    CHR(1040) AS Russian_A, -- А
    CHR(1105) AS Russian_Yo, -- ё
    Name || CHR(32) || LastName AS FullNameWithSpace
FROM Client
WHERE Id <= 5;
--
-- UPPER, LOWER, INITCAP
SELECT 
    Name,
    UPPER(Name) AS UpperName,
    LOWER(LastName) AS LowerLastName,
    INITCAP('иван иванович иванов') AS InitCapExample,
    UPPER(SUBSTRING(Name, 1, 1)) || LOWER(SUBSTRING(Name, 2)) AS FirstUpperRestLower
FROM Client
LIMIT 10;
--
-- STRPOS и POSITION (поиск подстроки)
SELECT 
    Name,
    LastName,
    STRPOS(Name, 'а') AS FirstAPosition,
    STRPOS(LastName, 'ов') AS FirstOVPosition,
    POSITION('ова' IN LastName) AS OvaPosition,
    CASE 
        WHEN STRPOS(Name, 'ан') > 0 THEN 'Содержит "ан"'
        ELSE 'Не содержит "ан"'
    END AS ContainsAn
FROM Client
WHERE Id <= 15;
--
-- SUBSTRING с разными вариантами использования
SELECT 
    Name,
    LastName,
    PhoneNumber,
    SUBSTRING(Name, 2, 3) AS SubstrPos2Len3, -- с 2 позиции, 3 символа
    SUBSTRING(Name FROM 1 FOR 2) AS FirstTwoChars, -- альтернативный синтаксис
    SUBSTRING(PhoneNumber FROM POSITION('9' IN PhoneNumber)) AS FromFirst9,
    SUBSTRING(PhoneNumber FROM '\+7\(([0-9]{3})\)') AS AreaCode -- regex извлечение кода
FROM Client
LIMIT 10;
--
-- OVERLAY (замена части строки)
SELECT 
    Name,
    LastName,
    OVERLAY(Name PLACING '***' FROM 2) AS From2ToEnd, -- с 2 позиции до конца
    OVERLAY(PhoneNumber PLACING 'XXX' FROM 6 FOR 3) AS PhoneMasked,
    OVERLAY(LastName PLACING UPPER(SUBSTRING(LastName, 1, 1)) FROM 1 FOR 1) AS Capitalized,
    OVERLAY(Name PLACING '.' FROM LENGTH(Name) FOR 0) AS NameWithDot -- вставка в конец
FROM Client
LIMIT 10;
--
-- REPLACE (замена подстроки)
SELECT 
    Name,
    REPLACE(Name, 'а', 'А') AS ReplaceAToCapitalA,
    REPLACE(REPLACE(REPLACE(PhoneNumber, '(', ''), ')', ''), '-', '') AS CleanPhone,
    REPLACE(LastName, 'ов', 'ОВ') AS ReplaceOVToUpper,
    REPLACE(LastName, 'ва', 'ВА') AS ReplaceVAToUpper,
    -- множественная замена через вложенные REPLACE
    REPLACE(REPLACE(REPLACE(Name, 'а', 'o'), 'е', 'e'), 'и', 'i') AS LatinLike
FROM Client
LIMIT 10;
--
-- BTRIM, LTRIM, RTRIM (удаление пробелов и символов)
SELECT 
    Id,
    Name,
    '  ' || Name || '  ' AS PaddedName,
    '...' || Name || '...' AS DottedName,
    LTRIM('  ' || Name || '  ') AS LeftTrimmed,
    RTRIM('  ' || Name || '  ') AS RightTrimmed,
    BTRIM('  ' || Name || '  ') AS BothTrimmed,
    BTRIM('...' || Name || '...', '.') AS TrimDots,
    LTRIM(PhoneNumber, '+7(') AS TrimLeadingSymbols
FROM Client
WHERE Id <= 10;
--
-- Конкатенация строк (||, CONCAT, CONCAT_WS)
SELECT 
    Id,
    Name,
    LastName,
    Name || ' ' || LastName AS FullName_Concat,
    CONCAT(Name, ' ', LastName) AS FullName_ConcatFunc,
    CONCAT_WS(' - ', Name, LastName, PhoneNumber) AS ConcatenatedWithSeparator,
    CONCAT_WS(', ', LastName, Name, Otchestvo) AS FullNameCommaSeparated
FROM Client
LIMIT 10;
--
-- LEFT, RIGHT (получение первых/последних символов)
SELECT 
    Name,
    LEFT(Name, 3) AS FirstThreeChars,
    RIGHT(Name, 2) AS LastTwoChars,
    LEFT(PhoneNumber, 6) AS PhonePrefix,
    RIGHT(PhoneNumber, 4) AS PhoneSuffix
FROM Client
LIMIT 10;
--
-- LPAD, RPAD (дополнение строки до нужной длины)
SELECT 
    Name,
    LPAD(Name, 10, '*') AS LeftPadded,
    RPAD(Name, 10, '-') AS RightPadded,
    LPAD(CAST(NumberPurchase AS VARCHAR), 5, '0') AS PaddedNumber,
    RPAD(PhoneNumber, 20, '.') AS PaddedPhone
FROM Client
LIMIT 10;
--
-- REVERSE (переворот строки)
SELECT 
    Name,
    REVERSE(Name) AS ReversedName,
    LastName,
    REVERSE(LastName) AS ReversedLastName,
    CASE 
        WHEN LOWER(Name) = LOWER(REVERSE(Name)) THEN 'Палиндром'
        ELSE 'Не палиндром'
    END AS IsPalindrome
FROM Client
LIMIT 10;

-- SPLIT_PART (разделение строки)
SELECT 
    PhoneNumber,
    SPLIT_PART(PhoneNumber, '(', 2) AS AfterOpenBracket,
    SPLIT_PART(SPLIT_PART(PhoneNumber, ')', 1), '(', 2) AS AreaCode,
    SPLIT_PART(PhoneNumber, '-', 1) AS FirstPart,
    SPLIT_PART(PhoneNumber, '-', 2) AS SecondPart,
    SPLIT_PART(PhoneNumber, '-', 3) AS ThirdPart
FROM Client
WHERE PhoneNumber IS NOT NULL
LIMIT 10;
--
-- REGEXP_MATCHES, REGEXP_REPLACE (регулярные выражения)
SELECT 
    Name,
    LastName,
    PhoneNumber,
    REGEXP_REPLACE(PhoneNumber, '[^0-9]', '', 'g') AS DigitsOnly,
    REGEXP_REPLACE(PhoneNumber, '^\+7', '8') AS ReplacePlus7To8,
    REGEXP_MATCHES(PhoneNumber, '\(([0-9]{3})\)') AS CodeInParentheses
FROM Client
LIMIT 10;
--
-- Комплексные строковые преобразования
SELECT 
    Id,
    UPPER(LEFT(Name, 1)) || LOWER(SUBSTRING(Name, 2)) AS ProperName,
    CONCAT_WS(' ', 
        UPPER(LEFT(LastName, 1)) || LOWER(SUBSTRING(LastName, 2)),
        UPPER(LEFT(Name, 1)) || '.',
        CASE WHEN Otchestvo IS NOT NULL 
             THEN UPPER(LEFT(Otchestvo, 1)) || '.' 
             ELSE ''
        END
    ) AS ShortName,
    REGEXP_REPLACE(PhoneNumber, '[^0-9]', '', 'g') AS CleanPhone,
    LENGTH(REGEXP_REPLACE(PhoneNumber, '[^0-9]', '', 'g')) AS PhoneDigitCount
FROM Client
LIMIT 15;
--
--

-- 7. Пункт Дата и время
SELECT 
    Id, 
    DatePurchase,
    AGE(CURRENT_DATE, DatePurchase) AS DaysSincePurchase,
    EXTRACT(MONTH FROM DatePurchase) AS PurchaseMonth
FROM Account
LIMIT 10;
--
-- AGE - разница между датами
SELECT 
    Id,
    DatePurchase,
    AGE(CURRENT_DATE, DatePurchase) AS AgeFromToday,
    AGE(DatePurchase, '2024-01-01') AS AgeFromNewYear,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, DatePurchase)) AS YearsAgo,
    EXTRACT(MONTH FROM AGE(CURRENT_DATE, DatePurchase)) AS MonthsAgo,
    EXTRACT(DAY FROM AGE(CURRENT_DATE, DatePurchase)) AS DaysAgo
FROM Account
WHERE DatePurchase IS NOT NULL
LIMIT 15;
--
-- EXTRACT и DATE_PART (извлечение компонентов даты)
SELECT 
    DatePurchase,
    EXTRACT(YEAR FROM DatePurchase) AS Year,
    EXTRACT(MONTH FROM DatePurchase) AS Month,
    EXTRACT(DAY FROM DatePurchase) AS Day,
    EXTRACT(DOW FROM DatePurchase) AS DayOfWeek, -- 0-6, воскресенье=0
    EXTRACT(DOY FROM DatePurchase) AS DayOfYear,
    EXTRACT(WEEK FROM DatePurchase) AS WeekNumber,
    EXTRACT(QUARTER FROM DatePurchase) AS Quarter,
    EXTRACT(HOUR FROM DatePurchase) AS Hour,
    EXTRACT(MINUTE FROM DatePurchase) AS Minute,
    DATE_PART('year', DatePurchase) AS Year_DatePart,
    DATE_PART('dow', DatePurchase) AS DayOfWeek_DatePart
FROM Account
WHERE DatePurchase IS NOT NULL
LIMIT 10;
--
-- DATE_TRUNC - усечение даты до указанной точности
SELECT 
    DatePurchase,
    DATE_TRUNC('year', DatePurchase) AS StartOfYear,
    DATE_TRUNC('quarter', DatePurchase) AS StartOfQuarter,
    DATE_TRUNC('month', DatePurchase) AS StartOfMonth,
    DATE_TRUNC('week', DatePurchase) AS StartOfWeek,
    DATE_TRUNC('day', DatePurchase) AS StartOfDay,
    DATE_TRUNC('hour', DatePurchase) AS StartOfHour
FROM Account
WHERE DatePurchase IS NOT NULL
LIMIT 10;
--
-- Интервалы и арифметика с датами
SELECT 
    DatePurchase,
    DatePurchase + INTERVAL '1 day' AS PlusOneDay,
    DatePurchase - INTERVAL '1 month' AS MinusOneMonth,
    DatePurchase + INTERVAL '1 year' AS PlusOneYear,
    DatePurchase + INTERVAL '2 weeks' AS PlusTwoWeeks,
    DatePurchase + (NumberPurchase || ' days')::INTERVAL AS PlusPurchasesDays,
    CURRENT_DATE - DatePurchase AS DaysDifference
FROM Account a
JOIN Client c ON a.IdClient = c.Id
WHERE DatePurchase IS NOT NULL
LIMIT 10;
--
-- TO_CHAR - форматирование дат
SELECT 
    DatePurchase,
    TO_CHAR(DatePurchase, 'DD.MM.YYYY') AS RussianFormat,
    TO_CHAR(DatePurchase, 'YYYY-MM-DD') AS ISOFormat,
    TO_CHAR(DatePurchase, 'Day, DD Month YYYY') AS FullTextFormat,
    TO_CHAR(DatePurchase, 'HH24:MI:SS') AS TimeOnly,
    TO_CHAR(DatePurchase, 'Mon YYYY') AS MonthYear,
    TO_CHAR(DatePurchase, 'Q') AS QuarterNumber,
    TO_CHAR(DatePurchase, 'WW') AS WeekNumber
FROM Account
WHERE DatePurchase IS NOT NULL
LIMIT 10;
--
-- TO_DATE и TO_TIMESTAMP - преобразование строк в даты
SELECT 
    '2024-03-15'::DATE AS DateFromString1,
    TO_DATE('15.03.2024', 'DD.MM.YYYY') AS DateFromString2,
    TO_DATE('2024-03-15 14:30:00', 'YYYY-MM-DD HH24:MI:SS') AS DateTimeFromString,
    TO_TIMESTAMP('2024-03-15 14:30:00', 'YYYY-MM-DD HH24:MI:SS') AS TimestampFromString,
    TO_CHAR(TO_DATE('01.01.2024', 'DD.MM.YYYY'), 'Day') AS NewYearDay;
--
-- MAKE_DATE, MAKE_TIME, MAKE_TIMESTAMP
SELECT 
    MAKE_DATE(2024, 3, 15) AS CreatedDate,
    MAKE_TIME(14, 30, 45) AS CreatedTime,
    MAKE_TIMESTAMP(2024, 3, 15, 14, 30, 45) AS CreatedTimestamp,
    MAKE_TIMESTAMPTZ(2024, 3, 15, 14, 30, 45, 'Europe/Moscow') AS CreatedTimestamptz;
--
-- ISFINITE - проверка на бесконечность даты
SELECT 
    DatePurchase,
    ISFINITE(DatePurchase) AS IsFinite,
    ISFINITE('infinity'::DATE) AS IsInfinity
FROM Account
WHERE DatePurchase IS NOT NULL
LIMIT 5;
--
-- Комплексные запросы с датами
-- Статистика по дням недели
SELECT 
    EXTRACT(DOW FROM DatePurchase) AS DayOfWeek,
    COUNT(*) AS PurchasesCount,
    SUM(Summ) AS TotalSum,
    AVG(Summ)::NUMERIC(10,2) AS AvgSum
FROM Account
WHERE DatePurchase IS NOT NULL
GROUP BY EXTRACT(DOW FROM DatePurchase)
ORDER BY DayOfWeek;
--
-- Помесячная статистика
SELECT 
    DATE_TRUNC('month', DatePurchase) AS Month,
    COUNT(*) AS PurchasesCount,
    COUNT(DISTINCT IdClient) AS UniqueClients,
    SUM(Summ) AS MonthlyRevenue,
    AVG(Summ)::NUMERIC(10,2) AS AverageCheck
FROM Account
WHERE DatePurchase IS NOT NULL
GROUP BY DATE_TRUNC('month', DatePurchase)
ORDER BY Month;
--
-- Возраст клиентов чеков в днях с категоризацией
SELECT 
    Id,
    DatePurchase,
    AGE(CURRENT_DATE, DatePurchase) AS Age,
    EXTRACT(DAY FROM AGE(CURRENT_DATE, DatePurchase)) AS DaysAgo,
    CASE 
        WHEN EXTRACT(DAY FROM AGE(CURRENT_DATE, DatePurchase)) <= 30 THEN 'Последний месяц'
        WHEN EXTRACT(DAY FROM AGE(CURRENT_DATE, DatePurchase)) <= 90 THEN 'Последний квартал'
        WHEN EXTRACT(DAY FROM AGE(CURRENT_DATE, DatePurchase)) <= 180 THEN 'Последние полгода'
        ELSE 'Более 6 месяцев'
    END AS PeriodCategory
FROM Account
WHERE DatePurchase IS NOT NULL
ORDER BY DatePurchase DESC
LIMIT 20;
--
--

-- 8. Пункт Агрегатные функции GROUP BY, HAVING
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
-- Статистика по клиентам с дополнительными агрегатными функциями
SELECT 
    c.Id,
    c.Name || ' ' || c.LastName AS FullName,
    COUNT(a.Id) AS TotalChecks,
    COUNT(DISTINCT DATE_TRUNC('month', a.DatePurchase)) AS MonthsWithPurchases,
    SUM(a.Summ) AS TotalSpent,
    AVG(a.Summ)::NUMERIC(10,2) AS AverageCheckSum,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY a.Summ)::NUMERIC(10,2) AS MedianCheck, -- медиана
    MIN(a.Summ) AS MinCheckSum,
    MAX(a.Summ) AS MaxCheckSum,
    SUM(a.Summ) / NULLIF(COUNT(a.Id), 0)::NUMERIC(10,2) AS CalculatedAvg,
    MAX(a.Summ) - MIN(a.Summ) AS CheckRange
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.Name, c.LastName
HAVING COUNT(a.Id) > 0
ORDER BY TotalSpent DESC;
--
-- Группировка с несколькими уровнями (CUBE, ROLLUP)
SELECT 
    COALESCE(c.Name, 'Все') AS ClientName,
    EXTRACT(YEAR FROM a.DatePurchase)::VARCHAR AS Year,
    EXTRACT(MONTH FROM a.DatePurchase)::VARCHAR AS Month,
    COUNT(*) AS PurchaseCount,
    SUM(a.Summ) AS TotalSum
FROM Client c
JOIN Account a ON c.Id = a.IdClient
WHERE a.DatePurchase IS NOT NULL
GROUP BY ROLLUP (c.Name, EXTRACT(YEAR FROM a.DatePurchase), EXTRACT(MONTH FROM a.DatePurchase))
ORDER BY c.Name NULLS LAST, Year NULLS LAST, Month NULLS LAST
LIMIT 30;
--
-- GROUPING SETS для множественных группировок
SELECT 
    COALESCE(c.Name, 'Все клиенты') AS ClientName,
    COALESCE(tg.NameType, 'Все типы') AS GoodsType,
    COUNT(*) AS ItemsSold,
    SUM(gc.Price) AS TotalRevenue
FROM GoodsCheck gc
JOIN Account a ON gc.IdCheck = a.Id
JOIN Client c ON a.IdClient = c.Id
JOIN AnotherGoods ag ON gc.IdAnotherGoods = ag.Id
JOIN Goods g ON ag.Id = g.IdAnotherGoods
JOIN TypeGoods tg ON g.IdType = tg.IdTypeGoods
GROUP BY GROUPING SETS (
    (c.Name), -- по клиентам
    (tg.NameType), -- по типам товаров
    (c.Name, tg.NameType), -- по комбинации
    () -- общий итог
)
ORDER BY ClientName, GoodsType
LIMIT 30;
--
-- Фильтрация групп с HAVING (сложные условия)
SELECT 
    c.Id,
    c.Name || ' ' || c.LastName AS FullName,
    COUNT(a.Id) AS PurchaseCount,
    SUM(a.Summ) AS TotalSpent,
    AVG(a.Summ)::NUMERIC(10,2) AS AvgCheck,
    MAX(a.DatePurchase) AS LastPurchaseDate
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.Name, c.LastName
HAVING 
    COUNT(a.Id) >= 2 -- минимум 2 покупки
    AND SUM(a.Summ) > 5000 -- потратили более 5000
    AND AVG(a.Summ) > 1500 -- средний чек выше 1500
    AND MAX(a.DatePurchase) > CURRENT_DATE - INTERVAL '90 days' -- покупали в последние 90 дней
ORDER BY TotalSpent DESC;
--
-- Агрегатные функции с условием (FILTER)
SELECT 
    c.Name || ' ' || c.LastName AS FullName,
    COUNT(*) AS TotalPurchases,
    COUNT(*) FILTER (WHERE a.Summ < 2000) AS SmallPurchases,
    COUNT(*) FILTER (WHERE a.Summ BETWEEN 2000 AND 5000) AS MediumPurchases,
    COUNT(*) FILTER (WHERE a.Summ > 5000) AS LargePurchases,
    SUM(a.Summ) FILTER (WHERE a.Status = 'возврат') AS ReturnedSum,
    SUM(a.Summ) FILTER (WHERE a.Status = 'оплачено') AS PaidSum,
    AVG(a.Summ) FILTER (WHERE a.ProcentDiscount > 0)::NUMERIC(10,2) AS AvgCheckWithDiscount
FROM Client c
JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.Name, c.LastName
HAVING COUNT(*) > 0
ORDER BY TotalPurchases DESC
LIMIT 15;
--
-- Группировка по нескольким полям с вычисляемыми колонками
SELECT 
    EXTRACT(YEAR FROM a.DatePurchase) AS Year,
    EXTRACT(QUARTER FROM a.DatePurchase) AS Quarter,
    COUNT(DISTINCT a.IdClient) AS UniqueCustomers,
    COUNT(*) AS TotalTransactions,
    SUM(a.Summ) AS Revenue,
    AVG(a.Summ)::NUMERIC(10,2) AS AvgTransaction,
    SUM(a.Summ) / COUNT(DISTINCT a.IdClient)::NUMERIC(10,2) AS RevenuePerCustomer,
    COUNT(*) / COUNT(DISTINCT a.IdClient)::NUMERIC(10,2) AS TransactionsPerCustomer
FROM Account a
WHERE a.DatePurchase IS NOT NULL
GROUP BY EXTRACT(YEAR FROM a.DatePurchase), EXTRACT(QUARTER FROM a.DatePurchase)
ORDER BY Year, Quarter;
--
-- Статистика по категориям клиентов
SELECT 
    CASE 
        WHEN c.NumberPurchase < 10 THEN 'Новичок'
        WHEN c.NumberPurchase < 20 THEN 'Регулярный'
        WHEN c.NumberPurchase < 30 THEN 'Постоянный'
        ELSE 'VIP'
    END AS ClientCategory,
    COUNT(DISTINCT c.Id) AS ClientCount,
    COUNT(a.Id) AS TotalPurchases,
    SUM(a.Summ) AS TotalSpent,
    AVG(a.Summ)::NUMERIC(10,2) AS AvgCheck,
    SUM(a.Summ) / NULLIF(COUNT(DISTINCT c.Id), 0)::NUMERIC(10,2) AS SpentPerClient
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
GROUP BY 
    CASE 
        WHEN c.NumberPurchase < 10 THEN 'Новичок'
        WHEN c.NumberPurchase < 20 THEN 'Регулярный'
        WHEN c.NumberPurchase < 30 THEN 'Постоянный'
        ELSE 'VIP'
    END
ORDER BY 
    MIN(c.NumberPurchase);
--
-- Группировка с сортировкой по агрегатным функциям и LIMIT
SELECT 
    ag.Name AS ProductName,
    COUNT(gc.Id) AS TimesSold,
    SUM(gc.Price) AS TotalRevenue,
    AVG(gc.Price)::NUMERIC(10,2) AS AvgPrice,
    COUNT(DISTINCT a.IdClient) AS UniqueBuyers
FROM AnotherGoods ag
JOIN GoodsCheck gc ON ag.Id = gc.IdAnotherGoods
JOIN Account a ON gc.IdCheck = a.Id
GROUP BY ag.Id, ag.Name
ORDER BY TotalRevenue DESC
LIMIT 10; -- Топ-10 товаров по выручке
--
-- HAVING с подзапросом
SELECT 
    c.Id,
    c.Name || ' ' || c.LastName AS FullName,
    COUNT(a.Id) AS PurchaseCount,
    SUM(a.Summ) AS TotalSpent
FROM Client c
JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.Name, c.LastName
HAVING SUM(a.Summ) > (
    SELECT AVG(TotalSpent) 
    FROM (
        SELECT SUM(Summ) AS TotalSpent
        FROM Account
        GROUP BY IdClient
    ) AS ClientTotals
)
ORDER BY TotalSpent DESC;
--
-- Группировка с несколькими агрегатными функциями и аналитическими вычислениями
SELECT 
    c.Name || ' ' || c.LastName AS Client,
    DATE_TRUNC('month', a.DatePurchase)::DATE AS Month,
    COUNT(*) AS MonthlyPurchases,
    SUM(a.Summ) AS MonthlySpent,
    ROUND(
        100.0 * SUM(a.Summ) / SUM(SUM(a.Summ)) OVER (PARTITION BY c.Id), 
        2
    ) AS PercentOfClientTotal,
    ROUND(
        100.0 * SUM(a.Summ) / SUM(SUM(a.Summ)) OVER (), 
        2
    ) AS PercentOfOverallTotal
FROM Client c
JOIN Account a ON c.Id = a.IdClient
WHERE a.DatePurchase IS NOT NULL
GROUP BY c.Id, c.Name, c.LastName, DATE_TRUNC('month', a.DatePurchase)
ORDER BY c.LastName, Month;
--

