--History table
CREATE TABLE borrow_record_history (
    ID NUMBER,
    member_id NUMBER,
    book_id NUMBER,
    borrow_date DATE,
    return_date DATE,
    mod_user VARCHAR2(300),
    created_on TIMESTAMP(6),
    last_mod TIMESTAMP(6),
    dml_flag VARCHAR2(1)
);

--History trigger
CREATE OR REPLACE TRIGGER borrow_record_history_trg
AFTER DELETE OR UPDATE OR INSERT ON borrow_record
FOR EACH ROW
BEGIN
    
    IF INSERTING THEN
        INSERT INTO borrow_record_history (
            id, member_id, book_id, borrow_date, return_date,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :NEW.id, :NEW.member_id, :NEW.book_id, :NEW.borrow_date, :NEW.return_date,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :NEW.created_on, SYSTIMESTAMP, 'I'
        );
    
    ELSIF UPDATING THEN
        INSERT INTO borrow_record_history (
            id, member_id, book_id, borrow_date, return_date,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :NEW.id, :NEW.member_id, :NEW.book_id, :NEW.borrow_date, :NEW.return_date,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :NEW.created_on, SYSTIMESTAMP, 'U'
        );
    
    ELSIF DELETING THEN
        INSERT INTO borrow_record_history (
            id, member_id, book_id, borrow_date, return_date,
            mod_user, created_on, last_mod, dml_flag
        ) VALUES (
            :OLD.id, :OLD.member_id, :OLD.book_id, :OLD.borrow_date, :OLD.return_date,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            :OLD.created_on, SYSTIMESTAMP, 'D'
        );
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error in borrow_record_history_trg: ' || SQLERRM);
        RAISE;
END;
/

--Audit trigger 
CREATE OR REPLACE TRIGGER borrow_record_audit_trg
BEFORE INSERT OR UPDATE ON borrow_record
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
