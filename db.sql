
-- Create the database
CREATE DATABASE IF NOT EXISTS dairyman;
USE dairyman;
CREATE TABLE farmers(
    farmer_id INT AUTO_INCREMENT PRIMARY KEY,
    fullname          VARCHAR(100) NOT NULL,
    phone               VARCHAR(255),
    email                VARCHAR (100) UNIQUE,
    password              VARCHAR (255) NOT NULL,
    county                  VARCHAR(100),
    farm _location          VARCHAR(255),
    farm_name               VARCHAR(100),
    registration_date      DATE NOT NULL DEFAULT CURRENT_DATE
);

-- ======================
-- 1. Animal Table
-- ======================
CREATE TABLE Animal (
    animal_tag        VARCHAR(20) PRIMARY KEY,
    name              VARCHAR(100) NOT NULL,
    dob               DATE NOT NULL,
    purchase_date     DATE NULL,
    breed             VARCHAR(100),
    gender            ENUM('Male','Female') NOT NULL,
    source            ENUM('Birth','Purchase') NOT NULL,
    status            ENUM('Alive','Dead','Sold') NOT NULL DEFAULT 'Alive'
);

-- ======================
-- 2. MilkProduction Table
-- ======================
CREATE TABLE MilkProduction (
    production_id     INT AUTO_INCREMENT PRIMARY KEY,
    animal_id         VARCHAR(20) NOT NULL,
    production_date   DATE NOT NULL,
    production_time   TIME NOT NULL,
    quantity          DECIMAL(8,2) NOT NULL,
    quality           VARCHAR(50) NULL,
    unit              VARCHAR(20) DEFAULT 'Liters',
    FOREIGN KEY (animal_id) REFERENCES Animal(animal_tag)
        ON DELETE CASCADE
);

-- ======================
-- 3. Sales Table
-- ======================
CREATE TABLE Sales (
    sale_id           INT AUTO_INCREMENT PRIMARY KEY,
    sale_date         DATE NOT NULL,
    sale_type         ENUM('Milk','Mursik','Animal','Other') NOT NULL DEFAULT 'Milk',
    item_description  VARCHAR(255) NULL,
    price_per_unit    DECIMAL(10,2) NOT NULL,
    quantity          DECIMAL(10,2) NOT NULL,
    unit              VARCHAR(20) NOT NULL,
    total_price       DECIMAL(12,2) GENERATED ALWAYS AS (price_per_unit * quantity) STORED
);

-- ======================
-- 4. Medication Table
-- ======================
CREATE TABLE Medication (
    medication_id     INT AUTO_INCREMENT PRIMARY KEY,
    animal_id        VARCHAR(20) NOT NULL,
    medication_name   VARCHAR(100) NOT NULL,
    dose              VARCHAR(100),
    start_date        DATE NOT NULL,
    end_date          DATE NULL,
    veterinary_name   VARCHAR(100),
    veterinary_remarks VARCHAR(255),
    notes             TEXT,
    FOREIGN KEY (animal_id) REFERENCES Animal(animal_tag)
        ON DELETE CASCADE
);

-- ======================
-- 5. Vaccination Table
-- ======================
CREATE TABLE Vaccination (
    vaccination_id    INT AUTO_INCREMENT PRIMARY KEY,
    animal_id         VARCHAR(20) NOT NULL,
    vaccine_name      VARCHAR(100) NOT NULL,
    date_administered DATE NOT NULL,
    next_due_date     DATE NULL,
    notes             TEXT,
    FOREIGN KEY (animal_id) REFERENCES Animal(animal_tag)
        ON DELETE CASCADE
);

-- ======================
-- 6. Expenses Table
-- ======================
CREATE TABLE Expenses (
    expense_id        INT AUTO_INCREMENT PRIMARY KEY,
    expense_date      DATE NOT NULL,
    expense_type      ENUM('Feeds','Vaccination','Medication','Maintenance','Labor','Insemination','Other') NOT NULL,
    description       VARCHAR(255),
    amount            DECIMAL(12,2) NOT NULL
);

-- ======================
-- 7. Losses Table
-- ======================
CREATE TABLE Losses (
    loss_id           INT AUTO_INCREMENT PRIMARY KEY,
    animal_id         VARCHAR(20) NOT NULL,
    loss_type         ENUM('Death','Accident','Theft') NOT NULL,
    date              DATE NOT NULL,
    notes             TEXT,
    FOREIGN KEY (animal_id) REFERENCES Animal(animal_tag)
        ON DELETE CASCADE
);

-- ======================
-- 8. FeedConsumption Table
-- ======================
CREATE TABLE FeedConsumption (
    id_feed           INT AUTO_INCREMENT PRIMARY KEY,
    animalfed         VARCHAR(20) NOT NULL,
    quantity          DECIMAL(8,2) NOT NULL,
    type              VARCHAR(50) NOT NULL,
    cost              DECIMAL(10,2) NOT NULL,
    date              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (animalfed) REFERENCES Animal(animal_tag)
        ON DELETE CASCADE
);


-- ====================== seeding data ======================


-- ======================
-- 1. Animal Table (15 Records)
-- ======================
INSERT INTO Animal (animal_tag, name, dob, purchase_date, breed, gender, source, status) VALUES
('A001','Kamau','2020-03-15','2020-06-01','Friesian','Male','Purchase','Alive'),
('A002','Pendo','2019-08-22',NULL,'Ayrshire','Female','Birth','Alive'),
('A003','Kadogo','2021-01-10','2021-03-05','Guernsey','Female','Purchase','Alive'),
('A004','Joy','2018-05-17',NULL,'Friesian','Male','Birth','Alive'),
('A005','Lelmet','2020-09-12','2020-12-01','Jersey','Female','Purchase','Alive'),
('A006','Mwangi','2017-11-03',NULL,'Zebu','Male','Birth','Alive'),
('A007','Nyambura','2019-02-14','2019-06-01','Sahiwal','Female','Purchase','Alive'),
('A008','Lelkina','2021-07-25','2021-09-15','Friesian','Male','Purchase','Alive'),
('A009','Daisy','2019-12-30',NULL,'Ayrshire','Female','Birth','Alive'),
('A010','Otieno','2018-04-11','2018-07-20','Jersey','Male','Purchase','Alive'),
('A011','Achieng','2020-06-05',NULL,'Guernsey','Female','Birth','Alive'),
('A012','Baraka','2021-02-19','2021-04-22','Sahiwal','Male','Purchase','Alive'),
('A013','Wairimu','2019-09-01',NULL,'Friesian','Female','Birth','Alive'),
('A014','Cherono','2020-01-25','2020-04-15','Jersey','Female','Purchase','Alive'),
('A015','Mutiso','2018-10-10','2019-01-05','Zebu','Male','Purchase','Alive');

-- ======================
-- 2. MilkProduction (15 Records)
-- ======================
INSERT INTO MilkProduction (animal_id, production_date, production_time, quantity, quality, unit) VALUES
('A002','2023-08-01','06:00:00',12.5,'High','Liters'),
('A003','2023-08-01','06:30:00',10.2,'Medium','Liters'),
('A005','2023-08-01','07:00:00',8.7,'High','Liters'),
('A007','2023-08-01','07:15:00',9.5,'High','Liters'),
('A009','2023-08-01','07:30:00',11.3,'High','Liters'),
('A011','2023-08-01','07:45:00',10.0,'Medium','Liters'),
('A013','2023-08-01','08:00:00',12.0,'High','Liters'),
('A014','2023-08-01','08:15:00',9.8,'High','Liters'),
('A002','2023-08-02','06:00:00',12.7,'High','Liters'),
('A003','2023-08-02','06:30:00',10.0,'Medium','Liters'),
('A005','2023-08-02','07:00:00',8.5,'High','Liters'),
('A007','2023-08-02','07:15:00',9.3,'High','Liters'),
('A009','2023-08-02','07:30:00',11.0,'High','Liters'),
('A011','2023-08-02','07:45:00',9.8,'Medium','Liters'),
('A013','2023-08-02','08:00:00',12.2,'High','Liters');

-- ======================
-- 3. Sales (15 Records)
-- ======================
INSERT INTO Sales (sale_date, sale_type, item_description, price_per_unit, quantity, unit) VALUES
('2023-08-05','Milk','Fresh milk sold to local market',50.00,20,'Liters'),
('2023-08-06','Milk','Milk supplied to school',45.00,50,'Liters'),
('2023-08-07','Milk','Fresh milk to hotel',55.00,30,'Liters'),
('2023-08-08','Mursik','Traditional mursik to shop',100.00,10,'Liters'),
('2023-08-09','Milk','Milk to neighbors',50.00,15,'Liters'),
('2023-08-10','Animal','Sale of bull calf A015',25000.00,1,'Animal'),
('2023-08-11','Milk','Milk sold to cooperative',48.00,60,'Liters'),
('2023-08-12','Other','Cow dung sold as manure',200.00,5,'Bags'),
('2023-08-13','Milk','Milk sold at market',50.00,25,'Liters'),
('2023-08-14','Milk','Fresh milk to hotel',55.00,40,'Liters'),
('2023-08-15','Mursik','Mursik to friends',90.00,8,'Liters'),
('2023-08-16','Milk','Milk to local shop',50.00,18,'Liters'),
('2023-08-17','Animal','Sale of heifer A005',45000.00,1,'Animal'),
('2023-08-18','Milk','Milk supplied to milk bar',52.00,35,'Liters'),
('2023-08-19','Other','Sale of hides after slaughter',1500.00,1,'Hide');

-- ======================
-- 4. Medication (15 Records)
-- ======================
INSERT INTO Medication (animal_id, medication_name, dose, start_date, end_date, veterinary_name, veterinary_remarks, notes) VALUES
('A002','Antibiotics','10ml','2023-07-01','2023-07-05','Dr. Kiptoo','Responding well','For mastitis'),
('A003','Dewormer','15ml','2023-06-15',NULL,'Dr. Wambui','Normal','Routine deworming'),
('A005','Vitamin Supplement','20ml','2023-07-10','2023-07-12','Dr. Mwangi','Good recovery','Weakness observed'),
('A007','Painkiller','5ml','2023-07-20','2023-07-21','Dr. Otieno','Improved','Leg injury'),
('A009','Antibiotics','12ml','2023-06-05','2023-06-10','Dr. Cherono','Recovered','Respiratory infection'),
('A011','Calcium Boost','25ml','2023-08-01','2023-08-03','Dr. Mutua','Effective','Post-calving'),
('A013','Dewormer','15ml','2023-07-22',NULL,'Dr. Wekesa','Routine','Quarterly schedule'),
('A014','Antibiotics','10ml','2023-05-01','2023-05-06','Dr. Kibet','Recovered','Wound treatment'),
('A002','Painkiller','5ml','2023-06-01','2023-06-02','Dr. Omondi','Stable','Minor injury'),
('A003','Vitamin Supplement','20ml','2023-08-05','2023-08-07','Dr. Achieng','Improved','Boost strength'),
('A005','Calcium Boost','25ml','2023-07-25','2023-07-26','Dr. Mwangi','OK','Milk fever'),
('A007','Dewormer','15ml','2023-08-10',NULL,'Dr. Kiprono','Normal','Routine deworming'),
('A009','Painkiller','5ml','2023-08-12','2023-08-13','Dr. Nyambura','Improved','Hoof injury'),
('A011','Antibiotics','10ml','2023-07-14','2023-07-18','Dr. Kiprotich','Recovered','Mastitis'),
('A013','Vitamin Supplement','20ml','2023-06-22','2023-06-24','Dr. Wambua','Good','Nutritional boost');

-- ======================
-- 5. Vaccination (15 Records)
-- ======================
INSERT INTO Vaccination (animal_id, vaccine_name, date_administered, next_due_date, notes) VALUES
('A002','FMD','2023-01-10','2024-01-10','Routine vaccination'),
('A003','Lumpy Skin','2023-02-15','2024-02-15','Annual dose'),
('A005','CBPP','2023-03-05','2024-03-05','Protective vaccine'),
('A007','Anthrax','2023-04-20','2024-04-20','Annual requirement'),
('A009','Black Quarter','2023-05-18','2024-05-18','Routine dose'),
('A011','FMD','2023-01-12','2024-01-12','Routine vaccination'),
('A013','CBPP','2023-03-10','2024-03-10','Annual booster'),
('A014','Lumpy Skin','2023-02-25','2024-02-25','Good response'),
('A002','Anthrax','2022-12-01','2023-12-01','Previous schedule'),
('A003','FMD','2023-01-20','2024-01-20','Routine'),
('A005','Black Quarter','2023-06-15','2024-06-15','Normal'),
('A007','CBPP','2023-07-12','2024-07-12','Annual dose'),
('A009','FMD','2023-01-18','2024-01-18','Routine'),
('A011','Lumpy Skin','2023-02-22','2024-02-22','Good'),
('A013','Anthrax','2023-03-30','2024-03-30','Routine');

-- ======================
-- 6. Expenses (15 Records)
-- ======================
INSERT INTO Expenses (expense_date, expense_type, description, amount) VALUES
('2023-08-01','Feeds','Napier grass purchase',5000.00),
('2023-08-02','Vaccination','FMD vaccine costs',2000.00),
('2023-08-03','Medication','Antibiotics for A002',1500.00),
('2023-08-04','Maintenance','Repair of cowshed',8000.00),
('2023-08-05','Labor','Farm worker wages',12000.00),
('2023-08-06','Feeds','Dairy meal bags',7000.00),
('2023-08-07','Insemination','AI service for A013',2500.00),
('2023-08-08','Other','Transport costs',3000.00),
('2023-08-09','Feeds','Hay bales',6000.00),
('2023-08-10','Vaccination','Anthrax vaccine',2200.00),
('2023-08-11','Medication','Painkillers for A007',1800.00),
('2023-08-12','Labor','Casual workers',4000.00),
('2023-08-13','Feeds','Molasses supplement',3500.00),
('2023-08-14','Maintenance','Fence repair',5000.00),
('2023-08-15','Other','Fuel for transport',2500.00);

-- ======================
-- 7. Losses (15 Records)
-- ======================

INSERT INTO Losses (animal_id, loss_type, date, notes) VALUES
('A004','Death','2022-05-10','Died due to pneumonia'),
('A006','Theft','2021-11-15','Stolen from grazing field'),
('A010','Accident','2020-08-12','Broke leg, had to be put down'),
('A012','Death','2022-03-08','Died due to severe infection'),
('A015','Theft','2021-06-22','Calf stolen during night'),
('A004','Accident','2021-01-18','Minor accident, later recovered'),
('A006','Death','2023-04-14','Old age'),
('A010','Theft','2019-12-11','Lost during market day'),
('A012','Accident','2020-07-20','Hit by vehicle on road'),
('A015','Death','2022-11-03','Sudden illness'),
('A004','Theft','2020-09-05','Went missing in pasture'),
('A006','Accident','2022-06-13','Injured by horn clash'),
('A010','Death','2023-02-24','Severe bloating'),
('A012','Theft','2021-05-09','Stolen at night'),
('A015','Accident','2023-07-01','Fell into ditch');

-- ======================
-- 8. FeedConsumption (15 Records)
-- ======================
INSERT INTO FeedConsumption (animalfed, quantity, type, cost, date) VALUES
('A002',15.0,'Napier Grass',750.00,'2023-08-01'),
('A003',10.0,'Dairy Meal',1200.00,'2023-08-01'),
('A005',12.0,'Hay',600.00,'2023-08-01'),
('A007',14.0,'Napier Grass',700.00,'2023-08-01'),
('A009',11.0,'Silage',900.00,'2023-08-01'),
('A011',13.0,'Dairy Meal',1500.00,'2023-08-01'),
('A013',12.5,'Hay',650.00,'2023-08-01'),
('A014',10.5,'Napier Grass',525.00,'2023-08-01'),
('A002',16.0,'Molasses',800.00,'2023-08-02'),
('A003',9.5,'Silage',820.00,'2023-08-02'),
('A005',11.0,'Napier Grass',550.00,'2023-08-02'),
('A007',13.0,'Dairy Meal',1400.00,'2023-08-02'),
('A009',12.5,'Hay',700.00,'2023-08-02'),
('A011',14.0,'Napier Grass',700.00,'2023-08-02'),
('A013',10.0,'Molasses',500.00,'2023-08-02');
