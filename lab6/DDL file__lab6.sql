create DATABASE lab6 ; 
use lab6 ;

CREATE TABLE Person (
    pid INT PRIMARY KEY,
    firstName VARCHAR(100) NOT NULL,
    lastName VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE, 
    affiliation VARCHAR(150) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE
);

CREATE TABLE Student (
    pid INT PRIMARY KEY,
    program VARCHAR(20) NOT NULL,
    FOREIGN KEY (pid) REFERENCES Person(pid) ON DELETE CASCADE ON UPDATE CASCADE
		-- student is a subclass of person, so when a person will be deleted from the person table, it should be deleted from the student's table if he is there
        -- this criteria is applied on all the subclasses of person
);

CREATE TABLE Employee (
    pid INT PRIMARY KEY,
    phone VARCHAR(30) NOT NULL,
    office VARCHAR(100) NOT NULL,
    position VARCHAR(100) , 
    supervisorPid INT,
    FOREIGN KEY (pid) REFERENCES Person(pid),
    FOREIGN KEY (supervisorPid) REFERENCES Employee(pid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Academic (
    pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Employee(pid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Faculty (
    pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Academic(pid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Administrative (
    pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Employee(pid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Technical (
    pid INT PRIMARY KEY,
    FOREIGN KEY (pid) REFERENCES Employee(pid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Advises (
    academicPid INT NOT NULL,
    studentPid INT NOT NULL,

    PRIMARY KEY (academicPid, studentPid),

    FOREIGN KEY (academicPid) REFERENCES Academic(pid) ON DELETE CASCADE ON UPDATE CASCADE,

    FOREIGN KEY (studentPid) REFERENCES Student(pid) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Laboratory (
    labId INT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    building VARCHAR(100) NOT NULL,
    roomNumber VARCHAR(50) NOT NULL,
    discipline VARCHAR(150) NOT NULL,
    supervisorPid INT NOT NULL,
    FOREIGN KEY (supervisorPid) REFERENCES Faculty(pid) ON DELETE NO ACTION ON UPDATE CASCADE
        -- ON DELETE NO ACTION because a laboratory is an independent entity, any other constraint will lead to the deletion of the labId, which we don't want;
		-- Since supervisor's id is NOT NULL, the laboratory must always have a valid supervisor (a lab should be supervised by exactly one faculty);
);

CREATE TABLE Attached (
    pid INT NOT NULL,
    labId INT NOT NULL,
    PRIMARY KEY (pid, labId),
    FOREIGN KEY (pid) REFERENCES Person(pid) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (labId) REFERENCES Laboratory(labId) ON DELETE CASCADE ON UPDATE CASCADE
		-- ON DELETE CASCADE because Attached is not the first and main holder of pid and labid, so if they are deleted from person and lab table, any corresponding rows should be deleted;
);

CREATE TABLE ResearchProject (
    code VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    status VARCHAR(20) NOT NULL
);
CREATE TABLE Participates (
    pid INT NOT NULL,
    projectCode VARCHAR(50) NOT NULL,
    role VARCHAR(30) NOT NULL,
    PRIMARY KEY (pid, projectCode),
    FOREIGN KEY (pid) REFERENCES Person(pid) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (projectCode) REFERENCES ResearchProject(code) ON DELETE CASCADE ON UPDATE CASCADE
		-- same as attached
);

CREATE TABLE Budget (
    budgetLine VARCHAR(50) PRIMARY KEY,
    amountGranted DECIMAL(12,2) NOT NULL,
    amountDisbursed DECIMAL(12,2) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    managerPid INT NOT NULL,
    FOREIGN KEY (managerPid) REFERENCES Academic(pid) ON DELETE NO ACTION ON UPDATE CASCADE
		-- ON DELETE NO ACTION because each budget must have a manager, and so the manager in person's table can't be deleted as long as he manages a budget
);

CREATE TABLE FundsPrj (
    budgetLine VARCHAR(50) NOT NULL,
    projectCode VARCHAR(50) NOT NULL,
    PRIMARY KEY (budgetLine, projectCode),
    FOREIGN KEY (budgetLine) REFERENCES Budget(budgetLine) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (projectCode) REFERENCES ResearchProject(code) ON DELETE CASCADE ON UPDATE CASCADE
		-- deleting a budget or a project should remove the corresponding
);

CREATE TABLE FundsLab (
    budgetLine VARCHAR(50) NOT NULL,
    labId INT NOT NULL,
    PRIMARY KEY (budgetLine, labId),
    FOREIGN KEY (budgetLine) REFERENCES Budget(budgetLine) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (labId) REFERENCES Laboratory(labId) ON DELETE CASCADE ON UPDATE CASCADE
		-- same as fundsPrj
);



CREATE TABLE EquipmentModel (
    modelId INT PRIMARY KEY,
    commercialName VARCHAR(150) NOT NULL,
    manufacturer VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    requiredEnvironment VARCHAR(200) NOT NULL,
    trainingMandatory BOOLEAN NOT NULL
);

CREATE TABLE EquipmentUnit (
    serialNo VARCHAR(100) PRIMARY KEY,
    acquisitionDate DATE NOT NULL,
    purchaseCost DECIMAL(12,2) NOT NULL,
    status VARCHAR(30) NOT NULL,
    portable BOOLEAN NOT NULL,
    modelId INT NOT NULL,
    labId INT NOT NULL,
    FOREIGN KEY (modelId) REFERENCES EquipmentModel(modelId) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (labId) REFERENCES Laboratory(labId) ON DELETE NO ACTION ON UPDATE CASCADE
		-- for both these foreign keys, we can’t delete an equipment model while equipment units of that model still exist, same for labId
);

CREATE TABLE Certification (
    code VARCHAR(50) PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    issuingAuthority VARCHAR(150) NOT NULL,
    validityPeriod INT NOT NULL,
    safetyLevel VARCHAR(100) NOT NULL
);
CREATE TABLE Requires (
    modelId INT NOT NULL,
    certCode VARCHAR(50) NOT NULL,
    PRIMARY KEY (modelId, certCode),
    FOREIGN KEY (modelId) REFERENCES EquipmentModel(modelId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (certCode) REFERENCES Certification(code) ON DELETE CASCADE ON UPDATE CASCADE
		-- if we delete a model from EquipmentModel, all its rows in requires are deleted automatically, same for certCode
);
CREATE TABLE Holds (
    pid INT NOT NULL,
    certCode VARCHAR(50) NOT NULL,
    issueDate DATE NOT NULL,
    expirationDate DATE NOT NULL,
    grade VARCHAR(50),
    PRIMARY KEY (pid, certCode),
    FOREIGN KEY (pid) REFERENCES Person(pid) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (certCode) REFERENCES Certification(code) ON DELETE CASCADE ON UPDATE CASCADE
		-- same as requires
);

CREATE TABLE Reservation (
    resId INT PRIMARY KEY,
    submissionTS TIMESTAMP NOT NULL,
    plannedStart TIMESTAMP NOT NULL,
    plannedEnd TIMESTAMP NOT NULL,
    purpose VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending',
    madeByPid INT NOT NULL,
    projectCode VARCHAR(50) NOT NULL,
    approverPid INT,

    FOREIGN KEY (madeByPid) REFERENCES Person(pid) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (projectCode) REFERENCES ResearchProject(code) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (approverPid) REFERENCES Person(pid) ON DELETE SET NULL ON UPDATE CASCADE
		-- for both first foreign keys, a person can't be deleted as long as its id is the id of a maker, same for projectCode
        -- for the third foreign key, the reservation stays with its approver's id, even if it may be deleted in the person's table, in
        -- that case its node will turn into null, but the reservation itself will not be deleted
);
CREATE TABLE Reserves (
    resId INT NOT NULL,
    serialNo VARCHAR(100) NOT NULL,

    PRIMARY KEY (resId, serialNo),

    FOREIGN KEY (resId) REFERENCES Reservation(resId) ON DELETE CASCADE ON UPDATE CASCADE,
		-- if resId is deleted, then the reservation does not exist, and so nothing to reserve
    FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNo) ON DELETE NO ACTION ON UPDATE CASCADE
		-- we can’t delete an equipment unit as long as it appears in a reservation
);

CREATE TABLE Maintenance (
    serialNo VARCHAR(100) NOT NULL,
    startTS TIMESTAMP NOT NULL,
    endTS TIMESTAMP NOT NULL,
    type VARCHAR(20) NOT NULL,
    description VARCHAR(255) NOT NULL,
    cost DECIMAL(12,2) NOT NULL,
    outcome VARCHAR(30) NOT NULL,
    technicalPid INT NOT NULL,

    PRIMARY KEY (serialNo, startTS),

    FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNo) ON DELETE CASCADE ON UPDATE CASCADE,
		-- because maintenance is a weak entity that depends on equipment unit
    FOREIGN KEY (technicalPid) REFERENCES Technical(pid) ON DELETE NO ACTION ON UPDATE CASCADE
		-- a technical id can't be deleted as long as its owner has done a maintenance to an equipment unit
);
CREATE TABLE CalibrationRecord (
    serialNo VARCHAR(100) NOT NULL,
    calibDate DATE NOT NULL,
    calibrationType VARCHAR(100) NOT NULL,
    result VARCHAR(20) NOT NULL,
    nextDueDate DATE NOT NULL,
    remarks VARCHAR(255) NOT NULL,

    PRIMARY KEY (serialNo, calibDate),

    FOREIGN KEY (serialNo) REFERENCES EquipmentUnit(serialNo) ON DELETE CASCADE ON UPDATE CASCADE
		-- as as maintenance, calibration record is a weak entity 
); 

CREATE TABLE Consumable (
    consId INT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    unitOfMeasure VARCHAR(50) NOT NULL,
    hazardLevel VARCHAR(100) NOT NULL,
    reorderThreshold DECIMAL(12,2) NOT NULL
);

CREATE TABLE Supplier (
    suppId INT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    contactEmail VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL
);

CREATE TABLE Supplies (
    suppId INT NOT NULL,
    consId INT NOT NULL,
    labId INT NOT NULL,
    unitPrice DECIMAL(12,2) NOT NULL,

    PRIMARY KEY (suppId, consId, labId),

    FOREIGN KEY (suppId) REFERENCES Supplier(suppId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (consId) REFERENCES Consumable(consId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (labId) REFERENCES Laboratory(labId) ON DELETE CASCADE ON UPDATE CASCADE
		-- If any of the three is deleted, the related row is deleted too, because as long as one of them is deleted, the row will have no meaning because supplies is a ternary relationship
        -- If one supplier, or consumable or lab disappears, the relationship disappears
);
CREATE TABLE Stocks (
    labId INT NOT NULL,
    consId INT NOT NULL,
    quantityOnHand DECIMAL(12,2) NOT NULL,
    lastRestockDate DATE NOT NULL,
    storageCondition VARCHAR(150),
    technicalPid INT NOT NULL,
    monitoringSince DATE NOT NULL,

    PRIMARY KEY (labId, consId),

    FOREIGN KEY (labId) REFERENCES Laboratory(labId) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (consId) REFERENCES Consumable(consId) ON DELETE NO ACTION ON UPDATE CASCADE,
    FOREIGN KEY (technicalPid) REFERENCES Technical(pid) ON DELETE NO ACTION ON UPDATE CASCADE
		-- ON DELETE NO ACTION because the stock is defined by the laboratory and consumable it refers to and it must always reference existing entities
);
CREATE TABLE Consumes (
    resId INT NOT NULL,
    labId INT NOT NULL,
    consId INT NOT NULL,
    quantityUsed DECIMAL(12,2) NOT NULL,

    PRIMARY KEY (resId, labId, consId),

    FOREIGN KEY (resId) REFERENCES Reservation(resId) ON DELETE CASCADE ON UPDATE CASCADE,
		-- same as reserves
    FOREIGN KEY (labId, consId) REFERENCES Stocks(labId, consId) ON DELETE NO ACTION ON UPDATE CASCADE
		-- stocks can't be deleted as long as it is still used in this table
);



