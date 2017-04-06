-- Query 1 - Test
SELECT DATEDIFF(DD, Evenementen.begin_dt, Orders.datum) AS tijd FROM Evenementen
  JOIN Product ON Evenementen.prod_nr = Product.prod_nr
  JOIN Aankoop ON Product.prod_nr = Aankoop.prod_nr
  JOIN Orders ON Aankoop.order_nr = Orders.order_nr;

-- Query 1
SELECT AVG(DATEDIFF(DD, Evenementen.begin_dt, Orders.datum)) AS avg_tijd FROM Evenementen
  JOIN Product ON Evenementen.prod_nr = Product.prod_nr
  JOIN Aankoop ON Product.prod_nr = Aankoop.prod_nr
  JOIN Orders ON Aankoop.order_nr = Orders.order_nr;



-- Query 2
-- TODO: Is the TOP usage correct in this query?
SELECT TOP(10) pc AS postcode, COUNT(pc) AS aantal
  FROM Orders
  JOIN Klant ON Orders.klant_id = Klant.klant_id
  WHERE Orders.datum > DATEADD(YEAR, -2, GETDATE())
  GROUP BY pc
  ORDER BY aantal DESC
