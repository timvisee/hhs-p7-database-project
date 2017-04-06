CREATE TABLE Opzegreden(
    opzegreden CHAR(3) NOT NULL,
    omschrijving VARCHAR(40) NOT NULL,
    PRIMARY KEY(opzegreden)
);

CREATE TABLE Titel(
    titel_cd VARCHAR(4) NOT NULL,
    titel VARCHAR(40)  NOT NULL,
    soort CHAR(1),
    PRIMARY KEY(titel_cd)
);

CREATE TABLE Locatie(
    locatie INT NOT NULL,
    naam VARCHAR(50) NOT NULL,
    strt VARCHAR(40) NOT NULL,
    hnr INT NOT NULL,
    av VARCHAR(15),
    pc CHAR(6) NOT NULL,
    PRIMARY KEY(locatie),
);

CREATE TABLE Medewerker(
    medw_nr INT NOT NULL,
    naam VARCHAR(30) NOT NULL,
    achternaam VARCHAR(40) NOT NULL,
    woonplaats VARCHAR(40) NOT NULL,
    email VARCHAR(50) NOT NULL,
    PRIMARY KEY(medw_nr)
);

CREATE TABLE Product(
    prod_nr INT NOT NULL,
    naam CHAR(70) NOT NULL,
    brand VARCHAR(4) NOT NULL,
    prijs DECIMAL(4,2) NOT NULL,
    PRIMARY KEY(prod_nr),
    FOREIGN KEY(brand) REFERENCES Titel(titel_cd)
);

CREATE TABLE Klant(
    klant_id INT NOT NULL,
    voorl VARCHAR(2),
    tv VARCHAR(10),
    anaam VARCHAR(40) NOT NULL,
    strt VARCHAR(40) NOT NULL,
    hnr INT NOT NULL,
    av VARCHAR(15),
    pc CHAR(6) NOT NULL,
    gebdt DATE NOT NULL,
    gesl CHAR(1),
    PRIMARY KEY(klant_id),
);

CREATE TABLE Orders(
    order_nr INT NOT NULL,
    klant_id INT NOT NULL,
    datum DATE NOT NULL,
    kanaal CHAR(1) NOT NULL,
    betaalwijze CHAR(1) NOT NULL,
    leveringsorder INT UNIQUE,
    PRIMARY KEY(order_nr),
    FOREIGN KEY(klant_id) REFERENCES Klant(klant_id),
    FOREIGN KEY(leveringsorder) REFERENCES Orders(order_nr)
);

CREATE TABLE Activiteit(
    activ_id INT NOT NULL,
    activ_srt VARCHAR(10) NOT NULL,
    activ_nm VARCHAR(40) NOT NULL,
    titel_cd VARCHAR(4) NOT NULL,
    PRIMARY KEY(activ_id),
    FOREIGN KEY(titel_cd) REFERENCES Titel(titel_cd)
);

CREATE TABLE Evenementen(
    prod_nr INT NOT NULL,
    activ_id INT NOT NULL,
    locatie INT NOT NULL,
    begin_dt DATE NOT NULL,
    eind_dt DATE NOT NULL,
    prijs_abo DECIMAL(4,2) NOT NULL,
    organisator INT NOT NULL,
    PRIMARY KEY(prod_nr),
    FOREIGN KEY(prod_nr) REFERENCES Product(prod_nr),
    FOREIGN KEY(activ_id) REFERENCES Activiteit(activ_id),
    FOREIGN KEY(locatie) REFERENCES Locatie(locatie)
);

CREATE TABLE Aankoop(
    aankoop_nr INT NOT NULL,
    order_nr INT NOT NULL,
    prod_nr INT NOT NULL,
    aantal INT NOT NULL,
    bedrag DECIMAL(4,2) NOT NULL,
    PRIMARY KEY(aankoop_nr),
    FOREIGN KEY(order_nr) REFERENCES Orders(order_nr),
    FOREIGN KEY(prod_nr) REFERENCES Evenementen(prod_nr)
);


CREATE TABLE Abon(
    abmnt INT NOT NULL,
    titel_cd VARCHAR(4) NOT NULL,
    begin_dt DATE NOT NULL,
    eind_dt DATE,
    lezer INT NOT NULL,
    opzegreden CHAR(3),
    betaler INT,
    betaalwijze CHAR(1),
    hulpverlener INT NOT NULL,
    PRIMARY KEY(abmnt),
    FOREIGN KEY(titel_cd) REFERENCES Titel(titel_cd),
    FOREIGN KEY(lezer) REFERENCES Klant(klant_id),
    FOREIGN KEY(opzegreden) REFERENCES Opzegreden(opzegreden),
    FOREIGN KEY(betaler) REFERENCES Klant(klant_id),
    FOREIGN KEY(hulpverlener) REFERENCES Medewerker(medw_nr)
);

CREATE TABLE Premielevering(
    abmnt INT NOT NULL,
    ontvanger INT NOT NULL,
    prod_nr INT NOT NULL,
    lever_dt DATE NOT NULL,
    PRIMARY KEY(abmnt, ontvanger, prod_nr),
    FOREIGN KEY(abmnt) REFERENCES Abon(abmnt),
    FOREIGN KEY(ontvanger) REFERENCES Klant(klant_id),
    FOREIGN KEY(prod_nr) REFERENCES Product(prod_nr)
);
CREATE TABLE Webhistorie(
    titel_cd VARCHAR(4) NOT NULL,
    klant_id INT NOT NULL,
    jaar INT NOT NULL,
    maand INT NOT NULL,
    n_bezoek INT NOT NULL,
    n_post INT NOT NULL,
    n_koop INT NOT NULL,
    n_retour INT NOT NULL,
    b_koop DECIMAL(5,2) NOT NULL,
    b_retour DECIMAL(5,2) NOT NULL,
    PRIMARY KEY(titel_cd, klant_id, jaar, maand),
    FOREIGN KEY(titel_cd) REFERENCES Titel(titel_cd),
    FOREIGN KEY(klant_id) REFERENCES Klant(klant_id)
);
CREATE TABLE Event_Medewerker(
    prod_nr INT NOT NULL,
    medw_nr INT NOT NULL,
    PRIMARY KEY(prod_nr, medw_nr),
    FOREIGN KEY(prod_nr) REFERENCES Evenementen(prod_nr),
    FOREIGN KEY(medw_nr) REFERENCES Medewerker(medw_nr)
);

CREATE TABLE functies(
    functie_nr INT NOT NULL,
    naam VARCHAR(40) NOT NULL,
    salaris DECIMAL(6,2) NOT NULL,
    cursus INT NOT NULL,
    PRIMARY KEY(functie_nr),
    FOREIGN KEY(cursus) REFERENCES Activiteit(Activ_id )
);

CREATE TABLE gesprek(
    manager INT NOT NULL,
    medewerker INT NOT NULL,
    datum DATE NOT NULL,
    soort_gesprek CHAR(1) NOT NULL,
    PRIMARY KEY(manager, medewerker, datum, soort_gesprek),
    FOREIGN KEY(manager) REFERENCES Medewerker(medw_nr),
    FOREIGN KEY(medewerker) REFERENCES Medewerker(medw_nr)
);

CREATE TABLE Klant_Event(
    prod_nr INT NOT NULL,
    klant_id INT NOT NULL,
    PRIMARY KEY(prod_nr, klant_id),
    FOREIGN KEY(prod_nr) REFERENCES Evenementen(prod_nr),
    FOREIGN KEY(klant_id) REFERENCES Klant(klant_id)
);




-- TRIGGERT 1
CREATE TRIGGER dbo.before_locCheck_insert
ON dbo.Evenementen
FOR INSERT
AS

DECLARE @locatie INT;
DECLARE @begin_dt DATE;

SELECT @locatie = i.locatie FROM inserted i;
SELECT @begin_dt = i.begin_dt FROM inserted i;

IF @locatie NOT IN (
    SELECT locatie FROM Evenementen WHERE locatie = @locatie AND begin_dt = @begin_dt
)
BEGIN

RAISERROR ('Dit kan dus niet', 16, 1);
ROLLBACK TRANSACTION;
RETURN 
END;


--TRIGGERT 2 + procedure

CREATE TRIGGER before_klantEvent_insert
ON dbo.Klant_Event 
FOR INSERT
AS

DECLARE @customer INT;
DECLARE @product INT;

SELECT @customer = i.klant_id FROM inserted i;
SELECT @product = i.prod_nr FROM inserted i;

BEGIN
    Execute check_matching_dates @customer, @product
END;


CREATE PROCEDURE check_matching_dates @klant_id INT = NULL, @prod_nr INT = NULL
AS
BEGIN
    DECLARE @existingDate DATE;
    DECLARE @newDate DATE;
    
SELECT @existingDate = E.begin_dt
FROM Klant_Event KE
INNER JOIN Event E
ON KE.prod_nr = E.prod_nr
INNER JOIN Activiteit A
ON E.activ_id = A.activ_id
WHERE a.activ_srt = "WORKSHOP"
AND KE.klant_id = @klant_id;

SELECT @newDate = E.begin_dt 
FROM Klant_Event KE
INNER JOIN Event E
ON KE.prod_nr = E.prod_nr
INNER JOIN Activiteit A
ON E.activ_id = A.activ_id
WHERE a.activ_srt = "WORKSHOP"
AND E.prod_nr = @prod_nr
AND KE.klant_id = @klant_id;

IF @existingDate = @newDate
BEGIN
    RAISERROR ('Dit kan dus niet', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN
END;
END;


-- TRIGGERT 3

CREATE TRIGGER before_event_insert
ON Evenementen
FOR INSERT
AS

DECLARE @begin_dt DATE;

SELECT @begin_dt = i.begin_dt FROM inserted i;

BEGIN
    DECLARE @eventType VARCHAR(10);
    DECLARE @end_dt DATE;

    SELECT @eventType = A.activ_srt, @end_dt = E.eind_dt
    FROM Evenementen E
    INNER JOIN Activiteit A
    ON E.activ_id = A.activ_id;
    
    IF @begin_dt <> @end_dt AND @eventType = 'WORKSHOP'
    BEGIN
        RAISERROR ('Workshop mag niet langer dan 1 dag duren!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN
    END;
END;

-- TRIGGERT 4
CREATE TRIGGER before_email_insert ON Medewerker
FOR INSERT
AS

DECLARE @surname VARCHAR(30);
DECLARE @lastname VARCHAR(40);

SELECT @surname = i.naam, @lastname = i.achternaam FROM inserted i;

BEGIN
    INSERT INTO Medewerker(email) VALUES ( CONCAT(SUBSTRING(@surname, 0, 1) ,@lastname, '@ntu.nl'))
END;

-- CONSTRAINT 5

ALTER TABLE Orders
ADD UNIQUE (leveringsorder);

-- CONSTRAINT 6
ALTER TABLE Orders
ADD CONSTRAINT retourorder_check CHECK ((betaalwijze IS NULL AND leveringsorder IS NOT NULL AND kanaal = 'R') OR (betaalwijze IS NOT NULL AND kanaal <> 'R' AND leveringsorder IS NOT NULL));


-- CONSTRAINT 7
CREATE TRIGGER check_retour_date_order
ON Orders
FOR INSERT
AS

DECLARE @newDate DATE;
DECLARE @newOrder INT;

SELECT @newDate = i.datum, @newOrder = i.leveringsorder FROM inserted i;

BEGIN

DECLARE @orddate DATE;

SELECT @orddate = datum
FROM Orders
WHERE Orders.order_nr = @newOrder;

IF DATEDIFF(day, @orddate, @newDate) > 21
    BEGIN
        RAISERROR ('INSERT NOT ALLOWED, PERIOD BETWEEN ORDERS IS MORE THAN 21 DAYS', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN
    END;

END;


-- CONSTRAINT 8
ALTER TABLE Orders
ADD CONSTRAINT order_betaalwijze_notnull CHECK ((betaalwijze IS NULL AND kanaal = 'R') OR kanaal <> 'R');


-- CONSTRAINT 9
CREATE TRIGGER Check_purchase_retourorder
ON  Orders
FOR INSERT
AS

DECLARE @newOrder INT;

SELECT @newOrder = i.order_nr FROM inserted i;

BEGIN
IF @newOrder NOT IN (SELECT order_nr FROM Aankoop WHERE order_nr = @newOrder)
BEGIN
    RAISERROR ('Geen aankoop voor deze retourorder!', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN
END;
END;



-- CONSTRAINT 10
CREATE TRIGGER before_checkProductExists_insert
ON Orders
FOR INSERT
AS

DECLARE @newOrder INT;
DECLARE @newLevOrd INT;

SELECT @newOrder = order_nr, @newLevOrd = i.leveringsorder FROM inserted i;

BEGIN
    IF @newLevOrd <> NULL
    BEGIN
    Execute check_product_retour @newOrder, @newLevOrd;
    END;
END;

CREATE PROCEDURE check_product_retour @newOrder INT = NULL, @newLevOrd INT = NULL
AS
BEGIN
    DECLARE @productRetour INT;
    DECLARE @productOrig INT;

SELECT @productRetour = A.prod_nr FROM Orders O
INNER JOIN Aankoop A
ON O.order_nr = A.order_nr
WHERE O.order_nr = @newOrder;

SELECT @productOrig = A.prod_nr FROM Orders O
INNER JOIN Aankoop A
ON O.order_nr = A.order_nr
WHERE O.order_nr = @newLevOrd;

IF @productRetour <> @productOrig
BEGIN
    RAISERROR ('Product van aankoop komt niet overeen met product retour!', 16, 1);
    ROLLBACK TRANSACTION;
    RETURN
END;
END;
-- CONSTRAINT 11

CREATE TRIGGER before_checkproduct_insert
ON Orders
FOR INSERT
AS

DECLARE @newLevOrd INT;

SELECT @newLevOrd = i.leveringsorder FROM inserted i;

BEGIN   
    IF @newLevOrd <> NULL
    BEGIN
        EXECUTE check_if_event @newLevOrd;
    END;
    
END;

CREATE PROCEDURE check_if_event @leveringsorder INT = NULL
AS
BEGIN
    DECLARE @product INT;

SELECT @product = A.prod_nr FROM Orders O
INNER JOIN Aankoop A
ON O.order_nr = A.order_nr
WHERE O.order_nr = @leveringsorder;

IF @product IN (SELECT prod_nr FROM Event)
    BEGIN 
        RAISERROR ('Retourorder mag geen event zijn!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN
    END;
END;


-- CONSTRAINT 12

ALTER TABLE Aankoop
ADD UNIQUE (prod_nr, order_nr);

CREATE TRIGGER bedrag_aantal_negatief
ON Aankoop
FOR INSERT
AS

DECLARE @newOrd INT;
DECLARE @newPrice DECIMAL(4,2);
DECLARE @newAmount INT;

SELECT @newOrd = i.order_nr, @newPrice = i.bedrag, @newAmount = i.aantal FROM inserted i;

BEGIN
    DECLARE @kanaal CHAR(1);
    
    SELECT @kanaal =O.kanaal FROM Aankoop A
    INNER JOIN Orders O
    ON A.order_nr = O.order_nr
    WHERE O.order_nr = @newOrd
    
    IF @newPrice > 0 OR @newAmount > 0 AND @kanaal = 'R'
    BEGIN
        RAISERROR ('Bedrag of aantal mag niet boven nul zijn bij een router order!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN
    END;
END;


-- CONSTRAINT 13

CREATE TRIGGER before_insupdel_aankoop
ON Aankoop
FOR INSERT,UPDATE,DELETE
AS

DECLARE @newProd INT;

SELECT @newProd = i.prod_nr FROM inserted i;

BEGIN
    DECLARE @aantVerkocht INT;
    DECLARE @aantRetour INT;

SELECT @aantVerkocht = COUNT(A.prod_nr)
FROM Aankoop A
INNER JOIN Orders O
ON A.order_nr = O.order_nr
WHERE O.kanaal <> 'R' AND A.prod_nr = @newProd;

SELECT @aantRetour = COUNT(A.prod_nr)
FROM Aankoop A
INNER JOIN Orders O
ON A.order_nr = O.order_nr
WHERE O.kanaal = 'R' AND A.prod_nr = @newProd;

IF @aantRetour < 0 OR @aantRetour > @aantVerkocht
    BEGIN
        RAISERROR ('Aantal retourorders mag niet kleiner zijn dan nul en ook niet groter dan het aantal verkochte items!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN
    END;
END;


-- CONSTRAINT 14
CREATE TRIGGER before_instert_aankoop_retour_prijs
ON Aankoop
FOR INSERT
AS

DECLARE @newOrd INT;
DECLARE @newAankoop INT;

SELECT @newOrd = i.order_nr, @newAankoop = i.aankoop_nr FROM inserted i;

BEGIN
    DECLARE @checkRetour CHAR(1);
    SELECT O.kanaal
    FROM Aankoop A
    INNER JOIN Orders O
    ON A.order_nr = O.order_nr
    WHERE A.order_nr = @newOrd;    
    IF @checkRetour = 'R'
    BEGIN
        DECLARE @amountRetour INT;
        DECLARE @priceRetour DECIMAL(5,2);
        
        SELECT @amountRetour = aantal, @priceRetour = bedrag
        FROM Aankoop
        WHERE aankoop_nr = @newAankoop;    
    
        DECLARE @amountOriginal INT;
        DECLARE @priceOriginal DECIMAL(5,2);

        SELECT @amountOriginal = A.aantal, @priceOriginal = A.bedrag
        FROM Aankoop A
        INNER JOIN Orders O
        ON A.order_nr = O.order_nr
        WHERE A.order_nr = O.leveringsorder;        
        IF (@priceOriginal * (@amountRetour / @amountOriginal) * -1 <> @priceRetour)
        BEGIN
            RAISERROR ('Het bedrag van de retour order klopt niet!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN
        END;
    END;
END;
-- CONSTRAIN 15
CREATE TRIGGER before_insert_aankoop_aantal_retour
ON Aankoop
FOR INSERT
AS

DECLARE @newOrd INT;
DECLARE @newAmount INT;
DECLARE @newPrice DECIMAL(5,2);

SELECT @newOrd = i.order_nr FROM inserted i;

BEGIN
    DECLARE @oldNRetour INT;
    DECLARE @oldBRetour DECIMAL(5,2);
    DECLARE @customer INT;
    DECLARE @month INT;
    DECLARE @year INT;

    SELECT @customer = klant_id, @month = DATEPART(yyyy,datum), @year = DATEPART(mm,datum)
    FROM Orders
    WHERE kanaal = 'R' AND leveringsorder = @newOrd;
    
    SELECT @oldNRetour = n_retour, @oldBRetour = b_retour
    FROM Webhistorie
    WHERE klant_id = @customer AND maand = @month AND jaar = @year;
    
    UPDATE Webhistorie
    SET n_retour = (@oldNRetour + @newAmount), b_retour = (@oldBRetour + @newPrice)
    WHERE klant_id = @customer AND maand = @month AND jaar = @year;
END;



