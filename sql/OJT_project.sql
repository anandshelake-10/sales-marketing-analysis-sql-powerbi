create database NMD_Infotech_Pvt_Ltd;

use nmd_infotech_pvt_ltd;
RENAME TABLE  ADMISSIONDATABASE TO ADMISSION_DATA;
RENAME TABLE ENQUIREDATABASE TO ENQUIRY_DATA;


alter table ENQUIRY_DATA
modify STUD_ID INT PRIMARY KEY,
modify DATE_OF_ENQUIRY date,
MODIFY SERVICE VARCHAR (50),
MODIFY NAME VARCHAR (50),
MODIFY ADDRESS VARCHAR (100),
MODIFY DISTRICT VARCHAR (50),
MODIFY GENDER ENUM ("MALE", "FEMALE"),
MODIFY SOURCE varchar(50);

ALTER TABLE ADMISSION_DATA
modify STUD_ID INT ,
modify DATE_OF_ADMISSION date,
MODIFY SERVICE VARCHAR (50),
MODIFY NAME VARCHAR (50),
MODIFY ADDRESS VARCHAR (100),
MODIFY DISTRICT VARCHAR (50),
MODIFY GENDER ENUM ("MALE", "FEMALE"),
MODIFY SOURCE varchar(50),
MODIFY TOTAL_FEES DECIMAL (10,0),
MODIFY INSTALLMENT1 DECIMAL (10,0),
MODIFY INSTALLMENT2 DECIMAL (10,0),
ADD foreign key (STUD_ID) references ENQUIRY_DATA (STUD_ID);

select * from admission_data;
select * from enquiry_data;

## Total Enquiries vs Admissions
select count(*) as total_enquiries from enquiry_data; -- Total_enquiries -- 1111
select count(*) as total_admission from admission_data; -- Total_Admission -- 658

## Conversion Rate
SELECT 
  (COUNT(DISTINCT A.STUD_ID) * 100.0 / COUNT(DISTINCT E.STUD_ID)) AS Conversion_Rate
FROM Enquiry_Data E
LEFT JOIN Admission_Data A
ON E.STUD_ID = A.STUD_ID;

use nmd_infotech_pvt_ltd;

## Enquires by source
SELECT Source, COUNT(*) AS Total_Enquiries
FROM Enquiry_Data
GROUP BY Source
ORDER BY Total_Enquiries DESC;

SELECT * FROM ADMISSION_DATA;

## Admissions by Course/Service
SELECT Service, COUNT(*) AS Total_Admissions
FROM Admission_Data
GROUP BY Service
ORDER BY Total_Admissions DESC;

## Revenue by Course
SELECT Service, SUM(Total_Fees) AS Total_Revenue
FROM Admission_Data
GROUP BY Service
ORDER BY Total_Revenue DESC;

## Gender-wise Enquiries vs. Admissions
SELECT 
    e.Gender,
    COUNT(DISTINCT e.STUD_ID) AS Total_Enquiries,
    COUNT(DISTINCT a.STUD_ID) AS Total_Admissions
FROM Enquiry_Data e
LEFT JOIN Admission_Data a 
       ON e.Stud_ID = a.Stud_ID
GROUP BY e.Gender;

## District-wise Admissions
SELECT 
    District,
    COUNT(STUD_ID) AS Total_Admissions
FROM Admission_Data
GROUP BY District
ORDER BY Total_Admissions DESC;


use nmd_infotech_pvt_ltd;

select * from admission_data;

## Add "Balance" and "Payment Status" column 

-- step 1 Add Columns
ALTER TABLE Admission_Data
ADD COLUMN Balance DECIMAL(10,2),
ADD COLUMN Payment_Status VARCHAR(20);

-- step 2 Update Balance Automatically
UPDATE Admission_Data 
SET Balance = Total_Fees - (IFNULL(Installment1, 0) + IFNULL(Installment2, 0));
    
-- step 3 Update payment status
UPDATE Admission_
Data
SET Payment_Status = 
    CASE 
        WHEN Balance = 0 THEN 'Paid'
        WHEN Balance = Total_Fees THEN 'Unpaid'
        ELSE 'Partially Paid'
    END;

## Service-wise Revenue Analysis
SELECT 
    Service,
    SUM(Total_Fees) AS Total_Fees,
    SUM(Total_Fees - Balance) AS Collected_Fees,
    SUM(Balance) AS Pending_Fees
FROM Admission_Data
GROUP BY Service
ORDER BY Total_Fees DESC;


## Payment Status Summary
SELECT Payment_Status, COUNT(*) AS Students
FROM Admission_Data
GROUP BY Payment_Status;

## Source-Wise Revenue Contribution
SELECT 
    e.Source,
    COUNT(a.STUD_ID) AS Total_Admissions,
    SUM(a.Total_Fees) AS Total_Revenue,
    SUM(a.Total_Fees - a.Balance) AS Collected_Fees,
    SUM(a.Balance) AS Pending_Fees
FROM Enquiry_Data e
JOIN Admission_Data a ON e.Stud_ID = a.Stud_ID
where e.source in ("Instagram", "Google", "Youtube", "Facebook", "Other", "REF","Walkin")
GROUP BY e.Source
ORDER BY Total_Revenue DESC;

## Monthly Admissions Trend
SELECT DATE_FORMAT(Date_of_Admission, '%Y-%m') AS Month, COUNT(*) AS Total_Admissions
FROM Admission_Data
GROUP BY Month
ORDER BY Month;

use nmd_infotech_pvt_ltd;
select * from enquiry_data;



## Peak Enquiry Months
SELECT DATE_FORMAT(Date_of_Enquiry, '%Y-%m') AS Month, COUNT(*) AS Enquiries
FROM Enquiry_Data
GROUP BY Month
ORDER BY Enquiries DESC;


## Follow-up Required (Enquiries not converted)
SELECT e.Stud_ID, e.Name, e.Service, e.Source
FROM Enquiry_Data e
LEFT JOIN Admission_Data a ON e.Stud_ID = a.Stud_ID
WHERE a.Stud_ID IS NULL;
