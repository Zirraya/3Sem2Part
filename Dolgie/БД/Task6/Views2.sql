-- Создание обновляемых представлений с CHECK OPTION для цветочного магазин
-- БАЗОВОЕ ПРЕДСТАВЛЕНИЕ (без CHECK OPTION)
-- Представление для клиентов из Москвы (телефонный код 495/499/903/916/925/926/927/928/929)
-- и с количеством покупок более 10

CREATE OR REPLACE VIEW MoscowClients AS
SELECT 
    Id,
    Name,
    LastName,
    Otchestvo,
    PhoneNumber,
    NumberPurchase
FROM Client
WHERE 
    (PhoneNumber LIKE '%(495)%' OR 
     PhoneNumber LIKE '%(499)%' OR
     PhoneNumber LIKE '%(903)%' OR
     PhoneNumber LIKE '%(916)%' OR
     PhoneNumber LIKE '%(925)%' OR
     PhoneNumber LIKE '%(926)%' OR
     PhoneNumber LIKE '%(927)%' OR
     PhoneNumber LIKE '%(928)%' OR
     PhoneNumber LIKE '%(929)%')
    AND NumberPurchase > 10;

-- Проверка базового представления
SELECT '--- БАЗОВОЕ ПРЕДСТАВЛЕНИЕ MoscowClients ---' AS info;
SELECT * FROM MoscowClients ORDER BY NumberPurchase DESC;

-- ПРЕДСТАВЛЕНИЕ 1: С LOCAL CHECK OPTION
-- Представление для VIP-клиентов из Москвы (NumberPurchase > 20)
-- Основано на MoscowClients, но с LOCAL CHECK OPTION

CREATE OR REPLACE VIEW MoscowVIPClients_Local AS
SELECT *
FROM MoscowClients
WHERE NumberPurchase > 20
WITH LOCAL CHECK OPTION;

-- Проверка представления с LOCAL CHECK OPTION
SELECT '--- ПРЕДСТАВЛЕНИЕ С LOCAL CHECK OPTION: MoscowVIPClients_Local ---' AS info;
SELECT * FROM MoscowVIPClients_Local;

-- ===== ТЕСТИРОВАНИЕ LOCAL CHECK OPTION =====

-- ТЕСТ 1: Вставка строки, удовлетворяющей условиям ОБОИХ представлений
-- (NumberPurchase > 20 И код Москвы И NumberPurchase > 10)
SELECT '--- ТЕСТ 1 (LOCAL): Вставка корректных данных (должна пройти) ---' AS test;

INSERT INTO MoscowVIPClients_Local (Name, LastName, Otchestvo, PhoneNumber, NumberPurchase)
VALUES ('Иван', 'Московский', 'Петрович', '+7(903)123-45-67', 25);

-- Проверка результата
SELECT 'Результат после ТЕСТА 1:' AS result;
SELECT * FROM MoscowVIPClients_Local WHERE LastName = 'Московский';
SELECT * FROM MoscowClients WHERE LastName = 'Московский';
SELECT * FROM Client WHERE LastName = 'Московский';


-- ТЕСТ 2: Вставка строки, удовлетворяющей условию LOCAL (NumberPurchase > 20),
-- но НЕ удовлетворяющей условию базового представления (код не Москвы)
-- ДОЛЖНА ПРОЙТИ, т.к. LOCAL проверяет ТОЛЬКО условия своего представления
SELECT '--- ТЕСТ 2 (LOCAL): Вставка с немосковским номером (должна ПРОЙТИ) ---' AS test;

INSERT INTO MoscowVIPClients_Local (Name, LastName, Otchestvo, PhoneNumber, NumberPurchase)
VALUES ('Петр', 'Немосковский', 'Сергеевич', '+7(812)123-45-67', 22);

-- Проверка результата
SELECT 'Результат после ТЕСТА 2:' AS result;
SELECT * FROM MoscowVIPClients_Local WHERE LastName = 'Немосковский';
SELECT * FROM MoscowClients WHERE LastName = 'Немосковский'; -- НЕ ВИДНО в базовом представлении!
SELECT * FROM Client WHERE LastName = 'Немосковский'; -- Но есть в таблице!


-- ТЕСТ 3: Вставка строки, НЕ удовлетворяющей условию LOCAL (NumberPurchase <= 20)
-- ДОЛЖНА ВЫЗВАТЬ ОШИБКУ
SELECT '--- ТЕСТ 3 (LOCAL): Вставка с NumberPurchase <= 20 (должна быть ОШИБКА) ---' AS test;


-- ПРЕДСТАВЛЕНИЕ 2: С CASCADED CHECK OPTION
-- Представление для VIP-клиентов из Москвы (NumberPurchase > 20)
-- Основано на MoscowClients, но с CASCADED CHECK OPTION

CREATE OR REPLACE VIEW MoscowVIPClients_Cascaded AS
SELECT *
FROM MoscowClients
WHERE NumberPurchase > 20
WITH CASCADED CHECK OPTION;

-- Проверка представления с CASCADED CHECK OPTION
SELECT '--- ПРЕДСТАВЛЕНИЕ С CASCADED CHECK OPTION: MoscowVIPClients_Cascaded ---' AS info;
SELECT * FROM MoscowVIPClients_Cascaded;

-- ТЕСТ 4: Вставка строки, удовлетворяющей условиям ВСЕХ представлений
-- (NumberPurchase > 20 И код Москвы И NumberPurchase > 10)
SELECT '--- ТЕСТ 4 (CASCADED): Вставка корректных данных (должна пройти) ---' AS test;

INSERT INTO MoscowVIPClients_Cascaded (Name, LastName, Otchestvo, PhoneNumber, NumberPurchase)
VALUES ('Анна', 'Московская', 'Владимировна', '+7(916)123-45-67', 28);

-- Проверка результата
SELECT 'Результат после ТЕСТА 4:' AS result;
SELECT * FROM MoscowVIPClients_Cascaded WHERE LastName = 'Московская';
SELECT * FROM MoscowClients WHERE LastName = 'Московская';
SELECT * FROM Client WHERE LastName = 'Московская';

-- ТЕСТ 5: Вставка строки, удовлетворяющей условию LOCAL (NumberPurchase > 20),
-- но НЕ удовлетворяющей условию базового представления (код не Москвы)
-- ДОЛЖНА ВЫЗВАТЬ ОШИБКУ, т.к. CASCADED проверяет ВСЕ условия
SELECT '--- ТЕСТ 5 (CASCADED): Вставка с немосковским номером (должна быть ОШИБКА) ---' AS test;

-- Для теста ошибки
-- INSERT INTO MoscowVIPClients_Cascaded (Name, LastName, Otchestvo, PhoneNumber, NumberPurchase)
-- VALUES ('Ольга', 'Питерская', 'Андреевна', '+7(812)123-45-67', 23);

-- Запрос не выполнится из-за ошибки

-- ТЕСТ 6: Вставка строки с московским номером, но НЕ удовлетворяющей условию NumberPurchase > 20
-- ДОЛЖНА ВЫЗВАТЬ ОШИБКУ
SELECT '--- ТЕСТ 6 (CASCADED): Вставка с NumberPurchase <= 20 (должна быть ОШИБКА) ---' AS test;
-- -- Для теста ошибки
-- INSERT INTO MoscowVIPClients_Cascaded (Name, LastName, Otchestvo, PhoneNumber, NumberPurchase)
-- VALUES ('Дмитрий', 'Московский', 'Иванович', '+7(903)123-45-67', 15);
-- Запрос не выполнится из-за ошибки




