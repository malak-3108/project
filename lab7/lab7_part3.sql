
-- =====================================================================
-- PART 3: Constraints
-- =====================================================================

#-- --------------------------------------------------------------------
#-- --- --------------------------------------------------------------------
#----------------Q1
ALTER TABLE Student 
ADD CONSTRAINT check_program
CHECK( program IN('BSc', 'MSc', 'PhD','BEng'));
update student set program='cs' where pid=8;
INSERT INTO Person VALUES (12,'Sara','Alami','sara.alami@um6p.ma','UM6P','2026-11-01',NULL);
INSERT INTO Student VALUES (12,'MSc');                                   

ALTER TABLE Employee
ADD CONSTRAINT check_position_emp
CHECK( position  IN('dean', 'faculty', 'postdoc', 'secretary', 'technician', 'lab manager'));
update Employee set position='director' where pid=7;
INSERT INTO Person VALUES (13,'Reda','Fassi','reda.fassi@um6p.ma','UM6P','2026-11-01',NULL);
INSERT INTO Employee VALUES (13,'0608','C-003','technician',2);         


ALTER TABLE ResearchProject
ADD CONSTRAINT check_status_prj
CHECK (status IN( 'Active','Proposed','Cancelled','Completed') );
update ResearchProject set status='new' where code='P1';
INSERT INTO ResearchProject VALUES ('P4','Quantum Sensing','2026-12-01','2027-12-01','Active');  


ALTER TABLE Participates
ADD CONSTRAINT check_role
CHECK ( role IN('PI', 'Co-PI', 'Collaborator'));
INSERT INTO  Participates Values (2,'P2','sara');
INSERT INTO Participates VALUES (3,'P3','Collaborator');                 


ALTER TABLE EquipmentUnit
ADD CONSTRAINT check_status_unit
Check( status IN('InService', 'UnderMaintenance'));
UPDATE EquipmentUnit SET status = 'Lost' WHERE serialNo = 'U3';
INSERT INTO EquipmentUnit VALUES ('U9','2026-11-01',20000.00,'UnderMaintenance',FALSE,2,1);


ALTER TABLE Reservation 
ADD CONSTRAINT check_status_rsv
CHECK ( status IN ('Approved', 'Pending', 'Rejected', 'Completed','Cancelled'));
update REservation set status ='sara ' where resId =1;
INSERT INTO Reservation VALUES
(8,'2026-11-22 10:00:00','2026-12-05 08:00:00','2026-12-06 18:00:00','Test run','Approved',2,'P1',3);

ALTER TABLE Maintenance
ADD CONSTRAINT check_type
check (type IN ( 'Corrective','Preventive')),
ADD CONSTRAINT check_outcome 
CHECK ( outcome IN ( 'FollowUpRequired','Resolved'));
update Maintenance set type ='sara' where serialNo ='U1';
update Maintenance set outcome ='sara' where serialNo ='U1';
INSERT INTO Maintenance VALUES
('U2','2026-11-10 09:00:00','2026-11-10 11:00:00','Corrective','Sensor fix',200.00,'FollowUpRequired',6);

ALTER TABLE CalibrationRecord
ADD CONSTRAINT check_result
CHECK ( result IN('Pass','Fail','Adjusted'));
update CalibrationRecord set result ='student' where serialNo ='U3';
INSERT INTO CalibrationRecord VALUES ('U1','2026-11-01','focus alignment','Fail','2027-05-01',NULL);  

-- -------------------Q2
alter table Supplies
add constraint unitPrice_check
check( unitPrice>=0);
update Supplies set unitPrice = -20 where suppId=1  and consId =1 and labId=1;
INSERT INTO Supplies VALUES (2,3,3,110.00);    

alter table  Stocks
add constraint stocks_check
check (quantityOnHand>=0);
update stocks set quantityOnHand =-10 where labId =1 and consId =1;
INSERT INTO Stocks VALUES (3,2,0.00,'2026-11-01',NULL,6,'2026-11-01');

alter table Consumes
add constraint quantity_check
check (quantityUsed>0);
update Consumes set quantityUsed =-5 where resId =1 and labId =1 and consId=1;
INSERT INTO Consumes VALUES (7,1,1,3.00); 

ALTER TABLE Budget 
ADD CONSTRAINT amount_check
CHECK( amountGranted>=0 and amountDisbursed>=0);
update Budget  set amountGranted =-1000 where budgetLine='B1';
INSERT INTO Budget VALUES ('B3',100000.00,0.00,'2026-11-01','2027-10-31',3);

ALTER TABLE EquipmentUnit
ADD CONSTRAINT purchaseCost_check
check (purchaseCost>=0);
update EquipmentUnit set purchaseCost =-1000 where serialNo ='U1';
INSERT INTO EquipmentUnit VALUES ('U10','2026-11-05',25000.00,'InService',FALSE,4,2);

ALTER TABLE Consumable
ADD CONSTRAINT reorderThreshold_check
check (reorderThreshold>=0);
update Consumable set reorderThreshold =-10 where consId=1;
INSERT INTO Consumable VALUES (4,'Ethanol','liter','Medium',0.00);


alter table Maintenance 
add constraint cost_check
check ( cost>=0);
update Maintenance set cost =-100 where serialNO='U1';
INSERT INTO Maintenance VALUES
('U7','2026-11-20 10:00:00','2026-11-20 12:00:00','Preventive','Calibration check',75.25,'Resolved',7);
-- ------------------
-- -----------Q3
ALTER TABLE Reservation 
ADD CONSTRAINT check_temoral_rsv
check (plannedStart<plannedEnd);
update Reservation set plannedStart='2026-12-20 08:00:00' where resId=2;
INSERT INTO Reservation VALUES
(9,'2026-11-22 11:00:00','2026-12-10 09:00:00','2026-12-11 17:00:00','Spectrometer calibration','Pending',9,'P2',NULL);

ALTER TABLE Maintenance
ADD CONSTRAINT check_temoral_mnt
check (endTS>=startTS);
update Maintenance set endTS='2026-04-12 08:00:00' where serialNo='U1';
INSERT INTO Maintenance VALUES
('U5','2026-11-18 09:00:00','2026-11-19 17:00:00','Corrective','Motor replacement',350.50,'Resolved',6);
-- ---------------------
-- -----------------







 