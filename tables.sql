-- This file will contain all your tables


CREATE TABLE Students 
(
    idnr VARCHAR(10) NOT NULL PRIMARY KEY CHECK (idnr ~ '\d{10}$'),
    name TEXT NOT NULL,
    login TEXT NOT NULL
);
CREATE TABLE Program 
(
    name TEXT NOT NULL PRIMARY KEY
);

CREATE TABLE Branches
(
    name TEXT UNIQUE NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (name, program)  

);
CREATE TABLE Department
(
    name TEXT NOT NULL PRIMARY KEY,
    Abbr TEXT NOT NULL
);

CREATE TABLE Courses
(
    code VARCHAR(6) PRIMARY KEY NOT NULL,
    name VARCHAR(6) NOT NULL,
    credits FLOAT NOT NULL,
    department VARCHAR(10) NOT NULL,
    FOREIGN KEY (department) REFERENCES Department(name)
);

CREATE TABLE LimitedCourses 
(
    code VARCHAR(6) PRIMARY KEY,
    capacity INT NOT NULL CHECK (capacity >= 0),
    FOREIGN KEY (code) REFERENCES Courses (code)
);

CREATE TABLE StudentBranches 
(
    student VARCHAR(10) PRIMARY KEY,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (program) REFERENCES Program(name)
   -- (student, program) UNIQUE
);

CREATE TABLE Classifications
(
    name TEXT NOT NULL PRIMARY KEY
);

-- TODO: TA BORT?
CREATE TABLE Classified
(
    course VARCHAR(6),
    classification TEXT,
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (classification) REFERENCES Classifications (name),
    PRIMARY KEY (course, classification)
);

CREATE TABLE Prerequisites
(
    course VARCHAR(6) PRIMARY KEY,
    prerequisiteCourse VARCHAR(6) NOT NULL,
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (prerequisiteCourse) REFERENCES Courses(code)
);

CREATE TABLE MandatoryProgram
(
    course VARCHAR(6),
    program TEXT NOT NULL,
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (program) REFERENCES Program (name),
    PRIMARY KEY (course, program)
);

CREATE TABLE MandatoryBranch
(
    course VARCHAR(6),
    branch TEXT,
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch) REFERENCES Branches(name),
    PRIMARY KEY (course,branch)
);

CREATE TABLE RecommendedBranch
(
    course VARCHAR(6),
    branch TEXT,
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch) REFERENCES Branches(name),
    PRIMARY KEY (course,branch)
);

CREATE TABLE Registered
(
    student VARCHAR(10),
    course VARCHAR(6),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code),
    PRIMARY KEY (student, course)
);

CREATE TABLE Taken
(
    student VARCHAR(10),
    course VARCHAR(6),
    grade CHAR(1) NOT NULL CHECK (grade IN ('5', '4', '3', 'U')),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code),
    PRIMARY KEY (student, course)
);

CREATE TABLE WaitingList
(
    student VARCHAR(10),
    course VARCHAR(6) UNIQUE,
    position INT UNIQUE NOT NULL,
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses(code),
    PRIMARY KEY (student, course)
);




CREATE TABLE IsIn
(
    student VARCHAR(10),
    department TEXT,
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (department) REFERENCES Department(name),
    PRIMARY KEY (student, department)
);

CREATE TABLE Hosting
(
    program TEXT,
    department TEXT,
    FOREIGN KEY (program) REFERENCES Program(name),
    FOREIGN KEY (department) REFERENCES Department(name),
    PRIMARY KEY (program, department)
);

CREATE TABLE HasA -- Classifications connected to courses
(
    code VARCHAR(6),
    classification TEXT,
    FOREIGN KEY (code) REFERENCES Courses(code),
    FOREIGN KEY (classification) REFERENCES Classifications(name),
    PRIMARY KEY (code, classification)
)