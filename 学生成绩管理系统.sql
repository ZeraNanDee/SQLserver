USE MASTER  
GO 
IF db_id('SudentScore') IS NOT NULL
	DROP DATABASE  SudentScore
GO
CREATE DATABASE SudentScore


/*******************************
创建数据表
*******************************/




USE SudentScore
/*1.学生信息表*/
CREATE TABLE student
(
	studentNo VARCHAR(20) PRIMARY KEY NOT NULL,--学生学号
	studentName VARCHAR(20) NOT NULL,--学生名称
	sex CHAR(10) NOT NULL,--学生性别
	major VARCHAR(20) NOT NULL,--学生专业
	grade VARCHAR(10) NOT NULL,--学生年级
)
GO

/*2.课程信息表*/
CREATE TABLE course
(
	courseNo VARCHAR(20)  PRIMARY KEY NOT NULL ,--课程编号
	courseName VARCHAR(20) NOT NULL,--课程名称
	courseTeacher VARCHAR(30) NOT NULL,--课程教师
)
GO


/*3.学生成绩信息表*/
CREATE TABLE sutdentscore
(
	studentNo VARCHAR(20)  NOT NULL,--学生编号
	courseNo VARCHAR(20)   NOT NULL ,--课程编号
	courseName VARCHAR(20) NOT NULL,--课程名称
	score int not null--学生成绩
)
GO

/*4.教师用户表，根据此表登录后对以上表进行查改操作*/
CREATE TABLE users
(
	name VARCHAR(20) NOT NULL,
	password VARCHAR(20) NOT NULL
)
GO

alter table sutdentscore
add constraint CK_s check (score>=0 AND score<=100)--添加约束设置成绩的范围
alter table sutdentscore add constraint CK_1 foreign key(studentNo) references student(studentNo)--添加外键
alter table sutdentscore add constraint CK_2 foreign key(courseNo) references course(courseNo)--添加外键



INSERT INTO student VALUES('CST15001','胡小小','女','法学','2015级');
INSERT INTO student VALUES('CST16022','卢本伟','男','计算机科学与技术','2016级');
INSERT INTO student VALUES('CST16013','江泽民','男','政治经济学','2016级');
INSERT INTO student VALUES('CST13054','刘德华','男','音乐表演','2013级');





INSERT INTO course
VALUES('B00003','表演基础','宋涛');
INSERT INTO course
VALUES('B00006','数据库原理','韩涛');
INSERT INTO course
VALUES('B00001','马克思原理','杜海涛');
INSERT INTO course 
VALUES('B00002','法律学','李涛');

INSERT INTO sutdentscore
VALUES('CST15001','B00002','法律学',89);
INSERT INTO sutdentscore
VALUES('CST16022','B00006','数据库原理',40);
INSERT INTO sutdentscore
VALUES('CST16013','B00001','马克思原理',99);
INSERT INTO sutdentscore
VALUES('CST13054','B00003','表演基础',78);

INSERT INTO users
VALUES('DHDA111','HUANQ111D');
INSERT INTO users
VALUES('CCA2445','55521DDS');

select *from student;
select *from course;
select *from sutdentscore;

select AVG(score) as '学生总平均分'--统计学生的总平均分
from sutdentscore;

select studentNo,studentName --查找姓江的同学
from student
where studentName like '江%';

select studentName--查找不及格的同学
from student,sutdentscore
where student.studentNo=sutdentscore.studentNo AND
score<60;

CREATE NONCLUSTERED--按照成绩表的成绩降序创建非聚集索引
INDEX  rollscore 
ON sutdentscore(score DESC) 

CREATE CLUSTERED--按照成绩表的学号和课程号创建聚集索引,唯一
INDEX  rollstudent
ON sutdentscore(studentNo,courseNo)


select studentName,score
from  sutdentscore,student 
where sutdentscore.studentNo=student.studentNo 
order by score DESC


create view Grade16--创建所有16级学生的信息视图
as 
select * from student where grade='2016级';

select * from Grade16;

create view Grade15--创建所有15级学生的信息视图
as 
select * from student where grade='2015级';

select * from Grade15;

create view allCourseTeacher--创建所有任课老师的信息视图
as 
select courseName,courseTeacher from course ;

select * from allCourseTeacher;




--创建存储过程，用游标遍历打印学生学号和成绩.
use SudentScore
create proc proc_scoreasDECLARE cur_stuno CURSOR FOR SELECT studentNo,score FROM sutdentscore-- 1定义游标DECLARE @stuno varchar(20)DECLARE @stusc int OPEN cur_stuno -- 2.打开游标FETCH NEXT FROM cur_stuno INTO @stuno,@stuscWHILE (@@FETCH_STATUS = 0)BEGIN    PRINT '学生学号:  ' + @stuno    PRINT '成绩:  ' + convert(char(8),@stusc)    PRINT ''    FETCH NEXT FROM cur_stuno INTO @stuno,@stuscENDCLOSE cur_stuno -- 关闭游标DEALLOCATE cur_stuno -- 删除游标exec proc_score--创建存储过程，单个参数用于输入学生学号时，输出相应成绩--如果没有此学号，就打印出不存在此学号create procedure proc_Query( @stuno varchar(20))asdeclare @stusc intselect @stusc=scorefrom sutdentscore where studentNo= @stunoif(select score from sutdentscore where studentNo=@stuno) is nullbeginprint '此学号不存在'endelseselect scorefrom sutdentscore where studentNo= @stuno--调用,执行存储过程exec proc_Query 'CST15001'--创建一个触发器，因为前面有约束外键，所以先删除CK_1外键,--然后创建关于成绩表的触发器，当往成绩表插入信息的时候，--触发器响应事件，如果学生表里面没有成绩表里相同的studentNo，--就提示错误，并且回滚事务，如果有相同studentNo，显示插入成功。create trigger studentinserton sutdentscore after insertasbegin	declare @studentNo varchar(20)	declare @score int		declare @msg varchar(200)	select  @studentNo=studentNo, @score = score FROM inserted   	if exists (select * from 	  sutdentscore where @studentNo NOT IN (select studentNo 	  from student)) 	begin		rollback transaction		set @msg = '学号：'+ @studentNo +'不存在，插入失败。'		raiserror(@msg,1,1) 		end	else	begin 		print '学号：'+@studentNo+'插入成功。'	endendalter table sutdentscore drop constraint CK_1 --先删除外键INSERT INTO sutdentscore
VALUES('CST13014','B00003','表演基础',78);INSERT INTO student
VALUES('CST13014','赵日天','男','数学','2015级');delete from studentwhere studentNo='CST13014';INSERT INTO sutdentscore
VALUES('CST13014','B00003','数学',78);