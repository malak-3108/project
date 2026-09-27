
create database lab2 ; 

use lab2 ; 

create table person (
	pid int ,
    firstName varchar(20),
    lastName varchar(20),
    email varchar(30),
    affiliation varchar(30),
    startDate date ,
    endDate date ,
    primary key(pid)
);

create table student (
	student_id int, 
	program  varchar(20),
    primary key(student_id),
    foreign key (student_id) references person(pid)
);

create table employee (
	employee_id int , 
    phone int , 
    office varchar(20),
    supervisor_id int , 
    primary key(employee_id) , 
    foreign key(employee_id) references person(pid), 
    foreign key (supervisor_id) references employee(employee_id)
); 

create table academic (
	academic_id int , 
    position varchar(20),
    primary key(academic_id) , 
    foreign key(academic_id) references employee(employee_id)
);
 
create table faculty (
	faculty_id int , 
    position varchar(20),
    primary key(faculty_id) , 
    foreign key(faculty_id) references academic(academic_id)
); 

create table non_academic (
	non_academic_id int , 
    position varchar(20),
    primary key(non_academic_id) , 
    foreign key(non_academic_id) references employee(employee_id)
); 

create table technical (
	technical_id int , 
    position varchar(20),
    primary key(technical_id) , 
    foreign key(technical_id) references non_academic(non_academic_id)
); 

create table administrative (
	administrative_id int , 
    position varchar(20),
    primary key(administrative_id) , 
    foreign key(administrative_id) references non_academic(non_academic_id)
); 

create table advises (
	student_id int,
    academic_id int not null  , 
    primary key (student_id ,academic_id ), 
    foreign key (student_id) references student(student_id), 
    foreign key (academic_id) references academic(academic_id)
);

create table laboratory(
	labid int , 
    name_lab varchar(20),
    building varchar(20),
    roomNumber int , 
    discipline varchar(20),
    faculty_supervisor_id int not null ,
    primary key(labid) ,
    foreign key (faculty_supervisor_id) references faculty(faculty_id) on delete no action
);

create table attached (
	labid int ,
    person_id int not null , 
    primary key(labid, person_id) ,
    foreign key (labid) references laboratory(labid),
    foreign key (person_id) references person(pid)
);

create table researchProject (
	code_rp int , 
    title varchar(20),
    startDate date , 
    endDate date , 
    Statuss varchar(20),
    primary key(code_rp)
);

create table participates_person_rp (
	code_rp int , 
    person_id int  not null ,
    rolee varchar(20),
    primary key (code_rp , person_id),
    foreign key(code_rp) references researchProject(code_rp),
    foreign key (person_id) references person(pid)
);

create table budget (
	budgetline  int , 
    amountGranted decimal ,
    amountDisbursed decimal , 
    startDate date , 
    endDate date , 
    manager_budget_id int  not null ,
    primary key(budgetline), 
    foreign key (manager_budget_id) references academic(academic_id) on delete no action
);

create table fundsPrj (
	code_rp int , 
    budgetline int  not null ,
    primary key(code_rp, budgetline ),
    foreign key(code_rp) references researchProject(code_rp),
    foreign key(budgetline) references budget(budgetline)
);

create table fundslab (
	labid int   , 
    budgetline int not null, 
    primary key (labid , budgetline ),
    foreign key (labid) references laboratory(labid),
    foreign key (budgetline) references budget(budgetline)
);

create table equipment_model (
	modelid int,
    commercial_name varchar(30),
    manufacturer varchar(30),
    category varchar(30),
    requiredEnvironment varchar(30),
    trainingMandatory varchar(30),
    primary key (modelid)
);

create table equipment_unit (
	serialno int,
    belonged_modelid int not null,
    labid_position int not null,
    acquisitiondate date,
    purchaseCost int,
    statuss varchar(40),
    portable varchar(10),
    primary key (serialno),
    foreign key (belonged_modelid) references equipment_model(modelid) on delete no action,
    foreign key (labid_position) references laboratory(labid) on delete no action
);

create table certification (
	codee int,
    title varchar(50),
    issiuingauthority varchar(50),
    validityPeriod varchar(50),
    safetylavel varchar(30),
    primary key (codee)
);

create table requires (
	codee int,
    modelid int,
    primary key (codee,modelid),
    foreign key (codee) references certification(codee),
    foreign key (modelid) references equipment_model(modelid)
);

create table holds (
	codee int,
    pid int,
    expirationdate date,
    issuedate date,
    grade int,
    primary key (codee,pid),
    foreign key (codee) references certification(codee),
    foreign key (pid) references person(pid)
);

create table reservation (
	maker_pid int not null,
    approver_pid int,
    code_rp int not null,
	resid int,
    submissionTS timestamp,
    plannedstart time,
    plannedend time,
    purpose varchar(30),
    statuss varchar(30),
    primary key (resid),
    foreign key(maker_pid) references person(pid) on delete no action,
    foreign key(approver_pid) references person(pid) on delete no action,
    foreign key (code_rp) references researchProject(code_rp) on delete no action
);

create table reserves (
	resid int,
    serialno int not null,
    primary key (resid, serialno),
    foreign key (resid) references reservation(resid),
    foreign key (serialno) references equipment_unit(serialno)
);

create table maintenance (
	maintained_serialno int not null,
    doneby_technical_id int not null,
	startTS timestamp,
    endTS timestamp,
    typee varchar(20),
    descriptionn varchar(30),
    cost decimal,
    outcome varchar(30),
    primary key (maintained_serialno, startTS),
    foreign key (maintained_serialno) references equipment_unit(serialno) ON DELETE CASCADE,
    foreign key (doneby_technical_id) references technical(technical_id) on delete no action
    
);

create table calibration (
	calib_serialno int not null,
    calibdate date,
    calibrationtype varchar(30),
    result varchar(20),
    nextduedate date,
    remarks varchar(50),
    primary key (calib_serialno,calibdate),
    foreign key (calib_serialno) references equipment_unit(serialno) ON DELETE CASCADE
);

create table consumable (
	consid int,
    namee varchar(30),
    unitofmeasure varchar(10),
    hazardlevel varchar(10),
    reorderthreshold varchar(10),
    primary key (consid)
);

create table stocks (
	monitoredby_technical_id int not null,
	consid int,
    labid int,
    qualityonhand int,
    lastrestockdate date,
    storagecondition varchar(30),
    monitoringsince date,
    primary key (consid, labid),
    foreign key (consid) references consumable(consid),
    foreign key (labid) references laboratory(labid),
    foreign key (monitoredby_technical_id) references technical(technical_id) on delete no action
);

create table consumes (
	resid int,
    consid int,
    labid int,
    quantityused int,
    primary key (resid,consid,labid),
    foreign key (consid,labid) references stocks(consid,labid),
    foreign key (resid) references reservation(resid)
);

create table supplier (
	suppid int,
    namee varchar(30),
    contactemail varchar(30),
    phone int,
    primary key (suppid)
);

create table supplies (
	suppid int,
    consid int,
    labid int,
    unitprice decimal,
    primary key (suppid, consid, labid),
    foreign key (consid) references consumable(consid),
    foreign key (suppid) references supplier(suppid),
    foreign key (labid) references laboratory(labid)
);












	







		