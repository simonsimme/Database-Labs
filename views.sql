-- This file will contain all your views


CREATE VIEW BasicInformation AS
SELECT 
    Students.idnr,
    Students.name,
    Students.login,
    Students.program,
    StudentBranches.branch
FROM Students
FULL OUTER JOIN StudentBranches ON Students.idnr = StudentBranches.student;

-- Helper function for FinishedCourses, returns (Students, course, credits)
CREATE VIEW PassedCourses AS
SELECT
    Students.name,
    Taken.course,
    Courses.credits
FROM Students
INNER JOIN Taken ON Taken.student = Students.idnr 
AND Taken.grade != 'U'
LEFT JOIN Courses ON Taken.course = Courses.code;

-- Returns (Students, course, courseName, grade, credit)

CREATE VIEW FinishedCourses AS
SELECT
    Taken.student,
    Taken.course,
    Courses.courseName,
    Taken.grade,
    Courses.credits
FROM Taken
LEFT JOIN Courses ON Courses.code = Taken.course;

-- Returns (student, course, status)
-- Question for TA how UNION orders the rows since not all regist then all waiting
CREATE VIEW Registrations AS
SELECT
    Registered.student,
    Registered.course,
    'registered' AS status
FROM Registered
UNION
SELECT
    WaitingList.student,
    WaitingList.course,
    'waiting' AS status
FROM WaitingList;




