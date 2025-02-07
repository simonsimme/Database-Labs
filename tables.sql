-- This file will contain all your tables


CREATE TABLE Students 
(
    idnr VARCHAR(10) NOT NULL PRIMARY KEY CHECK (idnr ~ '\d{10}$'),
    name VARCHAR(25) NOT NULL,
    login TEXT NOT NULL, 
    program TEXT NOT NULL
);

CREATE TABLE Branches
(
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (name, program)  

);

CREATE TABLE Courses
(
    code VARCHAR(6) PRIMARY KEY NOT NULL,
    name VARCHAR(25) NOT NULL,
    credits FLOAT NOT NULL,
    department VARCHAR(10) NOT NULL
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
    FOREIGN KEY (student) REFERENCES Students(idnr)
);

CREATE TABLE Classifications
(
    name TEXT NOT NULL PRIMARY KEY
);

CREATE TABLE Classified
(
    course VARCHAR(6),
    classification TEXT,
    FOREIGN KEY (course) REFERENCES Courses (code),
    FOREIGN KEY (classification) REFERENCES Classifications (name),
    PRIMARY KEY (course, classification)
);

CREATE TABLE MandatoryProgram
(
    course VARCHAR(6),
    program TEXT NOT NULL,
    FOREIGN KEY (course) REFERENCES Courses (code),
    PRIMARY KEY (course, program)
);

CREATE TABLE MandatoryBranch
(
    course VARCHAR(6),
    branch TEXT,
    program TEXT,
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY (course,branch,program)
);

CREATE TABLE RecommendedBranch
(
    course VARCHAR(6),
    branch TEXT,
    program TEXT,
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY (course,branch,program)
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
    course VARCHAR(6),
    position INT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses(code),
    PRIMARY KEY (student, course)
);
