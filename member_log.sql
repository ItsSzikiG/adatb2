--History table
CREATE TABLE member_history (
    ID NUMBER,
    first_name VARCHAR2(50),
    second_name VARCHAR2(50),
    address VARCHAR2(500),
    contact VARCHAR2(100),
    mod_user VARCHAR2(300),
    created_on TIMESTAMP(6),
    last_mod TIMESTAMP(6),
    dml_flag VARCHAR2(1)
);

--History trigger
CREATE OR REPLACE TRIGGER member_history_trg
AFTER DELETE OR UPDATE OR INSERT ON member
FOR EACH ROW
BEGIN
    
    IF INSERTING THEN
        INSERT INTO member_history (
            id, first_name, second_name, address, contact,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :NEW.id, :NEW.first_name, :NEW.second_name, :NEW.address, :NEW.contact,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :NEW.created_on, SYSTIMESTAMP, 'I'
        );
    
    ELSIF UPDATING THEN
        INSERT INTO member_history (
            id, first_name, second_name, address, contact,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :NEW.id, :NEW.first_name, :NEW.second_name, :NEW.address, :NEW.contact,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :NEW.created_on, SYSTIMESTAMP, 'U'
        );
    
    ELSIF DELETING THEN
        INSERT INTO member_history (
            id, first_name, second_name, address, contact,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :OLD.id, :OLD.first_name, :OLD.second_name, :OLD.address, :OLD.contact,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :OLD.created_on, SYSTIMESTAMP, 'D'
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error in member_history_trg: ' || SQLERRM);
        RAISE;
END;
/

--Audit trigger
CREATE OR REPLACE TRIGGER member_audit_trg
BEFORE INSERT OR UPDATE ON member
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
