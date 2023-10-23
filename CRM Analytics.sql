create database crm;
use crm;
create table account (
	Account_ID varchar(20),
    Created_by_ID varchar(20),
    Created_Date date,
    Industry varchar(50)
    );
drop table leads;
create table leads (
	Lead_ID varchar(30),	
    Converted varchar(10),	
    Converted_Account_ID varchar(30),	
    Converted_Opportunity_ID varchar(30),	
    Created_Date date,	
    Industry varchar(30),
    Lead_Source varchar(30),	
    Status varchar(20),	
    Status_Simplified varchar(20),	
    Converted_Accounts int,
    Converted_Opportunities int
    );
drop table opportunity;
create table opportunity(
	Opportunity_ID varchar(30),	
    Account_ID varchar(30),	
    Close_Date date,	
    Closed varchar(10),	
    Created_Date date,	
    Fiscal_Period varchar(20),	
    Fiscal_Quarter int,	
    Fiscal_Year int,	
    Forecast_Q_Commit varchar(10),	
    Industry varchar(40),	
    Lead_Source	varchar(50),
    Opportunity_Type varchar(50),	
    Stage varchar(100),	
    Won varchar(10),	
    Amount float,	
    Expected_Amount float);
    
LOAD DATA INFILE 'C:/Program Files/MySQL/MySQL Server 8.0/Uploads/Accont.csv'
INTO TABLE account
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
select * from account;

LOAD DATA INFILE 'C:/Program Files/MySQL/MySQL Server 8.0/Uploads/Lead.csv'
INTO TABLE leads
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
select * from leads;

LOAD DATA INFILE 'C:/Program Files/MySQL/MySQL Server 8.0/Uploads/Oppertuninty Table.csv'
INTO TABLE opportunity
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
select * from opportunity;

/*
Opportunity Table KPI's
*/
select * from opportunity;
#1. Expected Ammount
select concat(round(sum(Expected_Amount)/1000000),' M') as 'Expected Amount (Millions)'  
from opportunity;

#2. Active Opportunities
select count(Opportunity_ID) as 'Active Opportunities'
from opportunity
where closed = 'FALSE';

#3. Conversion Rate
select concat(round((sum(case when Closed = 'TRUE' then 1 else 0 end)/count(Closed))*100,2),' %') as 'Conversion Rate'
from opportunity;

#4. Win Rate
select concat(round((sum(case when Won = 'TRUE' then 1 else 0 end)/count(Won))*100,2),' %') as ' Win Rate'
from opportunity;

#5. Loss
select count(Stage) as 'Loss'
from opportunity
where Stage = 'Closed Lost';

#6. Running Total Expected Vs Commit Forecast Amount over Time
select Close_Date, 
	   sum(Expected_Amount) over (order by Close_Date) as 'Running Total Expected Amount', 
	   sum(Amount) over (order by Close_Date) as 'Running Total Forecast Commit Amount'
from opportunity 
where Forecast_Q_Commit = 'TRUE';

#7. Running Total Active Vs Total Opportunities over Time
select Created_Date,
	   sum(case when Closed='FALSE' then 1 else 0 end) over (order by Created_Date) as 'Running Total Active Opportunities',
       count(Opportunity_ID) over (order by Created_Date) as 'Running Total Opportunities'
from opportunity;

#8. Closed Won Vs Total Opportunities over Time
select Created_Date,
	   sum(case when Stage = 'Closed Won' then 1 else 0 end) as 'Closed Won Opportunities',
       count(Opportunity_ID) as 'Total Opportunities'
from opportunity
group by Created_Date
order by Created_date;

#9. Closed Won vs Total Closed over Time
select Created_Date,
	   sum(case when Stage = 'Closed Won' then 1 else 0 end) as 'Closed Won Opportunities',
       sum(case when Closed='TRUE' then 1 else 0 end) as 'Total Closed'
from opportunity
group by Created_Date
order by Created_date;

#10. Expected Amount by Opportunity Type
select Opportunity_Type, round(sum(Expected_Amount),2) as 'Expected Amount'
from opportunity
group by Opportunity_Type;

#11. Opportunities by Industry
select Industry, count(Opportunity_ID) as Opportunities
from opportunity
group by Industry;

/*
Lead Table KPI's
*/
select * from leads;
select * from opportunity;
select * from account;
#1. Total Leads
select concat(round(count(Lead_ID)/1000),' K') as 'Total Leads (in thousands)'
from leads;

#2. Expected Amount from Converted Leads
select concat(round(sum(o.Expected_Amount)/1000000),' M') as 'Expected Amount from Converted ID(in millions)'
from opportunity o 
join leads l on l.Converted_Opportunity_ID = o.Opportunity_ID;

#3. Conversion Rate
select concat(round((sum(case when Converted='TRUE' then 1 else 0 end)/count(Lead_ID))*100,2),' %') as 'Conversion Rate'
from leads;

#4 . Converted Accounts
select count(Converted_Accounts) as 'Converted Accounts'
from leads
where Converted_Accounts = 1;

#5. Converted Opportunities
select count(Converted_Opportunities) as 'Converted Opportunities'
from leads
where Converted_Opportunities = '1';

#6. Leads by Source
select Lead_Source, count(Lead_ID) as 'Number of Leads'
from leads
group by Lead_Source
order by count(Lead_ID) desc;

#7. Leads by Industry
select Industry, count(Lead_ID) as 'Number of Leads'
from leads
group by Industry
order by count(Lead_ID) desc;





