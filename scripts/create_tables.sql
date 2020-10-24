DROP TABLE Employees;
DROP TABLE Countries;
DROP TABLE Departments;
DROP TABLE Jobs;
DROP TABLE Job_History;
DROP TABLE Locations;
DROP TABLE Regions;
DROP TABLE job_grades;
CREATE TABLE Employees
AS SELECT * FROM HR.Employees;
--CREATE TABLE Countries
--AS SELECT * FROM HR.Countries;
CREATE TABLE Countries
AS SELECT country_id, country_name, region_id FROM HR.Countries;
CREATE TABLE Departments
AS SELECT * FROM HR.Departments;
CREATE TABLE Jobs
AS SELECT * FROM HR.Jobs;
CREATE TABLE Job_History
AS SELECT * FROM HR.Job_History;
CREATE TABLE Locations
AS SELECT * FROM HR.Locations;
CREATE TABLE Regions
AS SELECT * FROM HR.Regions;
--CREATE TABLE job_grades
--AS SELECT * FROM HR.job_grades;
create table job_grades
( grade_level varchar2(3),
  lowest_sal number,
  highest_sal number
);

insert into job_grades(grade_level, lowest_sal, highest_sal)
values ('A', 1000, 2999);
insert into job_grades(grade_level, lowest_sal, highest_sal)
values ('B', 3000, 5999);
insert into job_grades(grade_level, lowest_sal, highest_sal)
values ('C', 6000, 9999);
insert into job_grades(grade_level, lowest_sal, highest_sal)
values ('D', 10000, 14999);
insert into job_grades(grade_level, lowest_sal, highest_sal)
values ('E', 15000, 24999);
insert into job_grades(grade_level, lowest_sal, highest_sal)
values ('F', 25000, 4000);
commit;
