/*установка даты окончания действия при добавлении карты*/
CREATE OR REPLACE FUNCTION set_finale()
RETURNS TRIGGER AS
$$
BEGIN
    UPDATE card SET fin = card.start+ (SELECT type_of_card.duration FROM type_of_card 
    WHERE card.type = type_of_card.id)::interval;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS finale ON card;
CREATE TRIGGER finale 
AFTER INSERT ON card 
FOR EACH ROW
EXECUTE PROCEDURE set_finale();


/*проверка свободных мест на занятии*/
CREATE OR REPLACE FUNCTION is_available()
RETURNS TRIGGER AS
$$
BEGIN
    IF 
        (
        SELECT count(id) FROM reservation
        WHERE ((reservation.day=NEW.day) AND (reservation.program = NEW.day))
        )
        <= 
        (
        SELECT capacity FROM hall WHERE hall.id = (SELECT hall FROM program WHERE program.id = NEW.program)
        )
        THEN RETURN NEW;
    ELSE
        RAISE EXCEPTION 'В зале нет свободных мест. Невозможно записаться на занятие';
    END IF;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS reserve ON reservation;
CREATE TRIGGER reserve
BEFORE INSERT ON reservation
/*лоол. а если я сюда суну FOR EACH ROW 
оно каждую строку в таблице будет проверять 
или каждую строку в массиве INSERT'овских кортежей?*/
/*загуглила. второй вариант правильный*/
FOR EACH ROW
EXECUTE PROCEDURE is_available();


/*преверка отсутсвия пересечений с расписанием*/
CREATE OR REPLACE FUNCTION is_covered()
RETURNS TRIGGER AS
$$
DECLARE 
    covered BOOLEAN = 0;

    i RECORD;
    /*RECORD или program%rowtype*/
    
BEGIN
    FOR i IN 
        SELECT * FROM program 
        WHERE program.day_week = NEW.day_week AND program.hall = NEW.hall
    LOOP

    covered = covered OR (i.begin+i.duration < new.begin);
    /*
        covered = covered OR
        NOT(i.begin+i.duration < new.begin)
        OR
        NOT(new.begin+new.duration > i.begin)
        ;
        */
    END LOOP;

    IF (covered)        
        THEN RETURN NEW;
    ELSE
        RAISE EXCEPTION 'В это время зал занят'; 
        /*если дойдет до RAISE выполнение остановится?*/
    END IF;
END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS plan ON program;
CREATE TRIGGER plan
BEFORE INSERT ON program
FOR EACH ROW
EXECUTE PROCEDURE is_covered();



/*тестим*/
SELECT * FROM program;

INSERT INTO program (hall,duration,day_week,begin,trainer)
VALUES
  (2,'45 min',1,'17:00',3),
  (1,'60 min',1,'19:05',2);




/* кажется, я слишком усложнила
/*заготовленное условие*/
PREPARE in_that_wday_in_that_hall (INTEGER, INTEGER) AS
SELECT id, begin, duration FROM program 
WHERE program.day_week = $1
AND program.hall = $2;

CREATE OR REPLACE FUNCTION is_covered()
RETURNS TRIGGER AS
$$
/*подготовка списка занятости зала*/
DROP TABLE IF EXISTS program_wday_hall;
CREATE TEMP TABLE IF NOT EXISTS program_wday_hall AS 
EXECUTE in_that_wday_in_that_hall (NEW.day_week, NEW.hall);

    DECLARE covered BOOLEAN = 0;
    i program_wday_hall%rowtype;
    
    BEGIN
    FOR i IN program_wday_hall
    /*::interval*/
        covered = covered OR
        (new.begin < i.begin AND new.begin+new.duration < i.begin)
        OR
        (new.begin > i.begin+i.duration AND new.begin+new.duration > i.begin+i.duration)
        ;

    IF (covered)        
        THEN RETURN NEW;
    ELSE
        RAISE EXCEPTION 'В это время зал занят'; 
        /*если дойдет до RAISE выполнение остановится?*/
    END IF;
    END;
$$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS plan ON program;
CREATE TRIGGER plan
BEFORE INSERT ON program
FOR EACH ROW
EXECUTE PROCEDURE is_covered();

*/












/*

START TRANSACTION;
DELETE FROM card 
WHERE id = 7;
COMMIT;
SELECT * FROM card;

START TRANSACTION;
UPDATE card
SET start = '2022-10-11';
SELECT * FROM card;
ROLLBACK;
SELECT * FROM card;

/* Сохранение */
START TRANSACTION;
SAVEPOINT SP1;

INSERT INTO trainer (name,kind,tel)
VALUES
  ('Madaline Frye','aerobics','89045238046');
SELECT * FROM trainer;

ROLLBACK TO SP1;
SELECT * FROM trainer;
*/






