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
