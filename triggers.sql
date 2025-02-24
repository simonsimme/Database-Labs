-- This should be your trigger file for part 3

CREATE OR REPLACE FUNCTION check_capacity_before_registrating() RETURNS TRIGGER AS $$
DECLARE
    max_capacity INT;
    current_capacity INT;
    student_inRegistered INT;
    student_inWaitingList INT;
    nrPrereqs INT;
    passedPreReqs INT;
    passedCurr INT;
BEGIN
    SELECT capacity INTO max_capacity
    FROM LimitedCourses
    WHERE code = NEW.course;

    SELECT COUNT(*) INTO current_capacity
    FROM Registered
    WHERE course = NEW.course;

    SELECT COUNT(*) INTO student_inRegistered
    FROM Registrations
    WHERE course = NEW.course AND student = NEW.student AND status = 'registered';

    SELECT COUNT(*) INTO student_inWaitingList
    FROM Registrations
    WHERE course = NEW.course AND student = NEW.student AND status = 'waiting';

    SELECT COUNT(*) INTO nrPrereqs
    FROM Prerequisites
    WHERE course = NEW.course;

    SELECT COUNT(*) INTO passedPreReqs 
    FROM Prerequisites 
    JOIN Taken ON Prerequisites.prerequisiteCourse = Taken.course AND Taken.student = NEW.student AND Taken.grade IN ('5', '4', '3')
    WHERE Prerequisites.course = new.course;


-- TODO: FIX TO SEE IF STUDENT PASSED COURSE HES APPLYING TO\
    -- SELECT COUNT(*) INTO passedCurr

    -- Checking to satisfy student not already registered or in waiting list and has passed all prerequisites
    IF student_inRegistered > 0 THEN
        RAISE EXCEPTION 'Student is already registered';
    ELSEIF student_inWaitinglist > 0 THEN
        RAISE EXCEPTION 'Student is already in the waiting list';
    ELSEIF nrPrereqs > 0 AND passedPreReqs < nrPrereqs THEN
        RAISE EXCEPTION 'Student has not passed all prerequisite courses';
    ELSEIF 

    -- Checking to see where we route the student
  /*   ELSEIF current_capacity >= max_capacity THEN
        INSERT INTO WaitingList (student, code, position) VALUES 
        (NEW.student, NEW.code, (SELECT COALESCE(MAX(position), 0) + 1 FROM WaitingList WHERE code = NEW.code));
        RETURN NULL; */ -- Not on wating list should be on Registrations
    ELSEIF current_capacity >= max_capacity THEN
        INSERT INTO WaitingList (student, course, position) VALUES 
        (NEW.student, NEW.course, (SELECT COALESCE(MAX(position), 0) + 1 FROM WaitingList WHERE course = NEW.course));
        RETURN NULL;
    ELSE
        INSERT INTO Registered (student, course) VALUES (NEW.student, NEW.course);
        RETURN NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER check_capacity_before_registrating
INSTEAD OF INSERT ON Registrations -- the View registered
FOR EACH ROW
EXECUTE FUNCTION check_capacity_before_registrating();

CREATE OR REPLACE FUNCTION remove_from_waiting() RETURNS TRIGGER AS $$
DECLARE
    leftCourse VARCHAR(6);
    max_capacity INT;
    current_capacity INT;
    newStudent text;
    newCourse text;
BEGIN
    leftCourse = OLD.course;

    SELECT capacity INTO max_capacity
    FROM LimitedCourses
    WHERE code = OLD.course;

    SELECT COUNT(*) INTO current_capacity
    FROM Registered
    WHERE course = OLD.course;

    IF current_capacity < max_capacity THEN
        SELECT student, course INTO newStudent, newCourse
        FROM WaitingList
        WHERE course = leftCourse AND position = 1;
        INSERT INTO Registered (student, course) VALUES (newStudent, newCourse);
        DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
        DELETE FROM WaitingList WHERE course = leftCourse AND student = newStudent;
        return NULL;
    ELSE    
        DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
        return NULL;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER remove_from_waiting
INSTEAD OF DELETE ON Registrations
FOR EACH ROW 
EXECUTE FUNCTION remove_from_waiting();

