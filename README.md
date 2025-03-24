# Restoring-ActiveDirectory

- Restore-AD.ps1 script

1. This script checks for the existence of an Active Directory Organizational Unit (OU) named “Finance.” Outputs a message to the console that indicates if the OU exists or if it does not. If it already exists, deletes it and outputs a message to the console that it was deleted.

2.  Creates an OU named “Finance.” Outputs a message to the console that it was created.

3.  Imports the financePersonnel.csv file (found in the attached directory) into the Active Directory domain and directly into the finance OU.

![Restore-AD screenshot](https://github.com/user-attachments/assets/d23a9ed3-a4b4-4a48-9526-72ced85b13f1)


- Restore-SQL.ps1 script
  
1. Checks for the existence of a database named ClientDB. Outputs a message to the console that indicates if the database exists or if it does not. If it already exists, deletes it and outputs a message to the console that it was deleted.

2.  Creates a new database named “ClientDB” on the Microsoft SQL server instance. Outputs a message to the console that the database was created.

3.  Creates a new table and name it “Client_A_Contacts” in the new database. Outputs a message to the console that the table was created.

4.  Inserts the data (all rows and columns) from the “NewClientData.csv” file (found in the attached folder) into the table created in part D3.
