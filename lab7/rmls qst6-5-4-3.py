import mysql.connector

conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="password",
    database="lab7"
)
cursor = conn.cursor()
## 3 ##

lab_name = input("enter the Labname")
cursor.execute(
    "select serialNo, M.modelName from  Laboratory L join EquipmentUnit E  join EquipmentModel M  on E.modelId = M.modelId and L.labId = E.labId  where L.labName =%s and  E.status = 'InService'  ", (lab_name,)
)
rows = cursor.fetchall()
for row in rows : 
    print(f"the serialNo is {row[0]} and the modelname is {row[1]}")


cursor.execute(
    "select * from LaboratoryStockSummary where stockLevel = 'low'"
)
## 4 ##
rows1 = cursor.fetchall()
for row in rows1 : 
    print(f"the labId is {row[0]} , the laboratory name is {row[1]}, the consId is {row[2]}, the consumable name is {row[3]}, the unit of measure is  {row[4]}, the currentt Qnatity on hand is  {row[5]}, reorder threshold is {row[6]},technicalPid is  {row[7]}, the monitoring startdate is {row[8]} and the stocklevel is {row[9]}")

## 5 ##
new_quantity = cursor.callproc('RestockLab', [lab_id , cons_id , qty, 0])
conn.commit()
print(new_quantity[3])


#6
resId = input("enter the number of reservations: ")
serialNo = input("enter the EU's serial number:  ")

connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="root",
    database="lab7"
)
cursor = connection.cursor()

try:
    cursor.execute("INSERT INTO reserves (resId, serialNo) VALUES (%s, %s)",(resId, serialNo))
    connection.commit()
    print("insertion done successfully")
except mysql.connector.Error as error:
    print('Insertion rejected by the database:', error.msg)
cursor.close()
connection.close()




