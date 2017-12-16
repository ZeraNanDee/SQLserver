USE MASTER  
GO 
IF db_id('SudentScore') IS NOT NULL
	DROP DATABASE  SudentScore
GO
CREATE DATABASE SudentScore


/*******************************
�������ݱ�
*******************************/




USE SudentScore
/*1.ѧ����Ϣ��*/
CREATE TABLE student
(
	studentNo VARCHAR(20) PRIMARY KEY NOT NULL,--ѧ��ѧ��
	studentName VARCHAR(20) NOT NULL,--ѧ������
	sex CHAR(10) NOT NULL,--ѧ���Ա�
	major VARCHAR(20) NOT NULL,--ѧ��רҵ
	grade VARCHAR(10) NOT NULL,--ѧ���꼶
)
GO

/*2.�γ���Ϣ��*/
CREATE TABLE course
(
	courseNo VARCHAR(20)  PRIMARY KEY NOT NULL ,--�γ̱��
	courseName VARCHAR(20) NOT NULL,--�γ�����
	courseTeacher VARCHAR(30) NOT NULL,--�γ̽�ʦ
)
GO


/*3.ѧ���ɼ���Ϣ��*/
CREATE TABLE sutdentscore
(
	studentNo VARCHAR(20)  NOT NULL,--ѧ�����
	courseNo VARCHAR(20)   NOT NULL ,--�γ̱��
	courseName VARCHAR(20) NOT NULL,--�γ�����
	score int not null--ѧ���ɼ�
)
GO

/*4.��ʦ�û������ݴ˱��¼������ϱ���в�Ĳ���*/
CREATE TABLE users
(
	name VARCHAR(20) NOT NULL,
	password VARCHAR(20) NOT NULL
)
GO

alter table sutdentscore
add constraint CK_s check (score>=0 AND score<=100)--���Լ�����óɼ��ķ�Χ
alter table sutdentscore add constraint CK_1 foreign key(studentNo) references student(studentNo)--������
alter table sutdentscore add constraint CK_2 foreign key(courseNo) references course(courseNo)--������



INSERT INTO student VALUES('CST15001','��СС','Ů','��ѧ','2015��');
INSERT INTO student VALUES('CST16022','¬��ΰ','��','�������ѧ�뼼��','2016��');
INSERT INTO student VALUES('CST16013','������','��','���ξ���ѧ','2016��');
INSERT INTO student VALUES('CST13054','���»�','��','���ֱ���','2013��');





INSERT INTO course
VALUES('B00003','���ݻ���','����');
INSERT INTO course
VALUES('B00006','���ݿ�ԭ��','����');
INSERT INTO course
VALUES('B00001','���˼ԭ��','�ź���');
INSERT INTO course 
VALUES('B00002','����ѧ','����');

INSERT INTO sutdentscore
VALUES('CST15001','B00002','����ѧ',89);
INSERT INTO sutdentscore
VALUES('CST16022','B00006','���ݿ�ԭ��',40);
INSERT INTO sutdentscore
VALUES('CST16013','B00001','���˼ԭ��',99);
INSERT INTO sutdentscore
VALUES('CST13054','B00003','���ݻ���',78);

INSERT INTO users
VALUES('DHDA111','HUANQ111D');
INSERT INTO users
VALUES('CCA2445','55521DDS');

select *from student;
select *from course;
select *from sutdentscore;

select AVG(score) as 'ѧ����ƽ����'--ͳ��ѧ������ƽ����
from sutdentscore;

select studentNo,studentName --�����ս���ͬѧ
from student
where studentName like '��%';

select studentName--���Ҳ������ͬѧ
from student,sutdentscore
where student.studentNo=sutdentscore.studentNo AND
score<60;

CREATE NONCLUSTERED--���ճɼ���ĳɼ����򴴽��Ǿۼ�����
INDEX  rollscore 
ON sutdentscore(score DESC) 

CREATE CLUSTERED--���ճɼ����ѧ�źͿγ̺Ŵ����ۼ�����,Ψһ
INDEX  rollstudent
ON sutdentscore(studentNo,courseNo)


select studentName,score
from  sutdentscore,student 
where sutdentscore.studentNo=student.studentNo 
order by score DESC


create view Grade16--��������16��ѧ������Ϣ��ͼ
as 
select * from student where grade='2016��';

select * from Grade16;

create view Grade15--��������15��ѧ������Ϣ��ͼ
as 
select * from student where grade='2015��';

select * from Grade15;

create view allCourseTeacher--���������ο���ʦ����Ϣ��ͼ
as 
select courseName,courseTeacher from course ;

select * from allCourseTeacher;




--�����洢���̣����α������ӡѧ��ѧ�źͳɼ�.
use SudentScore
create proc proc_scoreasDECLARE cur_stuno CURSOR FOR SELECT studentNo,score FROM sutdentscore-- 1�����α�DECLARE @stuno varchar(20)DECLARE @stusc int OPEN cur_stuno -- 2.���α�FETCH NEXT FROM cur_stuno INTO @stuno,@stuscWHILE (@@FETCH_STATUS = 0)BEGIN    PRINT 'ѧ��ѧ��:  ' + @stuno    PRINT '�ɼ�:  ' + convert(char(8),@stusc)    PRINT ''    FETCH NEXT FROM cur_stuno INTO @stuno,@stuscENDCLOSE cur_stuno -- �ر��α�DEALLOCATE cur_stuno -- ɾ���α�exec proc_score--�����洢���̣�����������������ѧ��ѧ��ʱ�������Ӧ�ɼ�--���û�д�ѧ�ţ��ʹ�ӡ�������ڴ�ѧ��create procedure proc_Query( @stuno varchar(20))asdeclare @stusc intselect @stusc=scorefrom sutdentscore where studentNo= @stunoif(select score from sutdentscore where studentNo=@stuno) is nullbeginprint '��ѧ�Ų�����'endelseselect scorefrom sutdentscore where studentNo= @stuno--����,ִ�д洢����exec proc_Query 'CST15001'--����һ������������Ϊǰ����Լ�������������ɾ��CK_1���,--Ȼ�󴴽����ڳɼ���Ĵ������������ɼ��������Ϣ��ʱ��--��������Ӧ�¼������ѧ��������û�гɼ�������ͬ��studentNo��--����ʾ���󣬲��һع������������ͬstudentNo����ʾ����ɹ���create trigger studentinserton sutdentscore after insertasbegin	declare @studentNo varchar(20)	declare @score int		declare @msg varchar(200)	select  @studentNo=studentNo, @score = score FROM inserted   	if exists (select * from 	  sutdentscore where @studentNo NOT IN (select studentNo 	  from student)) 	begin		rollback transaction		set @msg = 'ѧ�ţ�'+ @studentNo +'�����ڣ�����ʧ�ܡ�'		raiserror(@msg,1,1) 		end	else	begin 		print 'ѧ�ţ�'+@studentNo+'����ɹ���'	endendalter table sutdentscore drop constraint CK_1 --��ɾ�����INSERT INTO sutdentscore
VALUES('CST13014','B00003','���ݻ���',78);INSERT INTO student
VALUES('CST13014','������','��','��ѧ','2015��');delete from studentwhere studentNo='CST13014';INSERT INTO sutdentscore
VALUES('CST13014','B00003','��ѧ',78);