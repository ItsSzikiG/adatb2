--History table
CREATE TABLE staff_history (
    ID NUMBER,
    first_name VARCHAR2(50),
    second_name VARCHAR2(50),
    ROLE VARCHAR2(100),
    contact VARCHAR2(100),
    mod_user VARCHAR2(300),
    created_on TIMESTAMP(6),
    last_mod TIMESTAMP(6),
    dml_flag VARCHAR2(1)
);

--History trigger
CREATE OR REPLACE TRIGGER staff_history_trg
AFTER DELETE OR UPDATE OR INSERT ON staff
FOR EACH ROW
BEGIN
    
    IF INSERTING THEN
        INSERT INTO staff_history (
            id, first_name, second_name, ROLE, contact,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :NEW.id, :NEW.first_name, :NEW.second_name, :NEW.ROLE, :NEW.contact,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :NEW.created_on, SYSTIMESTAMP, 'I'
        );
    
    ELSIF UPDATING THEN
        INSERT INTO staff_history (
            id, first_name, second_name, ROLE, contact,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :NEW.id, :NEW.first_name, :NEW.second_name, :NEW.ROLE, :NEW.contact,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :NEW.created_on, SYSTIMESTAMP, 'U'
        );
    
    ELSIF DELETING THEN
        INSERT INTO staff_history (
            id, first_name, second_name, ROLE, contact,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :OLD.id, :OLD.first_name, :OLD.second_name, :OLD.ROLE, :OLD.contact,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :OLD.created_on, SYSTIMESTAMP, 'D'
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error in staff_history_trg: ' || SQLERRM);
        RAISE;
END;
/

--Audit trigger 
CREATE OR REPLACE TRIGGER staff_audit_trg
BEFORE INSERT OR UPDATE ON staff
FOR EACH ROW 
BEGIN 
    IF INSERTING THEN
        :NEW.created_on := SYSTIMESTAMP;
        :NEW.last_mod := SYSTIMESTAMP;
        :NEW.dml_flag := 'I';
        :NEW.mod_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    ELSIF UPDATING THEN
        :NEW.last_mod := SYSTIMESTAMP;
        :NEW.dml_flag := 'U';
        :NEW.mod_user := SYS_CONTEXT('USERENV', 'SESSION_USER');
    END IF;
END;
/
