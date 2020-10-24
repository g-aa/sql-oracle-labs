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
values ('F', 25000, 40000);
commit;