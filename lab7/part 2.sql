-- view 1
create view UpcomingApprovedReservationsByLab as
select laboratory.labId, laboratory.name as labName, plannedStart, count(distinct reservation.resId) as approved_res
from laboratory, reserves, reservation, equipmentUnit
where reservation.status = "approved"
	and reserves.resId = reservation.resId
    and reserves.serialNo = equipmentUnit.serialNo
    and laboratory.labId = equipmentUnit.labId
    and plannedStart <= date_add(now(), interval 14 day)
group by laboratory.labId, laboratory.name, plannedStart;

-- view 2
create view EquipmentInventoryByLab as
select laboratory.labId, laboratory.name as labName, equipmentModel.modelId, commercialName, category, count(*) as eu_num, sum(equipmentUnit.status = "InService") as inService,sum(equipmentUnit.status = "UnderMaintenance") as underMaintenance
from laboratory, equipementModel, equipmentUnit
where equipmentModel.modelId = equipmentUnit.modelId
	and equipmentUnit.labId = laboratory.labId
group by laboratory.labId, laboratory.name, equipmentModel.modelId, commercialName, category;

-- view 3 
create view PersonReservationSummary as
select person.pid, firstName, lastName, count(reservation.resId) as res_num, sum(reservation.status = "approved") as approved_res, sum(reservation.status = "pending") as pending_res, sum(reservation.status = "canceled") as canceled_res
from person
left outer join reservation on reservation.madeBypid = person.pid
group by person.pid, firstName, lastName;

-- view 4
create view ProjectReservationSummary as
select code, title, researchProject.status,
       table1.res_num, table2.approved_res, table3.nextApproved
from researchProject P
left outer join (select projectCode, count(*) as res_num from reservation group by projectCode) as table1 on T.projectCode = P.code
left outer join (select projectCode, count(*) as approved_res from reservation where status = "Approved" group by projectCode) as table2 on A.projectCode = P.code
left outer join (select projectCode, min(plannedStart) as approved_next from reservation where status = "Approved" and plannedStart >= now() group by projectCode) as table3 on N.projectCode = P.code;

-- view 5
create view LaboratoryStockSummary as
select stocks.labId, laboratory.name as labName, stocks.consId, consumable.name as consName, unitOfMeasure, quantityOnHand, reorderThreshold, stocks.technicalPid, monitoringSince, "LOW" as stockLevel
from laboratory, consumable, stocks
where stocks.labId = laboratory.labId
  and stocks.consId = consumable.consId
  and stocks.quantityOnHand <= consumable.reorderThreshold
union
select stocks.labId, laboratory.name as labName, stocks.consId, consumable.name as consName, unitOfMeasure, quantityOnHand, reorderThreshold, stocks.technicalPid, monitoringSince, "OK" as stockLevel
from laboratory, consumable, stocks
where stocks.labId = laboratory.labId
  and stocks.consId = consumable.consId
  and quantityOnHand > reorderThreshold;
  
-- executed query
select * from UpcomingApprovedReservationsByLab;


-- 1) UpcomingApprovedReservationsByLab: counts approved reservations per lab and day over the next 14 days, so managers can plan their workload.

-- 2) EquipmentInventoryByLab: shows each lab’s units per model and how many are in service or under maintenance, so users know what is really available.

-- 3) PersonReservationSummary: summarizes each person’s reservations by status, even those who have none, so administrators can follow who uses the equipment.

-- 4) ProjectReservationSummary: gives each project’s total and approved reservations and its next approved date, so leaders can follow their equipment use.

-- 5) LaboratoryStockSummary: lists each lab’s consumable stock with a LOW/OK level, so staff get a ready restocking list.




    




