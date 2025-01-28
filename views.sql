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
    Taken.student,
    Taken.course,
    Courses.credits
FROM Taken
INNER JOIN Courses ON Taken.course = Courses.code AND Taken.grade != 'U';

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

-- Helper view for unreadmandatory courses (Student, course)
CREATE VIEW UnreadMandatory AS
(SELECT
    Students.idnr AS student,
    MandatoryProgram.course
FROM MandatoryProgram
INNER JOIN Students ON MandatoryProgram.program = Students.program
UNION
SELECT
    StudentBranches.student,
    MandatoryBranch.course
FROM MandatoryBranch
INNER JOIN StudentBranches ON MandatoryBranch.program = StudentBranches.program 
AND MandatoryBranch.branch = StudentBranches.branch)
EXCEPT
SELECT
    PassedCourses.student,
    PassedCourses.course
FROM PassedCourses;

CREATE VIEW totalCredits AS
SELECT
    Taken.student,
    COALESCE(SUM(Courses.credits), 0) AS totalCredits
FROM Taken 
LEFT JOIN Courses ON Taken.course = Courses.code
WHERE EXISTS 
(SELECT 1 FROM PassedCourses WHERE PassedCourses.student = Taken.student)
GROUP BY student;

CREATE VIEW mandatoryLeft AS 
SELECT student, COUNT(course) as mandatoryLeft
FROM UnreadMandatory
GROUP BY student;

-- student, credits, mandatory
CREATE VIEW firstThreeC AS 
SELECT 
    Students.idnr,
    totalCredits.totalCredits,
    mandatoryLeft.mandatoryLeft
FROM Students
LEFT JOIN totalCredits ON totalCredits.student = Students.idnr
LEFT JOIN mandatoryLeft ON mandatoryLeft.student = Students.idnr;


-- Currently not working as intended!
CREATE VIEW mathCredits AS 
SELECT 
    Taken.student as studentID,
    COALESCE(SUM(PassedCourses.credits),0) as mathCredits
FROM Taken
INNER JOIN PassedCourses ON PassedCourses.student = Taken.student
WHERE EXISTS (SELECT 1 FROM Classified WHERE PassedCourses.course = Classified.course 
AND 
Classified.classification = 'math')
GROUP BY studentID;
