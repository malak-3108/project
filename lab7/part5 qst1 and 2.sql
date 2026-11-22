USE lab7;

DROP FUNCTION IF EXISTS availableUnits;
CREATE FUNCTION availableUnits(mId INT)
RETURNS INT
READS SQL DATA
RETURN (
    SELECT COUNT(serialNo)
    FROM equipmentunit E
    WHERE E.modelId = mId AND E.status = 'InService'
);

DROP PROCEDURE IF EXISTS RestockLab;
DELIMITER //
CREATE PROCEDURE RestockLab(IN labId INT, IN consId INT, IN qty DECIMAL, OUT newQuantity DECIMAL)
BEGIN
    IF qty <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'the qty cannot be negative';
    ELSEIF NOT EXISTS (SELECT labId, consId FROM stocks S WHERE S.labId = labId AND S.consId = consId) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'there is no stock with those values of lab and cons';
    ELSE
        UPDATE Stocks S SET S.quantityOnHand = S.quantityOnHand + qty, S.lastRestockDate = NOW() WHERE S.labId = labId AND S.consId = consId;
        SELECT quantityOnHand INTO newQuantity FROM Stocks S WHERE S.labId = labId AND S.consId = consId;
    END IF;
END //
DELIMITER ;


SELECT M.modelId, M.commercialName, availableUnits(M.modelId) AS available_units
FROM EquipmentModel M;

CALL RestockLab(1, 1, 10, @newQ);
SELECT @newQ;

CALL RestockLab(1, 1, -5, @newQ);

CALL RestockLab(3, 2, 10, @newQ);
