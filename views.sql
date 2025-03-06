-- This file will contain all your views


CREATE VIEW BasicInformation AS
SELECT 
    Students.idnr,
    Students.name,
    Students.login,
    Students.program,
    NULL AS branch
FROM Students
UNION ALL
SELECT
    Students.idnr,
    Students.name,
    Students.login,
    Students.program,
    StudentBranches.branch
    FROM Students
INNER JOIN StudentBranches ON Students.idnr = StudentBranches.student;

-- Helper function for FinishedCourses, returns (Students, course, credits)
CREATE VIEW PassedCourses AS
SELECT
    Taken.student,
    Taken.course,
    Courses.credits
FROM Taken
INNER JOIN Courses ON Taken.course = Courses.code AND Taken.grade != 'U';

-- Returns (Students, course, course name, grade, credit)

CREATE VIEW FinishedCourses AS
SELECT
    Taken.student,
    Taken.course,
    Courses.name as courseName,
    Taken.grade,
    Courses.credits
FROM Taken
LEFT JOIN Courses ON Courses.code = Taken.course;

-- (student, course, status)
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

-- (Student, course)
CREATE VIEW UnreadMandatory AS
SELECT
    Students.idnr AS Student,
    MandatoryProgram.course
FROM Students
INNER JOIN MandatoryProgram ON MandatoryProgram.program = Students.program
UNION
SELECT
    StudentBranches.student,
    MandatoryBranch.course
FROM StudentBranches
INNER JOIN MandatoryBranch ON MandatoryBranch.branch = StudentBranches.branch 
AND 
MandatoryBranch.program = StudentBranches.program
EXCEPT
SELECT
    PassedCourses.student,
    PassedCourses.course
FROM PassedCourses;

CREATE VIEW totalCredits AS
SELECT
    PassedCourses.student,
    COALESCE(SUM(Courses.credits), 0) AS totalCredits
FROM PassedCourses 
JOIN Courses ON PassedCourses.course = Courses.code
GROUP BY PassedCourses.student;

CREATE VIEW mandatoryLeft AS 
SELECT student, COALESCE(COUNT(course),0) as mandatoryLeft
FROM UnreadMandatory
GROUP BY student;

-- (student, credits, mandatory)
CREATE VIEW firstThreeC AS 
SELECT 
    Students.idnr,
    totalCredits.totalCredits,
    mandatoryLeft.mandatoryLeft
FROM Students
LEFT JOIN totalCredits ON totalCredits.student = Students.idnr
LEFT JOIN mandatoryLeft ON mandatoryLeft.student = Students.idnr;


-- (student, mathCredits)
CREATE VIEW mathCredits AS
SELECT 
    Taken.student AS studentID,
    COALESCE(SUM(Courses.credits), 0) as mathCredits
FROM Taken
INNER JOIN Courses ON Taken.course = Courses.code 
INNER JOIN PassedCourses ON PassedCourses.student = Taken.student 
AND PassedCourses.course = Courses.code
LEFT JOIN HasA ON Courses.code = HasA.code 
AND HasA.classification = 'math'
WHERE HasA.classification IS NOT NULL
GROUP BY studentID;

-- (student, count(seminarcourses))
CREATE VIEW seminarcourses AS
SELECT 
    Taken.student AS studentID,
    COALESCE(COUNT(Courses.credits),0) AS seminarcount
FROM Taken
INNER JOIN Courses ON Taken.course = Courses.code 
INNER JOIN PassedCourses ON PassedCourses.student = Taken.student 
AND PassedCourses.course = Courses.code
LEFT JOIN HasA ON Courses.code = HasA.code
AND HasA.classification = 'seminar'
WHERE HasA.classification IS NOT NULL
GROUP BY studentID;



CREATE VIEW passedRecommended AS
SELECT 
    Students.idnr as student,
    COALESCE(SUM(PassedCourses.credits),0) as credits
FROM Students
INNER JOIN PassedCourses ON Students.idnr = PassedCourses.student
LEFT JOIN RecommendedBranch on RecommendedBranch.course = PassedCourses.course 
LEFT JOIN StudentBranches ON Students.idnr = StudentBranches.student
AND RecommendedBranch.program = StudentBranches.program
WHERE RecommendedBranch IS NOT NULL AND RecommendedBranch.branch = StudentBranches.branch
GROUP BY Students.idnr;

CREATE VIEW PathToGraduation AS
SELECT 
    Students.idnr AS student,
    COALESCE(totalCredits.totalCredits,0) AS totalCredits,
    COALESCE(mandatoryLeft.mandatoryLeft,0) AS mandatoryLeft, 
    COALESCE(mathCredits.mathCredits,0) AS mathCredits,
    COALESCE(seminarcourses.seminarcount,0) as seminarcourses,
    (totalCredits.totalCredits > 10) AND 
    (passedRecommended.credits >= 10 AND passedRecommended.credits IS NOT NULL) AND 
    (mandatoryLeft.mandatoryLeft = 0 OR mandatoryLeft.mandatoryLeft IS NULL) AND
    (mathCredits.mathCredits >= 20 AND mathCredits.mathCredits IS NOT NULL) AND
    (seminarcourses.seminarcount >= 1 AND seminarcourses.seminarcount IS NOT NULL) AS qualified
FROM Students
LEFT JOIN totalCredits ON totalCredits.student = Students.idnr
LEFT JOIN mandatoryLeft ON mandatoryLeft.student = Students.idnr
LEFT JOIN mathCredits ON mathCredits.studentID = Students.idnr
LEFT JOIN seminarcourses ON seminarcourses.studentID = Students.idnr
LEFT JOIN passedRecommended ON Students.idnr = passedRecommended.student;

