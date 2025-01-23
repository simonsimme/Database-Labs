-- This file will contain all your tables
-- This file will contain all your tables
CREATE TABLE Students(
    idnr TEXT PRIMARY KEY CHECK (idnr LIKE '__________'),
    name TEXT,
    login TEXT,
    program TEXT
);

CREATE TABLE Branches(
    name TEXT,
    program TEXT
);

Courses(
    code TEXT PRIMARY KEY CHECK (code LIKE '______'),
    name TEXT,
    credits REAL,
    department TEXT
);

