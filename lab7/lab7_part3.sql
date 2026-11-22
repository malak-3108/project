
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

ALTER TABLE Employee
ADD CONSTRAINT check_position_emp
CHECK( position  IN('dean', 'faculty', 'postdoc', 'secretary', 'technician', 'lab manager'));
update Employee set position='director' where pid=7;

ALTER TABLE ResearchProject
ADD CONSTRAINT check_status_prj
CHECK (status IN( 'Active','Proposed','Cancelled','Completed') );
update ResearchProject set status='new' where code='P1';

ALTER TABLE Participates
ADD CONSTRAINT check_role
CHECK ( role IN('PI', 'Co-PI', 'Collaborator'));
INSERT INTO  Participates Values (2,'P2','sara');

ALTER TABLE EquipmentUnit
ADD CONSTRAINT check_status_unit
Check( status IN('InService', 'UnderMaintenance'));
UPDATE EquipmentUnit SET status = 'Lost' WHERE serialNo = 'U3';

ALTER TABLE Reservation 
ADD CONSTRAINT check_status_rsv
CHECK ( status IN ('Approved', 'Pending', 'Rejected', 'Completed','Cancelled'));
update REservation set status ='sara ' where resId =1;

ALTER TABLE Maintenance
ADD CONSTRAINT check_type
check (type IN ( 'Corrective','Preventive')),
ADD CONSTRAINT check_outcome 
CHECK ( outcome IN ( 'FollowUpRequired','Resolved'));
update Maintenance set type ='sara' where serialNo ='U1';
update Maintenance set outcome ='sara' where serialNo ='U1';

ALTER TABLE CalibrationRecord
ADD CONSTRAINT check_result
CHECK ( result IN('Pass','Fail','Adjusted'));
update CalibrationRecord set result ='student' where serialNo ='U3';
-- -------------------Q2
alter table Supplies
add constraint unitPrice_check
check( unitPrice>=0);
update Supplies set unitPrice = -20 where suppId=1  and consId =1 and labId=1;


alter table  Stocks
add constraint stocks_check
check (quantityOnHand>=0);
update stocks set quantityOnHand =-10 where labId =1 and consId =1;

alter table Consumes
add constraint quantity_check
check (quantityUsed>0);
update Consumes set quantityUsed =-5 where resId =1 and labId =1 and consId=1;

ALTER TABLE Budget 
ADD CONSTRAINT amount_check
CHECK( amountGranted>=0 and amountDisbursed>=0);
update Budget  set amountGranted =-1000 where budgetLine='B1';

ALTER TABLE EquipmentUnit
ADD CONSTRAINT purchaseCost_check
check (purchaseCost>=0);
update EquipmentUnit set purchaseCost =-1000 where serialNo ='U1';

ALTER TABLE Consumable
ADD CONSTRAINT reorderThreshold_check
check (reorderThreshold>=0);
 update Consumable set reorderThreshold =-10 where consId=1;



alter table Maintenance 
add constraint cost_check
check ( cost>=0);
update Maintenance set cost =-100 where serialNO='U1';

-- ------------------
-- -----------Q3
ALTER TABLE Reservation 
ADD CONSTRAINT check_temoral_rsv
check (plannedStart<plannedEnd);
update Reservation set plannedStart='2026-11-20 08:00:00' where resId=2;

ALTER TABLE Maintenance
ADD CONSTRAINT check_temoral_mnt
check (endTS>=startTS);
update Maintenance set endTS='2026-04-12 08:00:00' where serialNo='U1';
-- ---------------------
-- -----------------







 