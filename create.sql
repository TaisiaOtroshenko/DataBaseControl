DROP TABLE IF EXISTS client CASCADE;
CREATE TABLE client ( 
id SERIAL PRIMARY KEY, 
name VARCHAR(50) DEFAULT NULL,
tel NUMERIC(11) DEFAULT NULL,
CONSTRAINT unique_client UNIQUE (name,tel)
); 

INSERT INTO client (name,tel)
VALUES
  ('Jin','89043823037'),
  ('Valentine','89048932734'),
  ('Bradley','89504145405'),
  ('Adena','89503821101'),
  ('Xaviera','89041465768'),
  ('Elvis','89501864431'),
  ('Travis','89504813126'),
  ('Emmanuel','89502048517'),
  ('Leonard','89504787486'),
  ('Maggy','89504975496'),
  ('Maggy','89504975492'),
  ('Maggy','89504975491'),
  ('Maggy','89504975493'),
  ('Emmanuel','89502048511'),
  ('Leonard','89504787488');


DROP TABLE IF EXISTS branch CASCADE;
CREATE TABLE branch ( 
id SERIAL PRIMARY KEY, 
name VARCHAR(50) DEFAULT NULL
); 
INSERT INTO branch (name)
VALUES
  ('Nikitina'),
  ('Baymana'),
  ('Moscowskaya');


DROP TABLE IF EXISTS hall CASCADE;
CREATE TABLE hall ( 
id SERIAL PRIMARY KEY, 
branch INTEGER REFERENCES branch(id) ON DELETE CASCADE,
name VARCHAR(50) DEFAULT NULL,
capacity INTEGER  CHECK (capacity>0)
); 
INSERT INTO hall ( branch, name, capacity)
VALUES
  (1, 'Swimming pool', 20),  
  (1, 'Gym', 40),
  (2, 'Gym', 35),
  (2, 'Dance hall', 15);


DROP TABLE IF EXISTS type_of_card CASCADE;
CREATE TABLE type_of_card (
id SERIAL PRIMARY KEY, 
name VARCHAR(30) NOT NULL,
branch INTEGER REFERENCES branch(id) ON DELETE CASCADE,
duration INTERVAL NOT NULL, 
price NUMERIC(5) NOT NULL CHECK (price>0)
);
INSERT INTO type_of_card (name,branch,duration,price)
VALUES 
('lite',1,'1 month',3000), 
('medium',1,'3 month',5000), 
('hard',1,'6 month',9000), 

('lite',2,'1 month',4000), 
('medium',2,'3 month',6000), 
('hard',2,'6 month',11000);


DROP TABLE IF EXISTS card CASCADE;
CREATE TABLE card ( 
id SERIAL PRIMARY KEY, 
type INTEGER REFERENCES type_of_card(id) ON DELETE SET NULL, 
start DATE CHECK (start<='now'::timestamp), 
fin DATE CHECK (fin>start), 
/* вычисляемое поле. есть ли смысл его хранить?*/
client INTEGER REFERENCES client(id) ON DELETE SET NULL
); 
INSERT INTO card (type,start,fin,client)
VALUES
  (1,'2023-06-04','2024-01-11',1),
  (5,'2023-06-17','2024-12-29',2),
  (5,'2023-07-18','2024-02-26',3),
  (5,'2022-07-06','2023-02-09',4),
  (2,'2022-07-29','2023-12-24',5),
  (2,'2021-07-19','2024-12-15',6),
  (1,'2021-08-03','2024-09-20',7),
  (1,'2023-03-21','2024-06-23',8),
  (2,'2023-01-11','2024-08-24',9),
  (5,'2022-05-28','2023-02-17',10),
  (4,'2022-05-28','2023-02-17',11),
  (5,'2022-05-28','2023-02-17',12),
  (5,'2022-05-28','2023-02-13',13);

/*DROP TYPE IF EXISTS wday;
CREATE TYPE wday AS ENUM ( 'mo', 'tu', 'we', 'th', 'fr', 'sa', 'su');*/
DROP TABLE IF EXISTS program CASCADE;
CREATE TABLE program (
id SERIAL PRIMARY KEY,
name VARCHAR(30) DEFAULT NULL,
description VARCHAR(50) DEFAULT NULL,

hall INTEGER REFERENCES hall(id) ON DELETE CASCADE,
duration INTERVAL NOT NULL, 

begin TIME NOT NULL,
day_week NUMERIC(1) CHECK ((day_week>=1) AND (day_week<=7)),
trainer INTEGER REFERENCES trainer(id) DEFAULT NULL
);
/*
--day VARCHAR(2) CHECK (day IN ('su', 'mo', 'tu', 'we', 'th', 'fr', 'sa')), 
day_week wday,
day_week NUMERIC(1) CHECK day_week BETWEEN 1 AND 7,*/

INSERT INTO program (hall,duration,day_week,begin,trainer)
VALUES
  (2,'45 min',1,'17:30',3),
  (1,'60 min',1,'18:00',2),
  (2,'60 min',2,'19:30',2),
  (3,'60 min',1,'13:00',2),
  (4,'60 min',4,'13:00',3),
  (4,'45 min',2,'12:45',3),
  (2,'45 min',4,'10:50',2),
  (2,'60 min',6,'14:15',5),
  (1,'45 min',6,'19:15',4),
  (3,'90 min',2,'17:45',4),
  (3,'45 min',6,'15:35',4),
  (2,'60 min',5,'17:35',2),
  (3,'60 min',4,'10:55',3),
  (3,'45 min',5,'8:30',5);


DROP TABLE IF EXISTS trainer CASCADE;
CREATE TABLE trainer (
id SERIAL PRIMARY KEY, 
name VARCHAR(50) NOT NULL,
kind VARCHAR(30) NOT NULL,
tel NUMERIC(11) DEFAULT NULL
);
INSERT INTO trainer (name,kind,tel)
VALUES
  ('Madaline Frye','aerobics','89045238046'),
  ('Kathleen Humphrey','crossfit','89503857826'),
  ('Grace Bauer','crossfit','89505514656'),
  ('Gil Washington','pilates','89502442201'),
  ('Cain Whitney','aerobics','89047974242');


DROP TABLE IF EXISTS reservation CASCADE;
CREATE TABLE reservation ( 
program INTEGER REFERENCES program(id) ON DELETE CASCADE,
card INTEGER REFERENCES card(id) ON DELETE CASCADE, 
day DATE NOT NULL,

PRIMARY KEY (card, program)
); 
INSERT INTO reservation (program,card,day)
VALUES
  (1,1,'2023-10-16'),
  (1,2,'2023-10-16'),
  (2,1,'2023-10-16'),
  (2,3,'2023-10-16'),
  (2,8,'2023-10-16'),
  (2,9,'2023-10-16'),
  (3,1,'2023-10-17'),
  (3,2,'2023-10-17'),
  (3,3,'2023-10-17');

