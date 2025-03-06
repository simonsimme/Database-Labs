CREATE FUNCTION register_student() RETURNS TRIGGER AS $$
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
    Where code = NEW.course;

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

    SELECT COUNT(*) INTO passedCurr
    FROM Taken
    INNER JOIN Courses ON Taken.course = new.course AND Taken.student = NEW.student AND Taken.grade != 'U';

    --check if student is in reg or wait list
    IF student_inRegistered > 0 THEN 
        RAISE EXCEPTION 'Student is allready registered';
        RETURN NULL;
    END IF;
    
    IF student_inWaitingList > 0 THEN 
        RAISE EXCEPTION 'Student is allready in waiting list';
        RETURN NULL;
    END IF;


    --check if student can register
    IF nrPrereqs > 0 AND passedPreReqs < nrPrereqs THEN
        RAISE EXCEPTION 'Student has not passed all pre requsites';
        RETURN NULL;
    END IF;

    IF passedCurr > 0 THEN
        RAISE EXCEPTION 'Student has passed already';
        RETURN NULL;
    END IF;


    --register or place in waiting
    IF  max_capacity <= current_capacity THEN
        INSERT INTO WaitingList(student, course, position) VALUES
            (NEW.student, NEW.course, (SELECT COALESCE(MAX(position), 0) + 1 FROM WaitingList WHERE course = NEW.course));
        RETURN NEW;
    ELSE
        INSERT INTO Registered(student, course) VALUES
            (NEW.student, NEW.course);
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE trigger register_student
INSTEAD OF INSERT ON Registrations -- the View registered
FOR EACH ROW
EXECUTE FUNCTION register_student();

CREATE FUNCTION unregister() RETURNS TRIGGER AS $$
DECLARE
leftCourse VARCHAR(6);
    max_capacity INT;
    current_capacity INT;
    student_is_reg INT;
    student_inWaitingList INT;
    newStudent text;
    newCourse text;
    removedPosition INT;
  waitingListCount INT;
BEGIN
    leftCourse = OLD.course;

    SELECT COUNT(*) INTO student_is_reg
    FROM Registrations
    WHERE course = OLD.course AND student = OLD.student AND status = 'registered';

      SELECT COUNT(*) INTO student_inWaitingList
    FROM Registrations
    WHERE course = OLD.course AND student = OLD.student AND status = 'waiting';

    SELECT COUNT(*) INTO waitingListCount FROM WaitingList WHERE course = leftCourse;


 SELECT capacity INTO max_capacity
    FROM LimitedCourses
    Where code = OLD.course;

    SELECT COUNT(*) INTO current_capacity
    FROM Registered
    WHERE course = OLD.course;

 -- remove from reg
     IF student_is_reg = 0 AND student_inWaitingList = 0 THEN
        RAISE EXCEPTION 'student not found';
        RETURN NULL;
    END IF;

    IF student_is_reg > 0 THEN
     DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
     current_capacity = current_capacity -1;
    -- RETURN OLD;
    ELSE
        SELECT position INTO removedPosition FROM WaitingList
        WHERE course = leftCourse AND student = OLD.student;
        DELETE FROM WaitingList WHERE course = leftCourse AND student = OLD.student;
        UPDATE WaitingList
        SET position = position -1
        WHERE  course = leftCourse AND position > removedPosition;
       -- RETURN OLD;
    
    END IF;
       

 --if students in waitinglist let first one join
     IF current_capacity < max_capacity AND waitingListCount > 0  THEN
        SELECT student, course INTO newStudent, newCourse FROM WaitingList
        WHERE course = leftCourse AND position = 1;
        DELETE FROM WaitingList WHERE course = leftCourse AND student = newStudent;
        INSERT INTO Registered (student, course) VALUES (newStudent, newCourse);
        removedPosition = 1;
        UPDATE WaitingList
        SET position = position -1
        WHERE  course = leftCourse AND position > removedPosition;
    ELSE
        -- Base case: No action needed if no students in waiting list or capacity is full
        RAISE NOTICE 'No action needed';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER unregister_student
INSTEAD OF DELETE ON Registrations
FOR EACH ROW
EXECUTE FUNCTION unregister();