create function availableUnits(mId int)
	returns integer
    begin
		declare n integer;
		select count(*) into n
        from equipmentUnit
		where equipmentUnit.modelId = mId and equipmentUnit.status = 'InService';
		return n;
	end
    

create procedure RestockLab (in p_labId int, in p_consId int, in p_qty int, out newQuantity int)
	begin
		update stocks set quantityOnHand = quantityOnHand + p_qty, lastRestockDate = now()
		where labId = p_labId and consId = p_consId;
		select quantityOnHand into newQuantity
		from stocks
		where labId = p_labId and consId = p_consId;
	end
    


    
