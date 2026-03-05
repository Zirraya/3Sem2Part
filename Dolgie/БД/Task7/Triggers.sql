--AFTER INSERT триггер для обновления количества покупок клиента
-- Функция для обновления количества покупок клиента
CREATE OR REPLACE FUNCTION update_client_purchase_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Обновляем количество покупок клиента
    UPDATE Client 
    SET NumberPurchase = NumberPurchase + 1
    WHERE Id = NEW.IdClient;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер AFTER INSERT на таблицу Account
CREATE TRIGGER after_insert_account
    AFTER INSERT ON Account
    FOR EACH ROW
    EXECUTE FUNCTION update_client_purchase_count();
--

-- Создаем представление для удобной работы с чеками
CREATE OR REPLACE VIEW CheckDetails AS
SELECT 
    gc.IdCheck,
    gc.IdAnotherGoods,
    gc.IdFlower,
    gc.Price,
    a.IdClient,
    a.DatePurchase
FROM GoodsCheck gc
JOIN Account a ON gc.IdCheck = a.Id;

-- Функция для вставки через представление
CREATE OR REPLACE FUNCTION insert_check_detail()
RETURNS TRIGGER AS $$
DECLARE
    v_client_id INTEGER;
    v_check_date DATE;
    v_flower_exists BOOLEAN;
BEGIN
    -- Проверяем существование чека
    SELECT IdClient, DatePurchase INTO v_client_id, v_check_date
    FROM Account WHERE Id = NEW.IdCheck;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Чек с ID % не существует', NEW.IdCheck;
    END IF;
    
    -- Проверяем, что цена положительная
    IF NEW.Price <= 0 THEN
        RAISE EXCEPTION 'Цена товара должна быть положительной';
    END IF;
    
    -- Если указан цветок, проверяем его существование
    IF NEW.IdFlower IS NOT NULL THEN
        SELECT EXISTS(SELECT 1 FROM Flowers WHERE Id = NEW.IdFlower) INTO v_flower_exists;
        IF NOT v_flower_exists THEN
            RAISE EXCEPTION 'Цветок с ID % не существует', NEW.IdFlower;
        END IF;
    END IF;
    
    -- Вставляем запись в GoodsCheck
    INSERT INTO GoodsCheck (IdCheck, IdAnotherGoods, IdFlower, Price)
    VALUES (NEW.IdCheck, NEW.IdAnotherGoods, NEW.IdFlower, NEW.Price);
    
    -- Обновляем сумму в чеке
    UPDATE Account 
    SET Summ = Summ + NEW.Price,
        SummAll = SummAll + NEW.Price * (1 - ProcentDiscount / 100)
    WHERE Id = NEW.IdCheck;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер INSTEAD OF INSERT на представление
CREATE TRIGGER instead_of_insert_check_detail
    INSTEAD OF INSERT ON CheckDetails
    FOR EACH ROW
    EXECUTE FUNCTION insert_check_detail();
--

-- Функция для синхронизации состава букета при изменении названия
CREATE OR REPLACE FUNCTION sync_bouquet_structure()
RETURNS TRIGGER AS $$
DECLARE
    v_flowers_count INTEGER;
    v_flowers_list TEXT;
BEGIN
    -- Получаем список цветов в букете
    SELECT COUNT(*), STRING_AGG(f.Name, ', ')
    INTO v_flowers_count, v_flowers_list
    FROM FlowersAndBouquet fb
    JOIN Flowers f ON fb.IdFlower = f.Id
    WHERE fb.IdBouquet = NEW.Id;
    
    -- Обновляем количество и состав букета
    IF v_flowers_count > 0 THEN
        UPDATE Bouquet 
        SET Quantity = v_flowers_count,
            Structure = v_flowers_list
        WHERE Id = NEW.Id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер AFTER UPDATE на таблицу FlowersAndBouquet
CREATE TRIGGER after_update_flowers_bouquet
    AFTER UPDATE ON FlowersAndBouquet
    FOR EACH ROW
    EXECUTE FUNCTION sync_bouquet_structure();
--


--Триггеры для операций DELETE

-- Функция для обновления букета при удалении цветка
CREATE OR REPLACE FUNCTION update_bouquet_after_flower_delete()
RETURNS TRIGGER AS $$
DECLARE
    v_bouquet_record RECORD;
BEGIN
    -- Для каждого букета, из которого удалили цветок
    FOR v_bouquet_record IN 
        SELECT DISTINCT IdBouquet 
        FROM FlowersAndBouquet 
        WHERE IdBouquet IN (
            SELECT IdBouquet FROM FlowersAndBouquet WHERE IdFlower = OLD.Id
        )
    LOOP
        -- Обновляем состав букета
        PERFORM sync_bouquet_structure() 
        FROM Bouquet WHERE Id = v_bouquet_record.IdBouquet;
    END LOOP;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Триггер AFTER DELETE на таблицу Flowers
CREATE TRIGGER after_delete_flower
    AFTER DELETE ON Flowers
    FOR EACH ROW
    EXECUTE FUNCTION update_bouquet_after_flower_delete();
--

-- Функция для безопасного удаления клиента
CREATE OR REPLACE FUNCTION safe_delete_client()
RETURNS TRIGGER AS $$
DECLARE
    v_active_checks INTEGER;
    v_total_spent DECIMAL;
BEGIN
    -- Проверяем наличие активных чеков у клиента
    SELECT COUNT(*) INTO v_active_checks
    FROM Account 
    WHERE IdClient = OLD.Id AND Status = 'оплачено';
    
    IF v_active_checks > 0 THEN
        -- Сохраняем историю покупок в архив (компенсирующее действие)
        INSERT INTO Account (IdClient, Status, DatePurchase, Summ, ProcentDiscount, SummAll)
        SELECT IdClient, 'архив', DatePurchase, Summ, ProcentDiscount, SummAll
        FROM Account
        WHERE IdClient = OLD.Id;
        
        -- Помечаем старые чеки как архивные
        UPDATE Account 
        SET Status = 'архив'
        WHERE IdClient = OLD.Id;
    END IF;
    
    -- Удаляем клиента
    DELETE FROM Client WHERE Id = OLD.Id;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Триггер INSTEAD OF DELETE на представление
CREATE OR REPLACE VIEW ClientView AS
SELECT * FROM Client;

CREATE TRIGGER instead_of_delete_client
    INSTEAD OF DELETE ON ClientView
    FOR EACH ROW
    EXECUTE FUNCTION safe_delete_client();
--


--AFTER UPDATE триггер для синхронизации состава букета
-- Функция для синхронизации состава букета при изменении названия
CREATE OR REPLACE FUNCTION sync_bouquet_structure()
RETURNS TRIGGER AS $$
DECLARE
    v_flowers_count INTEGER;
    v_flowers_list TEXT;
BEGIN
    -- Получаем список цветов в букете
    SELECT COUNT(*), STRING_AGG(f.Name, ', ')
    INTO v_flowers_count, v_flowers_list
    FROM FlowersAndBouquet fb
    JOIN Flowers f ON fb.IdFlower = f.Id
    WHERE fb.IdBouquet = NEW.Id;
    
    -- Обновляем количество и состав букета
    IF v_flowers_count > 0 THEN
        UPDATE Bouquet 
        SET Quantity = v_flowers_count,
            Structure = v_flowers_list
        WHERE Id = NEW.Id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер AFTER UPDATE на таблицу FlowersAndBouquet
CREATE TRIGGER after_update_flowers_bouquet
    AFTER UPDATE ON FlowersAndBouquet
    FOR EACH ROW
    EXECUTE FUNCTION sync_bouquet_structure();
--

-- Создаем представление для чеков
CREATE OR REPLACE VIEW AccountView AS
SELECT Id, IdClient, Status, DatePurchase, Summ, ProcentDiscount, SummAll
FROM Account;

-- Функция для обновления статуса чека
CREATE OR REPLACE FUNCTION update_account_status()
RETURNS TRIGGER AS $$
DECLARE
    v_exists_returns INTEGER;
BEGIN
    -- Проверяем допустимость смены статуса
    IF OLD.Status = 'возврат' AND NEW.Status != 'возврат' THEN
        RAISE EXCEPTION 'Нельзя изменить статус чека после возврата';
    END IF;
    
    -- Если меняем на "возврат", проверяем давность чека
    IF NEW.Status = 'возврат' AND OLD.Status != 'возврат' THEN
        IF OLD.DatePurchase < CURRENT_DATE - INTERVAL '14 days' THEN
            RAISE EXCEPTION 'Возврат возможен только в течение 14 дней после покупки';
        END IF;
        
        -- Уменьшаем количество покупок клиента
        UPDATE Client 
        SET NumberPurchase = NumberPurchase - 1
        WHERE Id = OLD.IdClient;
    END IF;
    
    -- Выполняем обновление
    UPDATE Account 
    SET Status = NEW.Status
    WHERE Id = OLD.Id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер INSTEAD OF UPDATE на представление
CREATE TRIGGER instead_of_update_account
    INSTEAD OF UPDATE ON AccountView
    FOR EACH ROW
    EXECUTE FUNCTION update_account_status();


	


