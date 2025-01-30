-- This file will contain all your views

CREATE VIEW BasicInformation AS
SELECT
    s.idnr,
    s.name,
    s.login,
    s.program,
    sb.branch
FROM
    Students s
    FULL OUTER JOIN StudentBranches sb ON s.idnr = sb.student;

CREATE VIEW PassedCourses AS
SELECT
    s.name,
    t.course,
    c.credits
FROM
    Students s
    INNER JOIN Taken t ON t.student = s.idnr
    LEFT JOIN Courses c ON t.course = c.code
WHERE
    t.grade != 'U';

CREATE VIEW FinishedCourses AS
SELECT
    s.idnr,
    t.course,
    c.name,
    t.grade,
    c.credits
FROM
    Students s
    INNER JOIN Taken t ON t.student = s.idnr
    LEFT JOIN Courses c ON c.code = t.course;

CREATE VIEW Registrations AS
SELECT
    s.name,
    r.course,
    'registered' AS status
FROM
    Registered r
    LEFT JOIN Students s ON r.student = s.idnr
UNION
SELECT
    s.name,
    w.course,
    'waiting' AS status
FROM
    WaitingList w
    LEFT JOIN Students s ON w.student = s.idnr;

CREATE VIEW PathToGraduation AS
SELECT
s.idnr,
SUM(c.credits) AS totalCredits,
mb.course,
SUM(cm.credits) AS mathCredits,
COUNT(cs.course) AS seminarCourseCount,
FROM
    Students s
    Courses c
    LEFT JOIN Taken t ON t.student = s.idrn
    LEFT JOIN MandatoryBranch mb ON mb.course = c.course
    LEFT JOIN Classified cl ON cl.classification = 'math'
    LEFT JOIN t ON t.course = cl.course
    LEFT JOIN Courses cm ON cm.course = t.course
    LEFT JOIN Classified cls ON cl.classification = 'seminar'
    INNER JOIN Taken ts ON ts.student = s.idnr
    AND ts.grade != 'U'
    LEFT JOIN ts ON ts.course = cls.course
    LEFT JOIN Courses cs ON cs.course = ts.course
    --INNER JOIN 