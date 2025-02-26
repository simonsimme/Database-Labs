-- This file will contain all your tables

CREATE TABLE Program 
(
    name TEXT  NOT NULL PRIMARY KEY
);


CREATE TABLE Students 
(
    idnr VARCHAR(10) NOT NULL PRIMARY KEY CHECK (idnr ~ '\d{10}$'),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (program) REFERENCES Program(name),
    UNIQUE (login)
);


CREATE TABLE Branches
(
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (program) REFERENCES Program(name),
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
    student VARCHAR(10),
    branch TEXT,
    program TEXT,
    PRIMARY KEY (student, branch, program),
    FOREIGN KEY (program, branch) REFERENCES Branches(program, name),
    FOREIGN KEY (student) REFERENCES Students(idnr),
    UNIQUE (student, program)   
);

CREATE TABLE Classifications
(
    name TEXT NOT NULL PRIMARY KEY
);


CREATE TABLE Prerequisites
(
    course VARCHAR(6),
    prerequisiteCourse VARCHAR(6) NOT NULL,
    PRIMARY KEY (course, prerequisiteCourse),
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
    PRIMARY KEY (student, course),
    UNIQUE (course, position)     
);


CREATE TABLE Hosting
(
    program TEXT,
    department TEXT,
    FOREIGN KEY (program) REFERENCES Program(name),
    FOREIGN KEY (department) REFERENCES Department(name),
    PRIMARY KEY (program, department)
);

CREATE TABLE HasA
(
    code VARCHAR(6),
    classification TEXT,
    FOREIGN KEY (code) REFERENCES Courses(code),
    FOREIGN KEY (classification) REFERENCES Classifications(name),
    PRIMARY KEY (code, classification)
);

