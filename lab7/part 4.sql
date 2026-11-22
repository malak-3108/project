USE llab6 ;
-- Trigger 1
CREATE TRIGGER biParticipates
BEFORE INSERT ON Participates
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 
    FROM Administrative 
    WHERE pid = NEW.pid
    ) THEN
    SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = 'Admin staff can not join research projects';
  END IF;

  IF NEW.role IN ('PI','Co-PI')
     AND NOT EXISTS (SELECT 1 FROM Academic WHERE pid = NEW.pid) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PI and Co-PI must be Academic';
  END IF;

  IF NEW.role IN ('PI','Co-PI')
     AND EXISTS (SELECT 1 FROM Participates
                 WHERE projectCode = NEW.projectCode AND role = NEW.role) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Project already has this PI/Co-PI';
  END IF;
END;


CREATE TRIGGER buParticipates
BEFORE UPDATE ON Participates
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 
    FROM Administrative 
    WHERE pid = NEW.pid
    ) THEN
    SIGNAL SQLSTATE '45000' 
      SET MESSAGE_TEXT = 'Admin staff can not join research projects';
  END IF;
  IF NEW.role IN ('PI','Co-PI')
     AND NOT EXISTS (SELECT 1 FROM Academic WHERE pid = NEW.pid
     ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'PI and Co-PI must be Academic';
  END IF;

  IF NEW.role IN ('PI','Co-PI')
     AND EXISTS (SELECT 1 FROM Participates
                 WHERE projectCode = NEW.projectCode 
                   AND role = NEW.role
                   AND NOT (pid = OLD.pid AND projectCode = OLD.projectCode)
                   ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Project already has this PI/Co-PI';
  END IF;
END;


-- Trigger 2
CREATE TRIGGER biReserves
BEFORE INSERT ON Reserves
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1
    FROM Reservation
    WHERE resId = NEW.resId
      AND status = 'Approved'
  ) THEN
      IF EXISTS(
        SELECT 1
        FROM Reservation r
        JOIN Reserves rs ON r.serialNo=New.serialNo
        JOIN Reservation rt ON rt.status='approved'
        WHERE r.resId = NEW.resId
            AND rt.status = 'Approved'
            AND r.plannedStart < rt.plannedEnd
            AND r.plannedEnd > rt.plannedStart 
      ) THEN
          SIGNAL SQLSTATE '45000' 
          SET MESSAGE_TEXT = 'Equipment unit already has an overlapping approved reservation';
      END IF;
  END IF;
END;



CREATE TRIGGER buReserves
BEFORE UPDATE ON Reserves
FOR EACH ROW
BEGIN
    IF NEW.status = 'Approved' THEN
      IF EXISTS(
        SELECT 1
        FROM Reservation r
        JOIN Reserves rs ON r.serialNo=New.serialNo
        JOIN Reservation rt ON rt.status='approved'
        WHERE r.resId = NEW.resId
            AND rt.status = 'Approved'
            AND r.plannedStart < rt.plannedEnd
            AND r.plannedEnd > rt.plannedStart 
      ) THEN
          SIGNAL SQLSTATE '45000' 
          SET MESSAGE_TEXT = 'Equipment unit has an overlapping approved reservation';
      END IF;
  END IF;
END;



-- Trigger 3
CREATE TRIGGER biReserves_cert
BEFORE INSERT ON Reserves
FOR EACH ROW
BEGIN
    IF EXISTS(
        SELECT 1
        from Reservation r 
        JOIN EquipmentUnit eu ON eu.serialNo=r.serialNo
        JOIN Requires req ON req.modelId=eu.modelId
        LEFT JOIN Holds h ON h.pid=r.madeByPid
                          AND h.certCode = req.certCode
                          AND h.expirationDate >= DATE(r.plannedStart)
        WHERE r.resId=New.resId 
              AND h.certCode IS NULL 
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Reservation creator is missing a required or valid certification';
    END IF;
End;

-- Trigger 4
CREATE TRIGGER biConsumes
BEFORE INSERT ON Consumes
FOR EACH ROW
BEGIN
    IF NEW.quantityUsed IS NULL OR NEW.quantityUsed <= 0 THEN
       SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'quantityUsed must be strictly greater than 0';
    END IF;

    IF NOT EXISTS ( 
        SELECT 1
        From stocks 
        WHERE labId = NEW.labId AND consId = NEW.consId
    ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Corresponding stock entry does not exist';
    END IF;
    IF EXISTS (
        SELECT 1
        FROM Stocks
        WHERE labId = NEW.labId
          AND consId = NEW.consId
          AND quantityOnHand < NEW.quantityUsed
    ) THEN
          SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT = 'Insufficient stock: quantityUsed exceeds quantityOnHand';
    END IF;
END;
       
CREATE TRIGGER aiConsumes
AFTER INSERT ON Consumes
FOR EACH ROW
BEGIN
    UPDATE Stocks
    SET quantityOnHand = quantityOnHand - NEW.quantityUsed
    WHERE labId = NEW.labId
          AND consId = NEW.consId;
END;



-- Triggle 5
CREATE TRIGGER aiMaintenance
AFTER INSERT ON Maintenance
FOR EACH ROW
BEGIN
    UPDATE EquipmentUnit
    SET status = ’UnderMaintenance’
    WHERE serialNo = NEW.serialNo;
END;


CREATE TRIGGER auMaintenance
AFTER UPDATE ON Maintenance
FOR EACH ROW
BEGIN
    IF (OLD.outcome IS NULL OR OLD.outcome <> 'Resolved')AND NEW.outcome = 'Resolved' THEN
    UPDATE EquipmentUnit
    SET status = 'InService'
    WHERE serialNo = NEW.serialNo;
  END IF;
END;

-- Triggle 6
CREATE TRIGGER biStudent
BEFORE INSERT ON Student
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Employee
        WHERE pid = NEW.pid
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A person cannot be both a student and an employee';
    END IF;
END;
    

CREATE TRIGGER biEmployee
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Student
        WHERE pid = NEW.pid
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'A person cannot be both a student and an employee';
    END IF;
END;


CREATE TRIGGER biFaculty
BEFORE INSERT ON Faculty
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Employee emp
        JOIN Employee sup ON emp.supervisorPid = sup.pid
        WHERE emp.pid = NEW.pid
              AND sup.position = 'dean'
    ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Faculty members must report to the dean';
    END IF;
END;


CREATE TRIGGER biAdministrative
BEFORE INSERT ON Administrative
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM Employee emp
        JOIN Employee sup ON emp.supervisorPid = sup.pid
        WHERE emp.pid = NEW.pid
              AND sup.position = 'dean'
    ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Faculty members must report to the dean';
    END IF;
END;

CREATE TRIGGER buSupervisor
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
  IF (EXISTS (
                SELECT 1 
                FROM Faculty 
                WHERE pid = NEW.pid)
    OR EXISTS (
                SELECT 1 
                FROM Administrative 
                WHERE pid = NEW.pid))
     AND NOT EXISTS (
       SELECT 1
       FROM Employee sup
       WHERE sup.pid = NEW.supervisorPid
             AND sup.position = 'dean'
     ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Faculty and administrative staff must report to the dean';
  END IF;
END;



CREATE TRIGGER biDean
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.position = 'dean' AND NEW.supervisorPid IS NOT NULL THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Violation PE5: The dean cannot have a supervisor';
  END IF;
END;

CREATE TRIGGER buDean
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
  IF NEW.position = 'dean' AND NEW.supervisorPid IS NOT NULL THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Violation PE5: The dean cannot have a supervisor';
  END IF;
END;



