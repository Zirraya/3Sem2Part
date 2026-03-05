
-- ПРЕДСТАВЛЕНИЕ 1: Статистика продаж по клиентам
-- Отчет по клиентам: общая сумма покупок, средний чек, количество покупок,
-- категория клиента на основе общей суммы покупок

CREATE OR REPLACE VIEW ClientSalesStatistics AS
SELECT 
    c.Id AS ClientId,
    c.LastName || ' ' || c.Name || COALESCE(' ' || c.Otchestvo, '') AS FullName,
    c.PhoneNumber,
    c.NumberPurchase AS NumberPurchaseField,
    COUNT(a.Id) AS ActualPurchaseCount,
    COALESCE(SUM(a.Summ), 0) AS TotalSum,
    COALESCE(AVG(a.Summ), 0) AS AverageCheck,
    COALESCE(SUM(a.SummAll), 0) AS TotalSumWithDiscount,
    CASE 
        WHEN COALESCE(SUM(a.Summ), 0) > 50000 THEN 'VIP'
        WHEN COALESCE(SUM(a.Summ), 0) > 20000 THEN 'Постоянный'
        WHEN COALESCE(SUM(a.Summ), 0) > 5000 THEN 'Обычный'
        ELSE 'Новый'
    END AS ClientCategory,
    MAX(a.DatePurchase) AS LastPurchaseDate
FROM Client c
LEFT JOIN Account a ON c.Id = a.IdClient
GROUP BY c.Id, c.LastName, c.Name, c.Otchestvo, c.PhoneNumber, c.NumberPurchase
ORDER BY TotalSum DESC;
--

-- ПРЕДСТАВЛЕНИЕ 2: Детализация чеков с товарами
-- Отчет по чекам: информация о чеке, клиенте и купленных товарах
-- с указанием типа товара и цены

CREATE OR REPLACE VIEW CheckDetails AS
SELECT 
    a.Id AS CheckId,
    a.DatePurchase,
    a.Status,
    a.Summ AS TotalSum,
    a.ProcentDiscount,
    a.SummAll AS FinalSum,
    c.Id AS ClientId,
    c.LastName || ' ' || c.Name AS ClientName,
    c.PhoneNumber,
    ag.Id AS GoodsId,
    ag.Name AS GoodsName,
    tg.NameType AS GoodsType,
    gc.Price AS ItemPrice,
    CASE 
        WHEN gc.IdFlower IS NOT NULL THEN f.Species || ': ' || f.Name
        ELSE NULL
    END AS FlowerInfo
FROM Account a
JOIN Client c ON a.IdClient = c.Id
JOIN GoodsCheck gc ON a.Id = gc.IdCheck
JOIN AnotherGoods ag ON gc.IdAnotherGoods = ag.Id
LEFT JOIN Goods g ON ag.Id = g.IdAnotherGoods
LEFT JOIN TypeGoods tg ON g.IdType = tg.IdTypeGoods
LEFT JOIN Flowers f ON gc.IdFlower = f.Id
ORDER BY a.DatePurchase DESC, a.Id;
--


-- ПРЕДСТАВЛЕНИЕ 3: Анализ продаж по товарам
-- Отчет по товарам: сколько раз куплен, общая выручка,
-- средняя цена, рейтинг популярности

CREATE OR REPLACE VIEW GoodsSalesAnalysis AS
SELECT 
    ag.Id AS GoodsId,
    ag.Name AS GoodsName,
    tg.NameType AS GoodsCategory,
    COUNT(gc.IdCheck) AS SalesCount,
    COUNT(DISTINCT a.IdClient) AS UniqueCustomers,
    SUM(gc.Price) AS TotalRevenue,
    AVG(gc.Price) AS AveragePrice,
    MIN(gc.Price) AS MinPrice,
    MAX(gc.Price) AS MaxPrice,
    CASE 
        WHEN b.Id IS NOT NULL THEN 'Букет'
        ELSE 'Отдельный товар'
    END AS SalesType,
    CASE 
        WHEN COUNT(gc.IdCheck) >= 10 THEN 'Высокий спрос'
        WHEN COUNT(gc.IdCheck) >= 5 THEN 'Средний спрос'
        WHEN COUNT(gc.IdCheck) >= 1 THEN 'Низкий спрос'
        ELSE 'Нет продаж'
    END AS Popularity,
    RANK() OVER (ORDER BY COUNT(gc.IdCheck) DESC) AS PopularityRank
FROM AnotherGoods ag
LEFT JOIN Goods g ON ag.Id = g.IdAnotherGoods
LEFT JOIN TypeGoods tg ON g.IdType = tg.IdTypeGoods
LEFT JOIN GoodsCheck gc ON ag.Id = gc.IdAnotherGoods
LEFT JOIN Account a ON gc.IdCheck = a.Id
LEFT JOIN Bouquet b ON g.IdBouquet = b.Id
GROUP BY ag.Id, ag.Name, tg.NameType, b.Id
ORDER BY SalesCount DESC, TotalRevenue DESC;
--

