-- Food Waste Management System (MySQL Version)

DROP DATABASE IF EXISTS food_waste_db;
CREATE DATABASE food_waste_db;
USE food_waste_db;

CREATE TABLE DONOR (
    DonorID INT PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Phone VARCHAR(15) UNIQUE,
    Address VARCHAR(100),
    Type VARCHAR(20)
);

CREATE TABLE NGO (
    NGOID INT PRIMARY KEY,
    Name VARCHAR(50),
    Location VARCHAR(100),
    Contact VARCHAR(15)
);

CREATE TABLE VOLUNTEER (
    VolunteerID INT PRIMARY KEY,
    Name VARCHAR(50),
    Phone VARCHAR(15),
    Area VARCHAR(50)
);

CREATE TABLE DONATION (
    DonationID INT PRIMARY KEY,
    DonorID INT,
    Date DATE,
    Status VARCHAR(20),
    FOREIGN KEY (DonorID) REFERENCES DONOR(DonorID)
);

CREATE TABLE FOOD_ITEM (
    FoodID INT PRIMARY KEY,
    Name VARCHAR(50),
    Quantity INT,
    ExpiryTime DATETIME,
    DonationID INT,
    FOREIGN KEY (DonationID) REFERENCES DONATION(DonationID)
);

CREATE TABLE PICKUP (
    PickupID INT PRIMARY KEY,
    DonationID INT,
    VolunteerID INT,
    PickupTime DATETIME,
    Status VARCHAR(20),
    FOREIGN KEY (DonationID) REFERENCES DONATION(DonationID),
    FOREIGN KEY (VolunteerID) REFERENCES VOLUNTEER(VolunteerID)
);

-- ─────────────────────────────────────────────
-- DONOR (5 rows)
-- ─────────────────────────────────────────────
INSERT INTO DONOR VALUES (1, 'Gagan Sharma',   '9876543210', 'Amritsar, Punjab',  'Individual');
INSERT INTO DONOR VALUES (2, 'Priya Mehta',    '9812345678', 'Ludhiana, Punjab',  'Individual');
INSERT INTO DONOR VALUES (3, 'Ravi Gupta',     '9123456780', 'Chandigarh',        'Restaurant');
INSERT INTO DONOR VALUES (4, 'Anand Bakery',   '9765432100', 'Patiala, Punjab',   'Business');
INSERT INTO DONOR VALUES (5, 'Harpreet Singh', '9732109876', 'Mohali, Punjab',    'Business');

-- ─────────────────────────────────────────────
-- NGO (4 rows)
-- ─────────────────────────────────────────────
INSERT INTO NGO VALUES (1, 'Helping Hands',    'Chandigarh',       '9998887770');
INSERT INTO NGO VALUES (2, 'Roti Bank Punjab', 'Amritsar, Punjab', '9111222333');
INSERT INTO NGO VALUES (3, 'Annapoorna Trust', 'Delhi',            '9222333444');
INSERT INTO NGO VALUES (4, 'Seva Bharati',     'Ludhiana, Punjab', '9333444555');

-- ─────────────────────────────────────────────
-- VOLUNTEER (5 rows)
-- ─────────────────────────────────────────────
INSERT INTO VOLUNTEER VALUES (1, 'Rahul Sharma', '8887776665', 'Chandigarh');
INSERT INTO VOLUNTEER VALUES (2, 'Simran Kaur',  '8776665554', 'Amritsar');
INSERT INTO VOLUNTEER VALUES (3, 'Arjun Patel',  '8665554443', 'Ludhiana');
INSERT INTO VOLUNTEER VALUES (4, 'Meena Devi',   '8554443332', 'Patiala');
INSERT INTO VOLUNTEER VALUES (5, 'Pooja Bhatia', '8332221110', 'Mohali');

-- ─────────────────────────────────────────────
-- DONATION (5 rows)
-- ─────────────────────────────────────────────
INSERT INTO DONATION VALUES (1, 1, '2025-04-01', 'Completed');
INSERT INTO DONATION VALUES (2, 2, '2025-04-03', 'Completed');
INSERT INTO DONATION VALUES (3, 3, '2025-04-05', 'Pending');
INSERT INTO DONATION VALUES (4, 4, '2025-04-10', 'Pending');
INSERT INTO DONATION VALUES (5, 5, '2025-04-18', 'Completed');

-- ─────────────────────────────────────────────
-- FOOD_ITEM (5 rows)
-- ─────────────────────────────────────────────
INSERT INTO FOOD_ITEM VALUES (1, 'Rice',         50,  '2025-04-02 12:00:00', 1);
INSERT INTO FOOD_ITEM VALUES (2, 'Roti',         100, '2025-04-03 20:00:00', 2);
INSERT INTO FOOD_ITEM VALUES (3, 'Biryani',      40,  '2025-04-06 14:00:00', 3);
INSERT INTO FOOD_ITEM VALUES (4, 'Bread Loaves', 60,  '2025-04-11 08:00:00', 4);
INSERT INTO FOOD_ITEM VALUES (5, 'Poha',         45,  '2025-04-19 07:30:00', 5);

-- ─────────────────────────────────────────────
-- PICKUP (5 rows)
-- ─────────────────────────────────────────────
INSERT INTO PICKUP VALUES (1, 1, 1, '2025-04-01 10:00:00', 'Delivered');
INSERT INTO PICKUP VALUES (2, 2, 2, '2025-04-03 11:30:00', 'Delivered');
INSERT INTO PICKUP VALUES (3, 3, 3, '2025-04-05 13:00:00', 'Pending');
INSERT INTO PICKUP VALUES (4, 4, 4, '2025-04-10 14:00:00', 'Pending');
INSERT INTO PICKUP VALUES (5, 5, 5, '2025-04-18 10:15:00', 'Delivered');

-- ─────────────────────────────────────────────
-- VIEW
-- ─────────────────────────────────────────────
CREATE VIEW ACTIVE_DONORS AS
SELECT DISTINCT D.Name
FROM DONOR D
JOIN DONATION DN ON D.DonorID = DN.DonorID;

-- ─────────────────────────────────────────────
-- TRIGGER
-- ─────────────────────────────────────────────
DELIMITER $$
CREATE TRIGGER update_donation_status
AFTER UPDATE ON PICKUP
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Delivered' THEN
        UPDATE DONATION
        SET Status = 'Completed'
        WHERE DonationID = NEW.DonationID;
    END IF;
END$$
DELIMITER ;

-- ─────────────────────────────────────────────
-- STORED PROCEDURE
-- ─────────────────────────────────────────────
DELIMITER $$
CREATE PROCEDURE Add_Donor(
    IN d_id INT,
    IN d_name VARCHAR(50),
    IN d_phone VARCHAR(15),
    IN d_address VARCHAR(100),
    IN d_type VARCHAR(20)
)
BEGIN
    INSERT INTO DONOR (DonorID, Name, Phone, Address, Type)
    VALUES (d_id, d_name, d_phone, d_address, d_type);
END$$
DELIMITER ;

-- ─────────────────────────────────────────────
-- FUNCTION
-- ─────────────────────────────────────────────
DELIMITER $$
CREATE FUNCTION Total_Food()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT IFNULL(SUM(Quantity),0) INTO total FROM FOOD_ITEM;
    RETURN total;
END$$
DELIMITER ;

-- ─────────────────────────────────────────────
-- SAMPLE QUERIES
-- ─────────────────────────────────────────────

-- 1. All donors
SELECT * FROM DONOR;

-- 2. All donations with donor names
SELECT DN.DonationID, D.Name AS Donor, DN.Date, DN.Status
FROM DONATION DN JOIN DONOR D ON DN.DonorID = D.DonorID;

-- 3. Food items with donation status
SELECT FI.Name AS FoodItem, FI.Quantity, FI.ExpiryTime, DN.Status
FROM FOOD_ITEM FI JOIN DONATION DN ON FI.DonationID = DN.DonationID;

-- 4. Active donors (via view)
SELECT * FROM ACTIVE_DONORS;

-- 5. Total food quantity (via function)
SELECT Total_Food() AS TotalFoodUnits;

-- 6. Pickup details with volunteer names
SELECT P.PickupID, V.Name AS Volunteer, P.PickupTime, P.Status
FROM PICKUP P JOIN VOLUNTEER V ON P.VolunteerID = V.VolunteerID;

-- 7. Test trigger: mark pickup as Delivered → donation auto-completes
UPDATE PICKUP SET Status = 'Delivered' WHERE PickupID = 3;
SELECT * FROM DONATION WHERE DonationID = 3;

-- 8. Test stored procedure: add a new donor
CALL Add_Donor(6, 'Manpreet Gill', '9600001111', 'Bathinda, Punjab', 'Individual');
SELECT * FROM DONOR WHERE DonorID = 6;
