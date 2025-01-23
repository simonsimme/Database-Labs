CREATE TABLE Students(
    idnr TEXT PRIMARY KEY CHECK (idnr ~ '^[0-9]{10}$'),
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    program TEXT NOT NULL
);

CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (name,program)
);

CREATE TABLE Courses(
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    credits REAL NOT NULL,
    department TEXT NOT NULL
);
CREATE TABLE LimitedCourses(
    code TEXT PRIMARY KEY,
    capacity INT NOT NULL,
    FOREIGN KEY (code) REFERENCES Courses(code)
);
CREATE TABLE StudentBranches(
    student TEXT NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);
CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);
CREATE TABLE Classified(
course TEXT NOT NULL,
classification TEXT NOT NULL,
FOREIGN KEY (course) REFERENCES Courses(code),
FOREIGN KEY (classification) REFERENCES Classifications(name)
);
CREATE TABLE MandatoryProgram(
course TEXT NOT NULL,
program TEXT NOT NULL,
FOREIGN KEY (course) REFERENCES Courses(code)
);
CREATE TABLE MandatoryBranch(
    course TEXT NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (course) REFERENCES Courses(code),
    FOREIGN KEY (branch,program) REFERENCES Branches(name,program)
);
CREATE TABLE RecommendedBranch(
course TEXT NOT NULL,
branch TEXT NOT NULL,
program TEXT NOT NULL,
FOREIGN KEY (course) REFERENCES Courses(code),
FOREIGN KEY (branch,program) REFERENCES Branches(name,program)
);
CREATE TABLE Registered(
student TEXT NOT NULL,
course TEXT NOT NULL,
FOREIGN KEY (student) REFERENCES Students(idnr),
FOREIGN KEY (course) REFERENCES Courses(code)
);
CREATE TABLE Taken(
    student TEXT NOT NULL,
    course TEXT NOT NULL,
    grade TEXT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES Courses(code)
);

CREATE TABLE WaitingList(
    student TEXT NOT NULL,
    course TEXT NOT NULL,
    position INT NOT NULL,
    FOREIGN KEY (student) REFERENCES Students(idnr),
    FOREIGN KEY (course) REFERENCES LimitedCourses(code)
);

